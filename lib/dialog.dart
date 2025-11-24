import 'package:flutter/material.dart';

/// CardMode에서 쓰는 디바이스 모델
class Device {
  final String id;
  final String name;
  final IconData icon;
  final String status;
  final Color color;

  Device({
    required this.id,
    required this.name,
    required this.icon,
    required this.status,
    required this.color,
  });
}

enum DeviceType {
  washingMachine,
  dryer,
  refrigerator,
  airConditioner,
}

/// 🔥 카드 화면과 연동하기 위한 전원 상태 콜백
typedef PowerChanged = void Function(bool isOn);

Future<void> showDeviceControlBottomSheet(
    BuildContext context,
    Device device,
    DeviceType type, {
      required bool initialOn,
      PowerChanged? onPowerChanged,
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
          return RefrigeratorSheet(device: device);
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

// ────────────────────────────────────────────────────────────────
// 1. Washing Machine
// ────────────────────────────────────────────────────────────────

class WashingMachineSheet extends StatefulWidget {
  final Device device;
  final PowerChanged? onPowerChanged;
  final bool initialOn;

  const WashingMachineSheet({
    Key? key,
    required this.device,
    required this.initialOn,
    this.onPowerChanged,
  }) : super(key: key);


  @override
  State<WashingMachineSheet> createState() => _WashingMachineSheetState();
}

class _WashingMachineSheetState extends State<WashingMachineSheet> {
  late bool isOn;
  String selectedCourse = '표준';
  bool drumCleanAlert = true;
  bool showCleanAlert = false;
  bool showAutoSaveAlert = false;
  bool showPowerWashAlert = false;
  bool autoScheduleEnabled = false;
  @override
  void initState() {
    super.initState();
    isOn = widget.initialOn;          // 🔥 카드 상태로 초기화
  }

  final List<String> courses = ['표준', '청결', '강력', '절약', '울', '이불'];

  void _handleCourseSelect(String course) {
    if (course == '청결') {
      setState(() => showCleanAlert = true);
    } else if (course == '강력') {
      setState(() => showPowerWashAlert = true);
    } else {
      setState(() => selectedCourse = course);
    }
  }

  void _confirmClean() {
    setState(() {
      selectedCourse = '청결';
      showCleanAlert = false;
    });
  }

  void _confirmPowerWash(bool withDrumClean) {
    setState(() {
      selectedCourse = '강력';
      showPowerWashAlert = false;
      if (withDrumClean) {
        drumCleanAlert = true;
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
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.device.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.device.icon,
                        color: widget.device.color, size: 30),
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
                        isOn ? '작동 중 · $selectedCourse' : '꺼짐',
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
                // 🔥 카드 쪽으로 전원 상태 전달
                widget.onPowerChanged?.call(isOn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isOn ? Colors.blue : Colors.grey.shade200,
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
            // 세탁코스 원격제어
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
                      Icon(Icons.settings, color: Colors.blue, size: 18),
                      SizedBox(width: 6),
                      Text('세탁코스 원격제어'),
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
                    children: courses.map((c) {
                      final selected = selectedCourse == c;
                      return TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                          selected ? Colors.blue : Colors.white,
                          foregroundColor: selected
                              ? Colors.white
                              : Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: selected ? 2 : 0,
                        ),
                        onPressed: () => _handleCourseSelect(c),
                        child: Text(
                          c,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 청결 코스 알림
            if (showCleanAlert)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blue.shade300, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.water_drop, color: Colors.blue),
                        SizedBox(width: 6),
                        Text('청결 코스 안내'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '청결 1.5kg 이하 → 22L만 사용해도 충분합니다',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '시행할까요?',
                      style:
                      TextStyle(fontSize: 12, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => showCleanAlert = false),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmClean,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('시행하기'),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // 세탁조(통) 청소 알림
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFE0A3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      const Text('세탁조(통) 청소알림'),
                      const Spacer(),
                      Switch(
                        value: drumCleanAlert,
                        onChanged: (v) =>
                            setState(() => drumCleanAlert = v),
                        activeColor: Colors.orange,
                      )
                    ],
                  ),
                  if (drumCleanAlert)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '다음 세탁 후 세탁조 청소를 권장합니다',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF965A00)),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 강력 세탁 알림
            if (showPowerWashAlert)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.red.shade300, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.water_drop, color: Colors.red),
                        SizedBox(width: 6),
                        Text('강력 세탁 안내'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '하람 성분 제거 위해 강한세척을 시행합니다. 세탁 이후 통 세척도 진행할까요?',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmPowerWash(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('시행하기'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmPowerWash(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                            ),
                            child: const Text('세탁만시행'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // 에너지·물 사용 최적화
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F9EE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFB1E6C2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.water_drop, color: Colors.green),
                      SizedBox(width: 6),
                      Text('에너지·물 사용 최적화'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('절약 모드',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('약 30% 에너지 절감',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.green)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => showAutoSaveAlert = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '활성화',
                          style: TextStyle(fontSize: 13),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 자동 절약 알림
            if (showAutoSaveAlert)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.green.shade300, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.water_drop, color: Colors.green),
                        SizedBox(width: 6),
                        Text('자동 절약 안내'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '저녁 시간대에는 물, 전기 사용량 증가가 예상됩니다. 세탁을 22:00 이후로 자동 예약할까요?',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.green.shade200, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('22:00 이후 자동 예약',
                                  style: TextStyle(fontSize: 13)),
                              const Spacer(),
                              Switch(
                                value: autoScheduleEnabled,
                                activeColor: Colors.green,
                                onChanged: (v) => setState(
                                        () => autoScheduleEnabled = v),
                              )
                            ],
                          ),
                          if (autoScheduleEnabled)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '예상 절감: 전기 20%, 물 15%',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.green),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              showAutoSaveAlert = false;
                              autoScheduleEnabled = false;
                            }),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => showAutoSaveAlert = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('확인'),
                          ),
                        ),
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
                      color: widget.device.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.device.icon,
                        color: widget.device.color, size: 30),
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
                isOn ? Colors.orange : Colors.grey.shade200,
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
                      Icon(Icons.speed, color: Colors.orange, size: 18),
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
                          selected ? Colors.orange : Colors.white,
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
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 6),
                      const Text('타이머'),
                      const Spacer(),
                      Text('$timerMinutes분',
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 13)),
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

  const RefrigeratorSheet({Key? key, required this.device}) : super(key: key);

  @override
  State<RefrigeratorSheet> createState() => _RefrigeratorSheetState();
}

class _RefrigeratorSheetState extends State<RefrigeratorSheet> {
  int freezerTemp = -18;
  int fridgeTemp = 3;
  bool doorAlert = true;
  bool tempAlert = true;
  bool protectionMode = true;
  bool showHalalZone = false;
  bool iftarBoostMode = false;

  void _toggleIftarBoost() {
    setState(() {
      iftarBoostMode = !iftarBoostMode;
      fridgeTemp = iftarBoostMode ? 0 : 3;
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
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.device.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.device.icon,
                        color: widget.device.color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(widget.device.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('작동 중',
                          style:
                          TextStyle(fontSize: 13, color: Colors.grey),
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

          // 온도 관리 카드
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
                    Icon(Icons.thermostat, color: Colors.blue, size: 18),
                    SizedBox(width: 6),
                    Text('온도관리'),
                  ],
                ),
                const SizedBox(height: 12),

                // 냉동실
                _tempControlRow(
                  title: '냉동실',
                  valueLabel: '$freezerTemp°C',
                  min: -23,
                  max: -15,
                  value: freezerTemp,
                  onChanged: (v) =>
                      setState(() => freezerTemp = v.toInt()),
                ),
                const SizedBox(height: 16),

                // 냉장실
                _tempControlRow(
                  title: '냉장실',
                  valueLabel: '$fridgeTemp°C',
                  min: 1,
                  max: 7,
                  value: fridgeTemp,
                  onChanged: (v) =>
                      setState(() => fridgeTemp = v.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Iftar Boost Mode
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F9EE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFB1E6C2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.flight_takeoff,
                        color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text('Iftar Boost Mode'),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt,
                            color: Colors.green, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Iftar 전용 냉각 강화',
                                style: TextStyle(fontSize: 13)),
                            SizedBox(height: 3),
                            Text('Iftar 전용 냉각 강화 사용',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: iftarBoostMode,
                        activeColor: Colors.green,
                        onChanged: (_) => _toggleIftarBoost(),
                      )
                    ],
                  ),
                ),
                if (iftarBoostMode) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Iftar Boost Mode 활성화 · 현재 냉장실 온도: $fridgeTemp°C',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.green),
                      )
                    ],
                  )
                ]
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 알림 설정
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFE0A3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 6),
                    Text('알림 설정'),
                  ],
                ),
                const SizedBox(height: 12),
                _alertToggleRow(
                  icon: Icons.door_front_door,
                  label: '도어 열림 알림',
                  value: doorAlert,
                  onChanged: (v) =>
                      setState(() => doorAlert = v),
                ),
                const SizedBox(height: 8),
                _alertToggleRow(
                  icon: Icons.device_thermostat,
                  label: '온도 이상 알림',
                  value: tempAlert,
                  onChanged: (v) =>
                      setState(() => tempAlert = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Halal Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EDFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD5C5FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🕌', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    const Text('Halal Zone'),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          setState(() => showHalalZone = !showHalalZone),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(showHalalZone ? '닫기' : '설정하기',
                          style: const TextStyle(fontSize: 13)),
                    )
                  ],
                ),
                if (showHalalZone) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.purple.shade300, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Text('냉장고 보관 구역 안내',
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 10),
                        Container(
                          width: 120,
                          height: 170,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.grey, Colors.white],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.grey.shade500, width: 3),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 10,
                                left: 10,
                                right: 10,
                                height: 60,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.green.shade500,
                                        width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: const [
                                      Text('🕌', style: TextStyle(fontSize: 20)),
                                      SizedBox(height: 2),
                                      Text('Halal Zone',
                                          style:
                                          TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 83,
                                left: 10,
                                right: 10,
                                height: 1,
                                child: Container(color: Colors.grey[500]),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                height: 60,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.blue.shade500,
                                        width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: const [
                                      Text('🍽️', style: TextStyle(fontSize: 20)),
                                      SizedBox(height: 2),
                                      Text('General Zone',
                                          style:
                                          TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.green.shade400, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('상단칸 · 할랄 보관 구역',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 2),
                              Text('할랄 인증 식품 전용 보관 공간',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.blue.shade400, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('하단칸 · 비할랄 보관 추천 구역',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 2),
                              Text('일반 식품 보관 공간',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 전력 보호
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield, color: Colors.red, size: 18),
                    SizedBox(width: 6),
                    Text('전력 보호'),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt,
                            color: Colors.red, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('전력 불안정 → 냉장고 보호모드 자동 전환',
                                style: TextStyle(fontSize: 13)),
                            SizedBox(height: 4),
                            Text(
                                '전압 불안정 감지 시 자동으로 압축기를 보호하고 안전 모드로 전환합니다',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            SizedBox(height: 6),
                            Text('• 압축기 과부하 방지',
                                style: TextStyle(fontSize: 11)),
                            Text('• 전자부품 손상 예방',
                                style: TextStyle(fontSize: 11)),
                            Text('• 안정화 후 자동 복구',
                                style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      Switch(
                        value: protectionMode,
                        activeColor: Colors.red,
                        onChanged: (v) =>
                            setState(() => protectionMode = v),
                      )
                    ],
                  ),
                ),
                if (protectionMode) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '보호 모드 활성화 · 현재 전력 상태: 정상 (220V, 60Hz)',
                        style: TextStyle(
                            fontSize: 11, color: Colors.redAccent),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _tempControlRow({
    required String title,
    required String valueLabel,
    required double min,
    required double max,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey)),
            const Spacer(),
            Text(valueLabel,
                style: TextStyle(
                    fontSize: 13, color: Colors.blue.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _circleButton(
              icon: Icons.remove,
                onTap: () {
                  double newValue = (value - 1).clamp(min, max).toDouble();
                  onChanged(newValue);
                }),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                min: min,
                max: max,
                value: value.toDouble(),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            _circleButton(
              icon: Icons.add,
                onTap: () {
                  double newValue = (value + 1).clamp(min, max).toDouble();
                  onChanged(newValue);
                }),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toInt()}°C',
                style:
                const TextStyle(fontSize: 11, color: Colors.grey)),
            Text('${max.toInt()}°C',
                style:
                const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _alertToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
          )
        ],
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
      mode = '자동'; // 기본 모드에서 확장 모드로
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
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.device.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.device.icon,
                        color: widget.device.color, size: 30),
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
                        isOn ? '켜짐' : '꺼짐',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
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
                // 🔥 카드로 전달
                widget.onPowerChanged?.call(isOn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isOn ? Colors.blue : Colors.grey.shade200,
                foregroundColor: isOn ? Colors.white : Colors.grey.shade700,
                elevation: isOn ? 4 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.power_settings_new),
              label: Text(isOn ? '끄기' : '켜기'),
            ),
          ),
          const SizedBox(height: 16),

          if (isOn) ...[
            // 온도
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
                            color: Colors.blue, fontSize: 14),
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
                            temperature =
                                (temperature - 1).clamp(16, 30);
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
                            temperature =
                                (temperature + 1).clamp(16, 30);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 모드
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(showMoreModes ? '숨기기' : '더보기',
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Icon(
                          showMoreModes
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (showMoreModes) ...[
              // 종교 및 테마 모드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('🕌', style: TextStyle(fontSize: 18)),
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
                      childAspectRatio: 3.0,
                      children: [
                        'Prayer Mode',
                        'Ramadan (Sahur)',
                        'Ramadan (Iftar)',
                        'Wudhu Mode',
                      ].map((m) {
                        final selected = selectedSpecialMode == m;
                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: selected
                                ? Colors.purple
                                : Colors.white,
                            foregroundColor: selected
                                ? Colors.white
                                : Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
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
                    Row(
                      children: const [
                        Text('🌿', style: TextStyle(fontSize: 18)),
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
                      childAspectRatio: 3.0,
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
                                horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
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

            if (selectedSpecialMode != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3F2FD), Color(0xFFE0F7FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
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
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text('활성',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4칸 그리드
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3.0,
                      children: [
                        _modeInfoCard(
                          icon: '🌡️',
                          label: '온도',
                          value: specialModes[selectedSpecialMode]!['temp']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(Icons.water_drop,
                              size: 16, color: Colors.blue),
                          label: '습도',
                          value:
                          specialModes[selectedSpecialMode]!['humidity']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(Icons.air,
                              size: 16, color: Colors.cyan),
                          label: '풍량',
                          value: specialModes[selectedSpecialMode]!['fan']!,
                        ),
                        _modeInfoCard(
                          iconWidget: const Icon(Icons.timer,
                              size: 16, color: Colors.purple),
                          label: '타이머',
                          value:
                          specialModes[selectedSpecialMode]!['timer']!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('💡',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        const Text('목적:',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            specialModes[selectedSpecialMode]!['purpose']!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blue),
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
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
                color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
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
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconWidget != null)
                iconWidget
              else
                Text(icon ?? '',
                    style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }
}
