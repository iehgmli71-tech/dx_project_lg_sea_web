import 'package:flutter/material.dart';

typedef RamadanModeChanged = void Function(bool enabled);

Future<void> showPrayerScheduleBottomSheet(
    BuildContext context, {
      RamadanModeChanged? onRamadanModeChange,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PrayerScheduleSheet(
      onRamadanModeChange: onRamadanModeChange,
    ),
  );
}

class _PrayerScheduleSheet extends StatefulWidget {
  final RamadanModeChanged? onRamadanModeChange;

  const _PrayerScheduleSheet({
    Key? key,
    this.onRamadanModeChange,
  }) : super(key: key);

  @override
  State<_PrayerScheduleSheet> createState() => _PrayerScheduleSheetState();
}

class _PrayerScheduleSheetState extends State<_PrayerScheduleSheet> {
  bool washerDryerDelay = false;
  bool fridgeDoorAlert = false;
  bool ramadanEcoMode = false;
  DateTimeRange? ramadanRange;

  // Quiet Home Mode: 두 토글를 같이 ON/OFF
  void _handleQuietModeActivate() {
    if (washerDryerDelay && fridgeDoorAlert) {
      setState(() {
        washerDryerDelay = false;
        fridgeDoorAlert = false;
      });
    } else {
      setState(() {
        washerDryerDelay = true;
        fridgeDoorAlert = true;
      });
    }
  }

  Future<void> _handleRamadanToggle() async {
    if (!ramadanEcoMode) {
      // 날짜 범위 선택 (라마단 기간)
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: now,
        lastDate: DateTime(2026, 4, 30),
        helpText: '라마단 기간을 선택하세요',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.green,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          ramadanEcoMode = true;
          washerDryerDelay = true;
          fridgeDoorAlert = true;
          ramadanRange = picked;
        });
        widget.onRamadanModeChange?.call(true);
      }
    } else {
      setState(() {
        ramadanEcoMode = false;
        ramadanRange = null;
      });
      widget.onRamadanModeChange?.call(false);
    }
  }

  String _formatRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    String fmt(DateTime d) =>
        '${d.year}년 ${d.month}월 ${d.day}일';
    return '${fmt(start)} ~ ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final canApply =
        washerDryerDelay || fridgeDoorAlert || ramadanEcoMode;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
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
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─ Header ─
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '🕌',
                                  style: TextStyle(fontSize: 26),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Prayer Schedule',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '조용한 시간 설정',
                                    style: TextStyle(
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

                      // ─ Quiet Home Mode 카드 ─
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: _handleQuietModeActivate,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.nights_stay,
                                    color: Colors.green, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Quiet Home Mode 시행할까요?',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '기도 시간 동안 모든 알림을 최소화합니다',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─ 세탁기/건조기 알림 ─
                      _toggleCard(
                        icon: Icons.local_laundry_service,
                        title: '세탁기/건조기 완료 알림 지연',
                        subtitle: '소리 없이 앱 알림만',
                        value: washerDryerDelay,
                        onChanged: (v) =>
                            setState(() => washerDryerDelay = v),
                      ),
                      const SizedBox(height: 8),

                      // ─ 냉장고 문 열림 알림 ─
                      _toggleCard(
                        icon: Icons.kitchen,
                        title: '냉장고 문 열림 알림 최소화',
                        subtitle: '소리 없이 앱 알림만',
                        value: fridgeDoorAlert,
                        onChanged: (v) =>
                            setState(() => fridgeDoorAlert = v),
                      ),
                      const SizedBox(height: 8),

                      // ─ 라마단 절전 모드 ─
                      _ramadanCard(),

                      const SizedBox(height: 24),

                      // 적용 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canApply
                              ? () => Navigator.pop(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canApply
                                ? Colors.green
                                : Colors.grey.shade300,
                            foregroundColor:
                            canApply ? Colors.white : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: canApply ? 4 : 0,
                          ),
                          child: const Text('적용'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          )
        ],
      ),
    );
  }

  Widget _ramadanCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
            Icon(Icons.bolt, size: 22, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('라마단 절전모드',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                const Text(
                  '야간 전력 사용 최적화, 불필요한 가전 대기전력 차단',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (ramadanEcoMode && ramadanRange != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '📅 ${_formatRange(ramadanRange!)}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.green),
                  )
                ]
              ],
            ),
          ),
          Switch(
            value: ramadanEcoMode,
            onChanged: (_) => _handleRamadanToggle(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
