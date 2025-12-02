import 'package:flutter/material.dart';
import 'package:dx_projecet_lg_sea/models/device_models.dart';

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
      wash: '세탁 3회',
      washSub: null,
      rinse: '헹굼 2회',
      rinseSub: null,
      spin: '탈수 2회',
      spinSub: null,
      special: null,
    ),
    'Tahara Rinse': _WashCourseDetail(
      wash: '세탁 1회',
      washSub: null,
      rinse: '헹굼 3회',
      rinseSub: null,
      spin: '탈수 1회',
      spinSub: null,
      special: null,
    ),
    'Prayerwear': _WashCourseDetail(
      wash: '세탁 2회 (약하게)',
      washSub: null,
      rinse: '헹굼 3회',
      rinseSub: null,
      spin: '탈수 1회 (약하게)',
      spinSub: null,
      special: '기도복/얇은 천을 위한 저강도 코스입니다.',
    ),
    'Steam+': _WashCourseDetail(
      wash: '세탁 2회',
      washSub: null,
      rinse: '헹굼 2회',
      rinseSub: null,
      spin: '탈수 2회',
      spinSub: null,
      // 🔥 여기서 피그마의 "특수 기능" 블럭에 들어갈 내용
      special: '강력 스팀으로 세탁조에 청결함을 유지할 수 있습니다.',
    ),
    'Najis Wash': _WashCourseDetail(
      wash: '세탁 3회 (강하게)',
      washSub: null,
      rinse: '헹굼 4회 (강하게)',
      rinseSub: null,
      spin: '탈수 1회 (강하게)',
      spinSub: null,
      special: '불순 오염(Najis)에 대응하는 집중 세탁 코스입니다.',
    ),
  };

  String? selectedCourse;
  bool showConfirmPopup = false;
  String? pendingCourse;
  bool showAutoSaveAlert = false;
  bool autoScheduleEnabled = false;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
  }

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

  void _handleConfirmCourse() {
    if (pendingCourse != null) {
      setState(() {
        selectedCourse = pendingCourse;
        showConfirmPopup = false;
      });

      // 코스 시작 시 전원 ON 처리
      if (!isOn) {
        isOn = true;
        widget.onPowerChanged(true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$pendingCourse" 코스를 시작했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // 헤더 (아이콘/이름/전원스위치)
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF7EE),
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
                          isOn ? '전원 켜짐 · 원격 제어 사용 가능' : '전원 꺼짐 · 코스 시작 시 자동으로 켜집니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOn ? Colors.green.shade700 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOn,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() => isOn = val);
                      widget.onPowerChanged(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                          '세탁코스 원격제어',
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
                              '세탁 코스 시작',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pendingCourse ?? ''} 코스를 시작할까요?',
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
                                      '취소',
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
                                      '시작',
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
                          "에너지·물 사용 최적화",
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
                                "절약 모드",
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "약 30% 에너지 절감",
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
                          child: const Text("활성화"),
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
                              "자동 절약 안내",
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
                          "저녁 시간대에는 물, 전기 사용량 증가가 예상됩니다.\n"
                              "세탁을 22:00 이후로 자동 예약할까요?",
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
                              const Text("22:00 이후 자동 예약",
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
          ),
        ),
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
                        '특수 기능',
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
                  label: '세탁',
                  main: detail.wash,
                  sub: detail.washSub,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDetailBox(
                  icon: '💧',
                  label: '헹굼',
                  main: detail.rinse,
                  sub: detail.rinseSub,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDetailBox(
                  icon: '🔄',
                  label: '탈수',
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
  String dryLevel = '중간';
  bool ecoMode = false;
  int timerMinutes = 45;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
  }

  final List<String> dryLevels = ['약', '중간', '강'];


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
                        isOn ? '건조 중' : '꺼짐',
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
              label: Text(isOn ? '중지' : '시작'),
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
                      Text('건조정도'),
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
                        onPressed: () =>
                            setState(() => dryLevel = level),
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
                        Text('절약건조'),
                        SizedBox(height: 2),
                        Text('에너지 효율 모드',
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
                      const Text('타이머'),
                      const Spacer(),
                      Text('$timerMinutes분',
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
                      Text('15분',
                          style:
                          TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('120분',
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
  int fridgeTemp = 4;    // 1 ~ 7

  // Halal zone / Boost / 알림 / 보호모드
  bool showHalalZone = false;
  bool iftarBoostMode = false;
  bool doorAlert = true;
  bool tempAlert = true;
  bool protectionMode = true;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // 헤더 (아이콘/이름/전원)
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
                          isOn ? '전원 켜짐 · 온도 관리 가능' : '전원 꺼짐 · 설정만 미리 변경됩니다',
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

              // 온도관리 카드
              _buildTemperatureCard(),

              const SizedBox(height: 16),

              // Halal Kitchen Assistant
              _buildHalalKitchenAssistant(),

              const SizedBox(height: 16),

              // Boost Mode
              _buildBoostModeCard(),

              const SizedBox(height: 16),

              // 알림 설정
              _buildAlertSettingsCard(),

              const SizedBox(height: 16),

              // 전력 보호 모드
              _buildProtectionModeCard(),
            ],
          ),
        ),
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
                '온도관리',
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
            title: '냉동실',
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
            title: '냉장실',
            temp: fridgeTemp,
            tempColor: Colors.cyan.shade600,
            min: 1,
            max: 7,
            gradient: const LinearGradient(
              colors: [Color(0xFFA5F3FC), Color(0xFF06B6D4)],
            ),
            onChanged: (v) {
              setState(() => fridgeTemp = v);
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
                  showHalalZone ? '닫기' : '설정하기',
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
                    '냉장고 보관 구역 안내',
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
                              '상단 세 칸 - Halal Zone',
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
                            '✓ 할랄 인증 식품 전용 보관',
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
                            '할랄 인증을 받은 식품만 보관하여 교차 오염을 방지합니다',
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
                              '하단 한 칸 - General Zone',
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
                            '✓ 일반 식품 보관 구역',
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
                            '일반 식품 및 음료수 보관 공간',
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
                            '냉각 강화',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '냉각 강화 사용',
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
                      onChanged: (val) {
                        setState(() => iftarBoostMode = val);
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
                        'Iftar Boost Mode 활성화',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '현재 냉장실 온도: $fridgeTemp°C',
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
                '알림 설정',
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
                label: '도어 열림 알림',
                value: doorAlert,
                onChanged: (val) {
                  setState(() => doorAlert = val);
                },
              ),
              const SizedBox(height: 8),
              // 온도 이상 알림
              _buildAlertRow(
                icon: Icons.thermostat_outlined,
                label: '온도 이상 알림',
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
                '전력 보호',
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
                            '전력 불안정 → 냉장고 보호모드 자동 전환',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '전압 불안정 감지 시 자동으로 압축기를 보호하고 안전 모드로 전환합니다',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• 압축기 과부하 방지\n• 전자부품 손상 예방\n• 안정화 후 자동 복구',
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
                        '보호 모드 활성화',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '현재 전력 상태: 정상 (220V, 60Hz)',
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
  String mode = '자동';
  bool showMoreModes = false;
  String? selectedSpecialMode;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;
  }

  final Map<String, Map<String, String>> specialModes = {
    'Prayer Mode': {
      'temp': '25°C',
      'humidity': '55–60%',
      'fan': 'Low/Quiet',
      'timer': '20분 복귀',
      'purpose': '조용·간접풍·쾌적',
    },
    'Ramadan (Sahur)': {
      'temp': '26°C',
      'humidity': '60%',
      'fan': 'Low',
      'timer': '1시간',
      'purpose': '새벽 절전·조용',
    },
    'Ramadan (Iftar)': {
      'temp': '24°C',
      'humidity': '55%',
      'fan': 'Mid→Low',
      'timer': '60–90분',
      'purpose': '빠른 냉방',
    },
    'Wudhu Mode': {
      'temp': '26–27°C',
      'humidity': '50%',
      'fan': 'Mid',
      'timer': '15–20분',
      'purpose': '제습 우선',
    },
    'Hybrid': {
      'temp': '26°C',
      'humidity': '55%',
      'fan': 'Auto',
      'timer': '지속',
      'purpose': '습도 기반 절전',
    },
    'Eco Night': {
      'temp': '24→26°C',
      'humidity': '55–60%',
      'fan': 'Mid→Low',
      'timer': '6시간',
      'purpose': '수면·절전',
    },
  };

  void _selectSpecialMode(String name) {
    setState(() {
      selectedSpecialMode = name;
      mode = '자동';
      final tempText = specialModes[name]!['temp']!;
      final match = RegExp(r'(\d+)').firstMatch(tempText);
      if (match != null) {
        temperature = int.parse(match.group(1)!);
      }
    });
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
                        isOn ? '켜짐' : '꺼짐',
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
                backgroundColor: isOn ? Colors.blue : Colors.grey.shade200,
                foregroundColor: isOn ? Colors.white : Colors.grey.shade700,
                elevation: isOn ? 4 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.power_settings_new),
              label: Text(isOn ? '끄기' : '켜기'),
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
                      const Text('온도'),
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
                  const Text('모드'),
                  const SizedBox(height: 10),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.0,
                    children: ['자동', '냉방', '송풍'].map((m) {
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
                          showMoreModes ? '숨기기' : '더보기',
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
                        Text('종교 및 테마모드'),
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
                        Text('절전 및 기능 모드'),
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
                            '활성',
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
                          label: '온도',
                          value: specialModes[selectedSpecialMode]!['temp']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(
                            Icons.water_drop,
                            size: 12,
                            color: Colors.green,
                          ),
                          label: '습도',
                          value: specialModes[selectedSpecialMode]!['humidity']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(
                            Icons.air,
                            size: 12,
                            color: Colors.green,
                          ),
                          label: '풍량',
                          value: specialModes[selectedSpecialMode]!['fan']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.green,
                          ),
                          label: '타이머',
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
                          '목적:',
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
