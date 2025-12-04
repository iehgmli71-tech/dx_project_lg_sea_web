// lib/services/power_usage_manager.dart
import '../models/device_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PowerUsageManager {
  PowerUsageManager._internal();
  static final PowerUsageManager instance = PowerUsageManager._internal();

  /// 인도네시아 R1 1300VA 주택용 요금 (대략) – Rp/ kWh
  /// 출처: PLN 요금표 ~1,444.7 Rp/kWh 기준
  static const double tariffIdrPerKwh = 1444.7;

  final Map<String, _RuntimeDeviceUsage> _devices = {};

  double _todayKwh = 0.0;
  double _monthKwh = 0.0;

  /// 오늘 0시
  DateTime _todayDate = _dateOnly(DateTime.now());

  /// 이번 달 1일 0시
  DateTime _monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);

  /// 마지막으로 누적 계산을 한 시점
  DateTime _lastUpdate = DateTime.now();

  int? _currentUserId;

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  Future<void> init(int userId) async {
    _currentUserId = userId;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final todayStr = '${now.year}-${now.month}-${now.day}';
    final monthStr = '${now.year}-${now.month}';

    final savedTodayStr =
    prefs.getString('usage_today_date_$userId');
    final savedMonthStr =
    prefs.getString('usage_month_ym_$userId');

    // 오늘 사용량 복구 또는 초기화
    if (savedTodayStr == todayStr) {
      _todayKwh = prefs.getDouble('usage_today_kwh_$userId') ?? 0.0;
    } else {
      _todayKwh = 0.0;
      await prefs.setString('usage_today_date_$userId', todayStr);
      await prefs.setDouble('usage_today_kwh_$userId', 0.0);
    }

    // 이번 달 사용량 복구 또는 초기화
    if (savedMonthStr == monthStr) {
      _monthKwh = prefs.getDouble('usage_month_kwh_$userId') ?? 0.0;
    } else {
      _monthKwh = 0.0;
      await prefs.setString('usage_month_ym_$userId', monthStr);
      await prefs.setDouble('usage_month_kwh_$userId', 0.0);
    }

    _todayDate = DateTime(now.year, now.month, now.day);
    _monthStart = DateTime(now.year, now.month, 1);
    _lastUpdate = now;
  }

  // ---------------------- public getter ----------------------

  double get todayKwh => _todayKwh;
  double get monthKwh => _monthKwh;

  /// 이번 달 예상 요금 (후불 기준)
  double get estimatedMonthlyBillIdr => _monthKwh * tariffIdrPerKwh;

  /// 오늘/이번달 사용량을 SharedPreferences 에 저장
  Future<void> _saveUsage() async {
    final uid = _currentUserId;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('usage_today_kwh_$uid', _todayKwh);
    await prefs.setDouble('usage_month_kwh_$uid', _monthKwh);
  }


  // ---------------------- device 등록 ------------------------

  void registerDevice(Device device) {
    if (_devices.containsKey(device.id)) return;
    _devices[device.id] = _RuntimeDeviceUsage(
      deviceId: device.id,
      averagePowerW: device.averagePowerW,
      isOn: device.active,
    );
  }

  /// CardMode에서 기기 전원이 켜짐/꺼짐 될 때마다 호출
  void setDevicePower(String deviceId, bool isOn) {
    final now = DateTime.now();
    _rollDatesIfNeeded(now);
    _accumulateUsageUntil(now);

    final d = _devices[deviceId];
    if (d == null) return;

    d.isOn = isOn;
    d.lastStateChange = now;
  }

  /// 주기적으로(예: 30초마다) 호출해서 kWh 계속 누적
  void tick() {
    final now = DateTime.now();
    _rollDatesIfNeeded(now);
    _accumulateUsageUntil(now);
  }

  // ---------------------- 내부 로직 ---------------------------

  void _rollDatesIfNeeded(DateTime now) {
    final today = _dateOnly(now);
    if (today.isAfter(_todayDate)) {
      // 날짜가 하루 이상 지남 → 오늘 사용량 리셋
      _todayKwh = 0.0;
      _todayDate = today;
      _saveUsage();
    }

    final monthStartNow = DateTime(now.year, now.month, 1);
    if (monthStartNow.isAfter(_monthStart)) {
      // 새 달로 넘어감 → 이번달 사용량 리셋
      _monthKwh = 0.0;
      _monthStart = monthStartNow;
      _saveUsage();
    }
  }

  void _accumulateUsageUntil(DateTime now) {
    final seconds = now.difference(_lastUpdate).inSeconds;
    if (seconds <= 0) return;

    final hours = seconds / 3600.0;

    // 현재 ON 상태인 기기들의 총 소비전력 (W 합)
    double totalWatt = 0.0;
    for (final d in _devices.values) {
      if (d.isOn) {
        totalWatt += d.averagePowerW;
      }
    }

    // kWh = (W * 시간[h]) / 1000
    final addedKwh = (totalWatt * hours) / 1000.0;

    _todayKwh += addedKwh;
    _monthKwh += addedKwh;
    _lastUpdate = now;

    _saveUsage(); // 🔹 누적 이후 항상 저장
  }
}

class _RuntimeDeviceUsage {
  final String deviceId;
  final double averagePowerW;
  bool isOn;
  DateTime lastStateChange;

  _RuntimeDeviceUsage({
    required this.deviceId,
    required this.averagePowerW,
    required this.isOn,
  }) : lastStateChange = DateTime.now();
}
