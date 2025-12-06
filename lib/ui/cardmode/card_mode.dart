import 'package:flutter/material.dart';
import '../../models/device_models.dart';
import '../../models/dashboard_model.dart';
import '../../data/consumables_data.dart';
import '../consumables/consumables_overview.dart';
import '../power/power_management.dart';
import '../mypage/my_page.dart';
import 'package:dx_projecet_lg_sea/ui/cardmode/common/dialog.dart';
import 'package:dx_projecet_lg_sea/ui/cardmode/common/notification.dart';
import 'prayer_schedule_sheet.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
// 🔥 ESP32 연동
import 'package:dx_projecet_lg_sea/services/esp32_api.dart';
// 전력 연동
import 'package:dx_projecet_lg_sea/services/power_usage_manager.dart';


class CardMode extends StatefulWidget {
  final bool isLoggedIn;
  final int userId;
  final String userName;
  final String membership;
  final String qReward;
  final VoidCallback onLogout;

  const CardMode({
    super.key,
    required this.isLoggedIn,
    required this.userId,
    required this.userName,
    required this.membership,
    required this.qReward,
    required this.onLogout,
  });

  @override
  State<CardMode> createState() => _CardModeState();
}


class _CardModeState extends State<CardMode> with WidgetsBindingObserver{
  Device? selectedDevice;
  bool showPrayerSchedule = false;
  bool showNotifications = false;
  bool ramadanEcoMode = false;
  String activeTab = 'home';
  final int temperature = 32;
  Device? selectDevice;

  // 대시보드 데이터(날씨, 사용자 정보 등)
  DashboardData? _dashboardData;
  bool _isDataLoading = true; // 데이터 로딩 중인지 여부 확인
  Timer? _timer; // 타이머 변수

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 상태 감지기 등록

    // 화면이 켜지자마자 데이터 가져옴
    _fetchDashboardData();

    _powerPage = PowerManagement(userId: widget.userId);
    // 🔋 전력 사용량 매니저에 디바이스 등록
    for (final d in devices) {
      PowerUsageManager.instance.registerDevice(d);
    }

    // 1시간마다 자동으로 날씨 데이터 갱신 (기상청 주기에 맞춤)
    _timer = Timer.periodic(const Duration(minutes: 60), (timer) {
      print('날씨 정보를 최신으로 갱신합니다.');
      _fetchDashboardData();
    });
  }

  @override
  void dispose() { // 앱 종료 시 타이머와 감지기 해제
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    // 🔥 LG Regen 화면을 떠날 때 → 모든 보드에 "Hello ThinQ" + LED OFF
    Esp32Api.showHelloThinqAll();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // 앱 상태 변화 감지
    if(state == AppLifecycleState.resumed) {
      print('앱으로 돌아왔습니다. 최신 데이터를 확인합니다.');
      _fetchDashboardData(); // 돌아왔을 때 즉시 갱신
    }
  }

  // 백엔드 API 호출
  Future<void> _fetchDashboardData() async {
    final userId = widget.userId; // 생성자에서 받은 ID 사용
    final url = Uri.parse('http://49.50.137.47:8082/home/$userId');

    try {
      final response = await http.get(url);

      if(response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);

        if(mounted) {
          setState(() {
            _dashboardData = DashboardData.fromJson(jsonMap);
            _isDataLoading = false; // 로딩 끝
          });
        }
        print("데이터 로딩 성공 : ${_dashboardData?.userName}, 날씨 : ${_dashboardData?.weatherData?.weatherIcon}");
      } else {
        print("데이터 로딩 실패 : ${response.statusCode}");
        if(mounted) setState(() => _isDataLoading = false);
      }
    } catch (e) {
      print("API 에러 : $e");
      if(mounted) setState(() => _isDataLoading = false);
    }
  }

  // 디바이스 목록
  final List<Device> devices = allDevices;
  late final PowerManagement _powerPage;  // 전력 탭 페이지 캐싱

  // JS handleDeviceStatusChange 대응
  void _handleDeviceStatusChange(String deviceId, bool isOn) {
    setState(() {
      for (final d in devices) {
        if (d.id == deviceId) {
          String newStatus = d.status;
          String? newDetail = d.detail;

          if (deviceId == '1') {
            // WashingMachine
            newStatus = isOn ? 'Running' : 'Off';
            newDetail = isOn ? '35 min left' : null;
          } else if (deviceId == '2') {
            // Dryer (ESP32 연동 없음)
            newStatus = isOn ? 'Drying' : 'Off';
            newDetail = isOn ? '20 min left' : null;
          } else if (deviceId == '3') {
            // Refrigerator
            newStatus = isOn ? '34°F' : 'Off';
          } else if (deviceId == '4') {
            // Air Conditioner
            newStatus = isOn ? '24°C' : 'Off';
          }

          d.status = newStatus;
          d.detail = newDetail;
          d.active = isOn;

          if (selectedDevice?.id == d.id) {
            selectedDevice!
              ..status = newStatus
              ..detail = newDetail
              ..active = isOn;
          }
        }
      }
    });

    // 🔥 하드웨어 쪽 LCD/LED 업데이트
    if (isOn) {
      if (deviceId == '1') {
        // 세탁기 전원 ON → "Wash Contact" + 흰색 LED
        Esp32Api.washerPowerOn();
      } else if (deviceId == '3') {
        // 냉장고 전원 ON → "Fridge Contact" + 흰색 LED
        Esp32Api.fridgePowerOn();
      } else if (deviceId == '4') {
        // 에어컨 전원 ON → "AC Contact" + 흰색 LED
        Esp32Api.acPowerOn();
      }
    } else {
      // 전원 OFF일 때 -> 각 가전별 OFF처리 ("LG Regen")
      if (deviceId == '1') {
        Esp32Api.washerPowerOff();
      } else if (deviceId == '3') {
        Esp32Api.fridgePowerOff();
      } else if (deviceId == '4') {
        Esp32Api.acPowerOff();
      }
    }


    // ⚡ 전력 사용량 매니저에도 ON/OFF 반영 (❗ 2개 인자만)
    try {
      PowerUsageManager.instance.setDevicePower(deviceId, isOn);
    } catch (e) {
      debugPrint('setDevicePower 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // bg-gray-100
      body: SafeArea(
        child: Column(
          children: [
            // 라마단 배너
            if (ramadanEcoMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFACC15),
                      Color(0xFFF97316),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('⚡ ', style: TextStyle(fontSize: 20)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ramadan Eco Mode Activated',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'All appliances are running in energy-saving mode',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Center(
                child: SizedBox(
                  width: 390, // 모바일 기준 폭
                  child: _buildByActiveTab(),
                ),
              ),
            ),

            BottomNav(
              activeTab: activeTab,
              onTabChange: (t) {
                setState(() => activeTab = t);
              },
            ),
          ],
        ),
      ),
    );
  }

  // activeTab 에 따라 다른 화면
  Widget _buildByActiveTab() {
    if (activeTab == 'power') {
      return _powerPage;
    } else if (activeTab == 'status') {
      return ConsumablesOverviewScreen(devices: devices);
    } else if (activeTab == 'my') {
      // CardMode 안에서 보여주는 MyPage
      return MyPage(
        isLoggedIn: widget.isLoggedIn,
        userName: widget.userName,
        membership: widget.membership,
        qReward: widget.qReward,
        onTapLogin: () {
          // CardMode 안에서는 로그인 누르면
          // 그냥 홈(UiHome)으로 나가서 거기서 로그인하게 할 수 있음
          Navigator.pop(context);
        },
        onTapSignup: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입은 홈에서 진행해 주세요.')),
          );
        },
        onTapLogout: () {
          // 🔥 실제 로그아웃 동작
          widget.onLogout(); // UiHome 쪽 상태 초기화
          Navigator.pop(context); // CardMode 닫고 UiHome 으로 복귀
        },
      );
    }

    // 나머지 home 탭
    return _buildCardModeHome();
  }

  Widget _buildCardModeHome() {
    // home 탭
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context),
                _buildGreetingCard(),
                _buildDeviceGrid(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 헤더: 뒤로가기 + 로고 + 종
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back + 로고
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/Lg_logo.png', // newLgSeaLogo2 대신
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Regen',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bell 버튼
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {
                // 기존: setState(() => showNotifications = true); _showSimpleDialog(...)
                showNotificationLayer(context);
              },
            ),
          ),
        ],
      ),
    );
  }

// 인사 + Prayer Schedule + 날씨 카드
  Widget _buildGreetingCard() {

    // 데이터가 있으면 사용, 에러인 경우 기존 widget.userName 사용
    final data = _dashboardData;
    final weather = data?.weatherData;

    final displayName = data?.userName ?? widget.userName;
    final regionName = data?.region ?? 'Location';
    final tempStr = weather?.temperature.toStringAsFixed(1) ?? ' ';
    final humiStr = weather?.humidity.toStringAsFixed(0) ?? ' ';
    final iconStr = weather?.weatherIcon ?? '☀️'; // 백엔드에서 온 이모지

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF7EE),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 텍스트
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dear $displayName', // 예) team3님
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Assalamu alaikum',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Prayer 버튼
                TextButton(
                  onPressed: () {
                    showPrayerScheduleSheet(
                      context,
                      initialRamadanEcoMode: ramadanEcoMode,
                      onRamadanModeChange: (enabled) {
                        setState(() {
                          ramadanEcoMode = enabled;
                        });
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.nightlight_round,
                          size: 18, color: Color(0xFFA5D6A7)),
                      SizedBox(height: 2),
                      Text(
                        'Prayer\nSchedule',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF66BB6A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 날씨 Row (백엔드 데이터 연결)
            Row(
              children: [
                Text(iconStr, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  _isDataLoading
                  ? 'Loading weather information...'
                  : '$regionName, $tempStr°C · Humidity $humiStr%',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 디바이스 카드 그리드
  Widget _buildDeviceGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final device = devices[index];
              return GestureDetector(
                onTap: () {
                  setState(() => selectedDevice = device);
                  _openDeviceSheet(device);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF7EE),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: device.active
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // active indicator & ramadan badge
                      Row(
                        children: [
                          if (device.active)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          const Spacer(),
                          if (ramadanEcoMode)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFACC15),
                                    Color(0xFFF97316),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Text('⚡',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 2),
                                  Text(
                                    '절전',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: device.iconImage != null
                              ? Image.asset(
                            device.iconImage!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          )
                              : Text(
                            device.iconEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: device.active
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (device.detail != null)
                        Text(
                          device.detail!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 가전 추가 버튼
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () {
              _showSimpleDialog('Add Appliance', 'You can implement the logic to add a new appliance here.');
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Add Appliance',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(300, 52),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              backgroundColor: const Color(0xFFF9FAFB),
              side: const BorderSide(color: Color(0xFF9CA3AF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 간단 알림/기도창 다이얼로그
  void _showSimpleDialog(
      String title,
      String message, {
        List<Widget>? extraActions,
      }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (extraActions != null) ...extraActions,
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // WashingMachineLayer / DryerLayer ... 자리에 들어갈 bottom sheet
  void _openDeviceSheet(Device device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        // id나 name 기준으로 어떤 dialog를 띄울지 결정
        if (device.id == '1' || device.name == 'WashingMachine') {
          return WashingMachineSheet(
            device: device,
            initialOn: device.active,
            onPowerChanged: (isOn) {
              _handleDeviceStatusChange(device.id, isOn);
            },
          );
        } else if (device.id == '2' || device.name == 'Dryer') {
          return DryerSheet(
            device: device,
            initialOn: device.active,
            onPowerChanged: (isOn) {
              _handleDeviceStatusChange(device.id, isOn);
            },
          );
        } else if (device.id == '3' || device.name == 'Refrigerator') {
          return RefrigeratorSheet(
            device: device,
            initialOn: device.active,
            onPowerChanged: (isOn) {
              _handleDeviceStatusChange(device.id, isOn);
            },
          );
        } else if (device.id == '4' || device.name == 'Air Conditioner') {
          return AirConditionerSheet(
            device: device,
            initialOn: device.active,
            onPowerChanged: (isOn) {
              _handleDeviceStatusChange(device.id, isOn);
            },
          );
        }

        // 혹시 모를 기본 fallback (간단 sheet)
        return WashingMachineSheet(
          device: device,
          initialOn: device.active,
          onPowerChanged: (isOn) {
            _handleDeviceStatusChange(device.id, isOn);
          },
        );
      },
    );
  }
}


class BottomNav extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChange;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            icon: Icons.home_outlined,
            label: "Home",
            tabId: 'home',
          ),
          _buildItem(
            icon: Icons.bolt_outlined,
            label: "Power",
            tabId: 'power',
          ),
          _buildItem(
            icon: Icons.info_outline,
            label: "Status",
            tabId: 'status',
          ),
          _buildItem(
            icon: Icons.person_outline,
            label: "My Page",
            tabId: 'my',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required String tabId,
  }) {
    final bool selected = activeTab == tabId;

    return GestureDetector(
      onTap: () => onTabChange(tabId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? Colors.green : Colors.black38,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.green : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

