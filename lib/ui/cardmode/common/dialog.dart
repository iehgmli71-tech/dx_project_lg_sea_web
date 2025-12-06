import 'package:flutter/material.dart';
import 'package:dx_projecet_lg_sea/models/device_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 🔥 ESP32 연동
import 'package:dx_projecet_lg_sea/services/esp32_api.dart';

/// CardMode에서 쓰는 디바이스 모델

enum DeviceType {
  washingMachine,
  dryer,
  refrigerator,
  airConditioner,
}


/// 🔥 카드 화면과 연동하기 위한 전원 상태 콜백
typedef PowerChanged = void Function(bool);

Future<void> showDeviceControlBottomSheet(
    BuildContext context,
    Device device,
    DeviceType type, {
      required bool initialOn,
      required PowerChanged onPowerChanged,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      switch (type) {
        case DeviceType.washingMachine:
          return WashingMachineSheet(
            device: device,
            initialOn: initialOn,
            onPowerChanged: onPowerChanged,
          );
        case DeviceType.dryer:
          return DryerSheet(
            device: device,
            initialOn: initialOn,
            onPowerChanged: onPowerChanged,
          );
        case DeviceType.refrigerator:
          return RefrigeratorSheet(
            device: device,
            initialOn: initialOn,
            onPowerChanged: onPowerChanged,
          );
        case DeviceType.airConditioner:
          return AirConditionerSheet(
            device: device,
            initialOn: initialOn,
            onPowerChanged: onPowerChanged,
          );
      }
    },
  );
}

/// 공통 BottomSheet 레이아웃
class _BaseBottomSheet extends StatelessWidget {
  final Widget child;

  const _BaseBottomSheet({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
Widget _deviceImage(Device device) {
  switch (device.name) {
    case 'WashingMachine':
      return Image.asset('images/WashingMachine.png');
    case 'Dryer':
      return Image.asset('images/DryerLayer.png');
    case 'Refrigerator':
      return Image.asset('images/Refrigerator.png');
    case 'Air Conditioner':
      return Image.asset('images/air_conditioner.png');
    default:
      return Text(device.iconEmoji, style: TextStyle(fontSize: 30));
  }
}
Color _deviceColor(Device device) {
  switch (device.name) {
    case 'WashingMachine':
      return Colors.blue;
    case 'Dryer':
      return Colors.orange;
    case 'Refrigerator':
      return Colors.green;
    case 'Air Conditioner':
      return Colors.lightBlue;
    default:
      return Colors.grey;
  }
}

// ────────────────────────────────────────────────────────────────
//  Washing Machine Bottom Sheet
// ────────────────────────────────────────────────────────────────

class WashingCourseDetail {
  final String wash;
  final String? washSub;
  final String rinse;
  final String? rinseSub;
  final String spin;
  final String? spinSub;
  final String? special;

  const WashingCourseDetail({
    required this.wash,
    this.washSub,
    required this.rinse,
    this.rinseSub,
    required this.spin,
    this.spinSub,
    this.special,
  });
}

class WashingMachineSheet extends StatefulWidget {
  final Device device;
  final bool initialOn;
  final ValueChanged<bool> onPowerChanged;

  const WashingMachineSheet({
    super.key,
    required this.device,
    required this.initialOn,
    required this.onPowerChanged,
  });

  @override
  State<WashingMachineSheet> createState() => _WashingMachineSheetState();
}

class _WashingMachineSheetState extends State<WashingMachineSheet> {
  bool isOn = false;
  String? selectedCourse;


  // 세탁 코스 리스트
  final List<String> courses = [
    'Standard',
    'Tahara Rinse',
    'Prayerwear',
    'Steam+',
    'Najis Wash',
  ];

  // 코스 상세 정보
  final Map<String, _WashCourseDetail> courseDetails = {
    'Standard': _WashCourseDetail(
      wash: 'Wash x3',
      washSub: null,
      rinse: 'Rinse x2',
      rinseSub: null,
      spin: 'Spin x2',
      spinSub: null,
      special: null,
    ),
    'Tahara Rinse': _WashCourseDetail(
      wash: 'Wash x1',
      washSub: null,
      rinse: 'Rinse x3',
      rinseSub: null,
      spin: 'Spin x1',
      spinSub: null,
      special: null,
    ),
    'Prayerwear': _WashCourseDetail(
      wash: 'Wash x2 \n(gentle)',
      washSub: null,
      rinse: 'Rinse x3',
      rinseSub: null,
      spin: 'Spin x1 \n(gentle)',
      spinSub: null,
      special: 'Low-intensity course for prayer clothes and thin garments.',
    ),
    'Steam+': _WashCourseDetail(
      wash: 'Wash x2',
      washSub: null,
      rinse: 'Rinse x2',
      rinseSub: null,
      spin: 'Spin x2',
      spinSub: null,
      // 🔥 여기서 피그마의 "특수 기능" 블럭에 들어갈 내용
      special: 'Keeps the drum hygienic with powerful steam.',
    ),
    'Najis Wash': _WashCourseDetail(
      wash: 'Wash x3 \n(strong)',
      washSub: null,
      rinse: 'Rinse x4 \n(strong)',
      rinseSub: null,
      spin: 'Spin x1  \n(strong)',
      spinSub: null,
      special: 'Intensive course for Najis contamination.',
    ),
  };


  bool showConfirmPopup = false;
  String? pendingCourse;
  bool showAutoSaveAlert = false;
  bool autoScheduleEnabled = false;

  @override
  void initState() {
    super.initState();
    _initFromPrefs();
  }

  Future<void> _initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPower  = prefs.getBool(_powerKey) ?? false;
    final savedCourse = prefs.getString(_courseKey);

    if (!mounted) return;

    setState(() {
      isOn = savedPower;                // 🔌 전원 먼저 복원
      selectedCourse = isOn ? savedCourse : null; // 전원이 켜져 있을 때만 코스 복원
    });
  }
  /// 기기별로 고유 저장 키 (여러 세탁기 사용 대비)
  String get _courseKey => 'washing_course_${widget.device.id}';

  /// 🔧 SharedPreferences에서 선택된 코스 로드
  Future<void> _loadSelectedCourse() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // ✅ 전원이 켜져 있을 때만 저장된 코스 복원
      selectedCourse = isOn ? selectedCourse : null;
    });
  }

  /// 🔧 선택된 코스 저장
  Future<void> _saveSelectedCourse() async {
    final prefs = await SharedPreferences.getInstance();

    if (selectedCourse != null) {
      await prefs.setString(_courseKey, selectedCourse!);
    } else {
      await prefs.remove(_courseKey);
    }
  }

  static const _powerKey  = 'washing_power_state';


  void _handleCourseSelect(String course) {
    setState(() {
      pendingCourse = course;
      showConfirmPopup = true;
    });
  }

  void _handleCancelCourse() {
    setState(() {
      showConfirmPopup = false;
      pendingCourse = null;
    });
  }

  Future<void> _handleConfirmCourse() async {
    if (pendingCourse != null) {
      final String courseName = pendingCourse!;

      setState(() {
        selectedCourse = courseName;
        showConfirmPopup = false;
      });

      await _saveSelectedCourse();

      // 코스 시작 시 전원 ON 처리
      if (!isOn) {
        isOn = true;
        widget.onPowerChanged(true);
        await _savePowerState();
      }

      // 🔥 Tahara Rinse일 때 ESP32에 LCD/LED 명령
      if (courseName == 'Tahara Rinse') {
        await Esp32Api.showWasherTaharaRinse();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$courseName" course started.'),
        ),
      );
    }
  }

  Future<void> _savePowerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_powerKey, isOn);
  }


  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (아이콘/이름/상태 + 닫기 버튼)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF7EE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _deviceImage(widget.device),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOn
                          ? 'Power ON · Remote control available'
                          : 'Power OFF · Will turn on automatically when a course starts',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOn ? Colors.green.shade700 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 전원 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  isOn = !isOn;
                  // 전원 OFF 시 코스 초기화
                  if (!isOn) {
                    selectedCourse = null;
                  }
                });
                widget.onPowerChanged?.call(isOn);
                await _savePowerState();     // 전원 상태 저장
                await _saveSelectedCourse(); // 코스도 같이 저장/삭제
              },
              icon: const Icon(Icons.power_settings_new),
              label: Text(isOn ? 'Turn Off' : 'Turn On'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isOn ? Colors.green : Colors.grey.shade200,
                foregroundColor:
                isOn ? Colors.white : Colors.grey.shade700,
                elevation: isOn ? 4 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

            if (isOn) ...[

              // 🔥 세탁코스 원격제어 블럭 (Figma 코드 Flutter 버전)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB), // bg-gray-50 느낌
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀
                    Row(
                      children: const [
                        Icon(
                          Icons.settings,
                          size: 20,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Remote wash course control',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 코스 버튼 그리드
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final bool selected = selectedCourse == course;

                        return ElevatedButton(
                          onPressed: () => _handleCourseSelect(course),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            backgroundColor:
                            selected ? const Color(0xFF10B981) : Colors.white,
                            foregroundColor:
                            selected ? Colors.white : const Color(0xFF4B5563),
                            elevation: selected ? 3 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          child: Text(
                            course,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 코스 상세 정보 카드
                    if (selectedCourse != null &&
                        courseDetails[selectedCourse] != null)
                      _buildCourseDetailCard(courseDetails[selectedCourse]!),

                    // 인라인 코스 시작 확인 팝업
                    if (showConfirmPopup)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(34, 197, 94, 0.15),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD1FAE5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.settings,
                                  color: Color(0xFF16A34A),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Start wash course',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start the "$pendingCourse" course?',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _handleCancelCourse,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      backgroundColor:
                                      const Color(0xFFF3F4F6),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleConfirmCourse,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      backgroundColor:
                                      const Color(0xFF22C55E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      'Start',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // -----------------------------------------------------
              // 🔥 에너지·물 사용 최적화
              // -----------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFDF4), // green-50
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFBBF7D0)), // green-200
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "Energy & Water Optimization",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Eco mode",
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Save about 30% energy",
                                style: TextStyle(fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                        ),

                        // 🔥 활성화 버튼
                        ElevatedButton(
                          onPressed: () {
                            setState(() => showAutoSaveAlert = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Activate"),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // -----------------------------------------------------
              // 🔥 자동 절약 알림 팝업
              // -----------------------------------------------------
              if (showAutoSaveAlert)
                AnimatedScale(
                  scale: 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFDF4),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.green.shade300, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.water_drop, color: Colors.green, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Auto-saving suggestion",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "Evening usage of water and electricity is expected to increase."
                              "Would you like to schedule the wash after 22:00 automatically?",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),

                        // 🔥 스위치 카드
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Auto-schedule after 22:00",
                                  style: TextStyle(fontSize: 13)),

                              // 토글 스위치
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    autoScheduleEnabled = !autoScheduleEnabled;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: autoScheduleEnabled
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: autoScheduleEnabled
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 3)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
           ],
          ),
        );

  }

  Widget _buildCourseDetailCard(_WashCourseDetail detail) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 특수 기능
          if (detail.special != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special feature',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail.special!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 세탁 / 헹굼 / 탈수 3열
          Row(
            children: [
              Expanded(
                child: _buildDetailBox(
                  icon: '🌊',
                  label: 'Wash',
                  main: detail.wash,
                  sub: detail.washSub,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDetailBox(
                  icon: '💧',
                  label: 'Rinse',
                  main: detail.rinse,
                  sub: detail.rinseSub,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDetailBox(
                  icon: '🔄',
                  label: 'Spin',
                  main: detail.spin,
                  sub: detail.spinSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox({
    required String icon,
    required String label,
    required String main,
    String? sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            main,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (sub != null)
            Text(
              sub,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class _WashCourseDetail {
  final String wash;
  final String? washSub;
  final String rinse;
  final String? rinseSub;
  final String spin;
  final String? spinSub;
  final String? special;

  const _WashCourseDetail({
    required this.wash,
    this.washSub,
    required this.rinse,
    this.rinseSub,
    required this.spin,
    this.spinSub,
    this.special,
  });
}

// ────────────────────────────────────────────────────────────────
// 2. Dryer
// ────────────────────────────────────────────────────────────────

class DryerSheet extends StatefulWidget {
  final Device device;
  final bool initialOn;
  final PowerChanged? onPowerChanged;

  const DryerSheet({
    Key? key,
    required this.device,
    required this.initialOn,
    this.onPowerChanged,
  }) : super(key: key);

  @override
  State<DryerSheet> createState() => _DryerSheetState();
}

class _DryerSheetState extends State<DryerSheet> {
  late bool isOn;
  String dryLevel = 'Medium';
  bool ecoMode = false;
  int timerMinutes = 45;

  String? selectedCourse;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
    _loadSelectedCourse();
  }
  String get _courseKey => 'dryer_course_${widget.device.id}';

  Future<void> _loadSelectedCourse() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCourse = prefs.getString(_courseKey);
    });
  }

  Future<void> _saveSelectedCourse() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedCourse != null) {
      await prefs.setString(_courseKey, selectedCourse!);
    } else {
      await prefs.remove(_courseKey);
    }
  }

  final List<String> dryLevels = ['Low', 'Medium', 'High'];


  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _deviceColor(widget.device).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _deviceImage(widget.device),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.device.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        isOn ? 'Drying' : 'Off',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                splashRadius: 22,
              )
            ],
          ),
          const SizedBox(height: 16),

          // 전원 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => isOn = !isOn);
                // 🔥 카드에 전달
                widget.onPowerChanged?.call(isOn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isOn ? Colors.green : Colors.grey.shade200,
                foregroundColor: isOn ? Colors.white : Colors.grey.shade700,
                elevation: isOn ? 4 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.power_settings_new),
              label: Text(isOn ? 'Turn Off' : 'Turn On'),
            ),
          ),
          const SizedBox(height: 16),

          if (isOn) ...[
            // 건조 정도
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.speed, color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Text('Dryness level'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.8,
                    children: dryLevels.map((level) {
                      final selected = dryLevel == level;
                      return TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                          selected ? Colors.green : Colors.white,
                          foregroundColor: selected
                              ? Colors.white
                              : Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: selected ? 2 : 0,
                        ),
                        onPressed: () {
                          setState(() => dryLevel = level);
                          _saveSelectedCourse();      // 저장 위치
                        },
                        child: Text(level),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 절약 건조
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F9EE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFB1E6C2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.energy_savings_leaf,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Eco drying'),
                        SizedBox(height: 2),
                        Text('Energy saving mode',
                            style: TextStyle(
                                fontSize: 11, color: Colors.green)),
                      ],
                    ),
                  ),
                  Switch(
                    value: ecoMode,
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => ecoMode = v),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 타이머
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      const Text('Timer'),
                      const Spacer(),
                      Text('$timerMinutes min',
                          style: const TextStyle(
                              color: Colors.green, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _circleButton(
                        '-',
                        onTap: () {
                          setState(() {
                            timerMinutes =
                                (timerMinutes - 15).clamp(15, 120);
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            min: 15,
                            max: 120,
                            divisions: (120 - 15) ~/ 15,
                            value: timerMinutes.toDouble(),
                            onChanged: (v) =>
                                setState(() => timerMinutes = v.toInt()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _circleButton(
                        '+',
                        onTap: () {
                          setState(() {
                            timerMinutes =
                                (timerMinutes + 15).clamp(15, 120);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('15 min',
                          style:
                          TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('120 min',
                          style:
                          TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _circleButton(String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 3. Refrigerator
// ────────────────────────────────────────────────────────────────
class RefrigeratorSheet extends StatefulWidget {
  final Device device;
  final bool initialOn;
  final ValueChanged<bool> onPowerChanged;

  const RefrigeratorSheet({
    super.key,
    required this.device,
    required this.initialOn,
    required this.onPowerChanged,
  });

  @override
  State<RefrigeratorSheet> createState() => _RefrigeratorSheetState();
}

class _RefrigeratorSheetState extends State<RefrigeratorSheet> {
  bool isOn = false;

  // 온도 상태
  int freezerTemp = -18; // -23 ~ -15
  int fridgeBaseTemp = 4;      // 사용자가 설정한 기본 온도
  final int fridgeMin = 1;
  final int fridgeMax = 7;

  // Halal zone / Boost / 알림 / 보호모드
  bool showHalalZone = false;
  bool iftarBoostMode = false;
  bool doorAlert = true;
  bool tempAlert = true;
  bool protectionMode = true;

  int get fridgeDisplayTemp {
    if (!iftarBoostMode) return fridgeBaseTemp;

    // 예: Boost 모드일 때 2도 더 낮게
    final boosted = fridgeBaseTemp - 2;
    // 최소/최대 범위는 유지
    return boosted.clamp(fridgeMin, fridgeMax);
  }

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
    _loadBoostMode();
  }

  String get _boostKey => 'boost_mode_${widget.device.id}';

  Future<void> _loadBoostMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      iftarBoostMode = prefs.getBool(_boostKey) ?? false;
    });
  }

  Future<void> _saveBoostMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_boostKey, iftarBoostMode);
  }


  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (아이콘/이름/전원 상태 + 닫기)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _deviceImage(widget.device),
                ),
              ),
              const SizedBox(width: 12),
              // 이름 + 상태 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOn
                          ? 'Power ON · Remote control available'
                          : 'Power OFF · Will turn on automatically when a course starts',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOn ? Colors.blue.shade700 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 전원 버튼 (카드 스타일)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => isOn = !isOn);
                widget.onPowerChanged(isOn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isOn ? Colors.green : Colors.grey.shade200,
                foregroundColor:
                isOn ? Colors.white : Colors.grey.shade700,
                elevation: isOn ? 4 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.power_settings_new),
              label: Text(isOn ? 'Turn Off' : 'Turn On'),
            ),
          ),

          const SizedBox(height: 16),

          // 🔥 전원이 켜졌을 때만 대시보드 카드들 보이게
          if (isOn) ...[
            _buildTemperatureCard(),
            const SizedBox(height: 16),

            _buildHalalKitchenAssistant(),
            const SizedBox(height: 16),

            _buildBoostModeCard(),
            const SizedBox(height: 16),

            _buildAlertSettingsCard(),
            const SizedBox(height: 16),

            _buildProtectionModeCard(),
          ],
        ],
      ),
    );
  }

  // -------------------- 온도 관리 카드 --------------------
  Widget _buildTemperatureCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // bg-gray-50
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.thermostat, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Temperature control',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 냉동실 온도
          _buildTempControlRow(
            title: 'Freezer',
            temp: freezerTemp,
            tempColor: Colors.blue.shade600,
            min: -23,
            max: -15,
            gradient: const LinearGradient(
              colors: [Color(0xFF93C5FD), Color(0xFF2563EB)],
            ),
            onChanged: (v) {
              setState(() => freezerTemp = v);
            },
          ),
          const SizedBox(height: 20),

          // 냉장실 온도
          _buildTempControlRow(
            title: 'Fridge',
            temp: fridgeDisplayTemp,
            tempColor: Colors.cyan.shade600,
            min: fridgeMin,
            max: fridgeMax,
            gradient: const LinearGradient(
              colors: [Color(0xFFA5F3FC), Color(0xFF06B6D4)],
            ),
            onChanged: (value) {
                 setState(() {
            // 슬라이더는 "기본 온도"를 수정
            fridgeBaseTemp = value;
                });
               },
               ),
             ],
           ),
           );
         }

  Widget _buildTempControlRow({
    required String title,
    required int temp,
    required int min,
    required int max,
    required Color tempColor,
    required Gradient gradient,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
            Text(
              '$temp°C',
              style: TextStyle(
                fontSize: 14,
                color: tempColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // - 버튼
            _roundIconButton(
              icon: Icons.remove,
              onTap: () {
                if (temp > min) onChanged(temp - 1);
              },
            ),
            const SizedBox(width: 8),

            // 커스텀 슬라이더 (그래디언트 바 + 동그라미)
            Expanded(
              child: SizedBox(
                height: 24,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final ratio =
                        (temp - min) / (max - min); // 0 ~ 1 사이
                    final knobSize = 18.0;
                    final trackWidth =
                        constraints.maxWidth - knobSize; // 좌우 여백 보정
                    final dx = trackWidth * ratio;

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Positioned(
                          left: dx,
                          child: Container(
                            width: knobSize,
                            height: knobSize,
                            decoration: BoxDecoration(
                              color: tempColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // + 버튼
            _roundIconButton(
              icon: Icons.add,
              onTap: () {
                if (temp < max) onChanged(temp + 1);
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$min°C',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            Text(
              '$max°C',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF4B5563)),
      ),
    );
  }

  // -------------------- Halal Kitchen Assistant --------------------
  Widget _buildHalalKitchenAssistant() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3), // bg-yellow-50
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAB308)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.restaurant_menu,
                    size: 20,
                    color: Color(0xFFCA8A04),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Halal Kitchen Assistant',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() => showHalalZone = !showHalalZone);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  showHalalZone ? 'Close' : 'Set up',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          if (showHalalZone) const SizedBox(height: 16),

          if (showHalalZone)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAB308), width: 2),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Fridge storage guide',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 실제 냉장고 이미지 + 오버레이
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'images/Refrigerator_open.png', // <- 가지고 있는 이미지
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Halal Zone (상단 약 70%)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.of(context).size.height * 0.0,
                        child: FractionallySizedBox(
                          heightFactor: 0.7,
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFF22C55E).withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              border: Border.all(
                                color: const Color(0xFF22C55E),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Halal Zone',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // General Zone (하단 약 30%)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: 0.3,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                const Color(0xFFF97373).withOpacity(0.2),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(10),
                                ),
                                border: Border.all(
                                  color: const Color(0xFFEF4444),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'General Zone',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 상단 Halal Zone 설명
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Upper 3 shelve - Halal Zone',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            '✓ For halal-certified foods only',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Store only halal-certified foods here to avoid cross-contamination.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 하단 General Zone 설명
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFEF4444),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Bottom shelf - General Zone',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            '✓ General food storage area',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Space for regular food and drinks',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // -------------------- Boost Mode --------------------
  Widget _buildBoostModeCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Boost Mode',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cooling boost',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Use cooling boost',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildToggle(
                      value: iftarBoostMode,
                      activeColor: const Color(0xFF22C55E),
                      onChanged: (val) async {
                        setState(() => iftarBoostMode = val);
                        await _saveBoostMode();

                        if (val) {
                          // ✅ Boost Mode ON → 파란 LED + "Boost Mode Run"
                          await Esp32Api.showFridgeBoostMode();
                        } else {
                          // ✅ Boost Mode OFF → LED 끄기 / LCD 초기화 등
                          await Esp32Api.clearFridgeBoostMode(); // ← 실제 함수 이름에 맞게 수정
                        }
                      },
                    ),
                  ],
                ),
                if (iftarBoostMode) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFD1FAE5)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Iftar Boost Mode activated',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iftarBoostMode
                        ? 'Current fridge temperature: ${fridgeDisplayTemp}°C (base ${fridgeBaseTemp}°C → Boost applied)'
                        : 'Current fridge temperature: ${fridgeBaseTemp}°C',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- 알림 설정 --------------------
  Widget _buildAlertSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded,
                  size: 20, color: Color(0xFF16A34A)),
              SizedBox(width: 8),
              Text(
                'Alert settings',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              // 도어 열림 알림
              _buildAlertRow(
                icon: Icons.door_front_door_outlined,
                label: 'Door open alert',
                value: doorAlert,
                onChanged: (val) {
                  setState(() => doorAlert = val);
                },
              ),
              const SizedBox(height: 8),
              // 온도 이상 알림
              _buildAlertRow(
                icon: Icons.thermostat_outlined,
                label: 'Abnormal temperature alert',
                value: tempAlert,
                onChanged: (val) {
                  setState(() => tempAlert = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _buildToggle(
            value: value,
            activeColor: const Color(0xFF22C55E),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // -------------------- 전력 보호 모드 --------------------
  Widget _buildProtectionModeCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield, size: 20, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Power protection',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Unstable power → Auto switch to fridge protection mode',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'When voltage instability is detected, the compressor is protected and the fridge switches to safe mode automatically.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Prevents compressor overload\n• Protects electronic components\n• Automatically recovers after stabilization',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildToggle(
                      value: protectionMode,
                      activeColor: const Color(0xFFDC2626),
                      onChanged: (val) {
                        setState(() => protectionMode = val);
                      },
                    ),
                  ],
                ),
                if (protectionMode) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFFECACA)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Protection mode active',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Current power status: Normal (220V, 60Hz)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 공통 토글 스위치
  Widget _buildToggle({
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: value ? activeColor : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment:
          value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ────────────────────────────────────────────────────────────────
// 4. Air Conditioner
// ────────────────────────────────────────────────────────────────

class AirConditionerSheet extends StatefulWidget {
  final Device device;
  final bool initialOn;
  final PowerChanged? onPowerChanged;

  const AirConditionerSheet({
    Key? key,
    required this.device,
    required this.initialOn,
    this.onPowerChanged,
  }) : super(key: key);

  @override
  State<AirConditionerSheet> createState() => _AirConditionerSheetState();
}

class _AirConditionerSheetState extends State<AirConditionerSheet> {
  late bool isOn;
  int temperature = 24;
  String mode = 'Auto';
  bool showMoreModes = false;
  String? selectedSpecialMode;

  String get _acSpecialModeKey => 'ac_special_mode_${widget.device.id}';

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
    _loadSpecialMode();
  }
  Future<void> _loadSpecialMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSpecialMode = prefs.getString(_acSpecialModeKey);
    });
  }

  /// 선택된 특수 모드 저장
  Future<void> _saveSpecialMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedSpecialMode != null) {
      await prefs.setString(_acSpecialModeKey, selectedSpecialMode!);
    } else {
      await prefs.remove(_acSpecialModeKey);
    }
  }


  final Map<String, Map<String, String>> specialModes = {
    'Prayer Mode': {
      'temp': '25°C',
      'humidity': '55–60%',
      'fan': 'Low / Quiet',
      'timer': 'Return in 20 min',
      'purpose': 'Quiet · Indirect airflow · Comfort',
    },

    'Ramadan (Sahur)': {
      'temp': '26°C',
      'humidity': '60%',
      'fan': 'Low',
      'timer': '1-hour duration',
      'purpose': 'Dawn energy-saving · Quiet operation',
    },

    'Ramadan (Iftar)': {
      'temp': '24°C',
      'humidity': '55%',
      'fan': 'Mid → Low',
      'timer': '60–90 min',
      'purpose': 'Fast cooling',
    },

    'Wudhu Mode': {
      'temp': '26–27°C',
      'humidity': '50%',
      'fan': 'Mid',
      'timer': '15–20 min',
      'purpose': 'Dehumidification priority',
    },

    'Hybrid': {
      'temp': '26°C',
      'humidity': '55%',
      'fan': 'Auto',
      'timer': 'Continuous',
      'purpose': 'Humidity-based energy saving',
    },

    'Eco Night': {
      'temp': '24 → 26°C',
      'humidity': '55–60%',
      'fan': 'Mid → Low',
      'timer': '6 hours',
      'purpose': 'Sleep mode · Energy saving',
    },
  };

  Future<void> _selectSpecialMode(String name) async {
    bool turnedOnWudhu = false;
    bool turnedOffWudhu = false;

    setState(() {
      if (selectedSpecialMode == name) {
        // 🔻 같은 버튼 다시 눌렀다 = 선택 해제
        if (name == 'Wudhu Mode') {
          turnedOffWudhu = true;
        }
        selectedSpecialMode = null;
      } else {
        // 🔼 새 모드 선택
        selectedSpecialMode = name;
        mode = 'Auto';

        final tempText = specialModes[name]!['temp']!;
        final match = RegExp(r'(\d+)').firstMatch(tempText);
        if (match != null) {
          temperature = int.parse(match.group(1)!);
        }

        if (name == 'Wudhu Mode') {
          turnedOnWudhu = true;
        }
      }
    });

    await _saveSpecialMode();

    // ✅ Wudhu Mode 켰을 때
    if (turnedOnWudhu) {
      await Esp32Api.showAcWudhuMode();
    }

    // ✅ Wudhu Mode 껐을 때
    if (turnedOffWudhu) {
      await Esp32Api.clearAcWudhuMode(); // ← 실제 함수 이름에 맞게 수정
    }
  }



  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: _deviceColor(widget.device).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _deviceImage(widget.device),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.device.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOn ? 'On' : 'Off',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                splashRadius: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 전원 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => isOn = !isOn);
                widget.onPowerChanged?.call(isOn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isOn ? Colors.green : Colors.grey.shade200,
                foregroundColor: isOn ? Colors.white : Colors.grey.shade700,
                elevation: isOn ? 4 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.power_settings_new),
              label: Text(isOn ? 'Turn Off' : 'Turn On'),
            ),
          ),
          const SizedBox(height: 16),

          if (isOn) ...[
            // 온도 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Temperature'),
                      const Spacer(),
                      Text(
                        '$temperature°C',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _circleButton(
                        icon: Icons.remove,
                        onTap: () {
                          setState(() {
                            temperature = (temperature - 1).clamp(16, 30);
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          min: 16,
                          max: 30,
                          value: temperature.toDouble(),
                          onChanged: (v) =>
                              setState(() => temperature = v.toInt()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _circleButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            temperature = (temperature + 1).clamp(16, 30);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 기본 모드 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mode'),
                  const SizedBox(height: 10),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.0,
                    children: ['Auto', 'Cool', 'Fan'].map((m) {
                      final selected =
                          (mode == m) && selectedSpecialMode == null;
                      return TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                          selected ? Colors.blue : Colors.white,
                          foregroundColor: selected
                              ? Colors.white
                              : Colors.grey.shade700,
                          padding:
                          const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: selected ? 2 : 0,
                        ),
                        onPressed: () {
                          setState(() {
                            mode = m;
                            selectedSpecialMode = null;
                          });
                        },
                        child: Text(m),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        setState(() => showMoreModes = !showMoreModes),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          showMoreModes ? 'Hide' : 'More',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          showMoreModes
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 확장 모드들
            if (showMoreModes) ...[
              // 종교 및 테마 모드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        SizedBox(width: 6),
                        Text('Religious & themed modes'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.6,
                      children: [
                        'Prayer Mode',
                        'Ramadan (Sahur)',
                        'Ramadan (Iftar)',
                        'Wudhu Mode',
                      ].map((m) {
                        final selected = selectedSpecialMode == m;
                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                            selected ? Colors.amber : Colors.white,
                            foregroundColor: selected
                                ? Colors.white
                                : Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: selected ? 2 : 0,
                          ),
                          onPressed: () => _selectSpecialMode(m),
                          child: Text(
                            m,
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 절전 및 기능 모드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9EE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        SizedBox(width: 6),
                        Text('Eco & function modes'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.6,
                      children: [
                        'Hybrid',
                        'Eco Night',
                      ].map((m) {
                        final selected = selectedSpecialMode == m;
                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                            selected ? Colors.green : Colors.white,
                            foregroundColor: selected
                                ? Colors.white
                                : Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: selected ? 2 : 0,
                          ),
                          onPressed: () => _selectSpecialMode(m),
                          child: Text(
                            m,
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 선택된 스페셜 모드 상세
            if (selectedSpecialMode != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedSpecialMode!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 🔧 여기서 childAspectRatio 줄여서 높이 확보
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2, // ⬅️ 3.0 → 2.2 로 수정
                      children: [
                        _modeInfoCard(
                          icon: '🌡️',
                          label: 'Temperature',
                          value: specialModes[selectedSpecialMode]!['temp']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(
                            Icons.water_drop,
                            size: 12,
                            color: Colors.green,
                          ),
                          label: 'Humidity',
                          value: specialModes[selectedSpecialMode]!['humidity']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(
                            Icons.air,
                            size: 12,
                            color: Colors.green,
                          ),
                          label: 'Fan Speed',
                          value: specialModes[selectedSpecialMode]!['fan']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.green,
                          ),
                          label: 'Timer',
                          value: specialModes[selectedSpecialMode]!['timer']!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          '💡',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Purpose:',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            specialModes[selectedSpecialMode]!['purpose']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _modeInfoCard({
    String? icon,
    Widget? iconWidget,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔑 내용만큼만 차지
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconWidget != null)
                iconWidget
              else
                Text(
                  icon ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
