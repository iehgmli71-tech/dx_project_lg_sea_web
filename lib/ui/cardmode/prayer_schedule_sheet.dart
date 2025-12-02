import 'package:flutter/material.dart';

/// 카드모드에서 호출해서 쓰는 헬퍼 함수
Future<void> showPrayerScheduleSheet(
    BuildContext context, {
      required bool initialRamadanEcoMode,
      required ValueChanged<bool> onRamadanModeChange,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.85, // 85vh 느낌
        child: _PrayerScheduleSheet(
          initialRamadanEcoMode: initialRamadanEcoMode,
          onRamadanModeChange: onRamadanModeChange,
        ),
      );
    },
  );
}

/// 각 달에 대한 캘린더 데이터
class _MonthData {
  final int year;
  final int month; // 1~12
  final String monthName;
  final List<DateTime?> days;

  _MonthData({
    required this.year,
    required this.month,
    required this.monthName,
    required this.days,
  });
}

/// 실제 바텀시트 위젯
class _PrayerScheduleSheet extends StatefulWidget {
  final bool initialRamadanEcoMode;
  final ValueChanged<bool> onRamadanModeChange;

  const _PrayerScheduleSheet({
    super.key,
    required this.initialRamadanEcoMode,
    required this.onRamadanModeChange,
  });

  @override
  State<_PrayerScheduleSheet> createState() => _PrayerScheduleSheetState();
}

class _PrayerScheduleSheetState extends State<_PrayerScheduleSheet> {
  bool washerDryerDelay = false;
  bool fridgeDoorAlert = false;
  bool ramadanEcoMode = false;

  bool showCalendar = false;
  bool selectingStartDate = true;
  DateTime? startDate;
  DateTime? endDate;

  late final List<_MonthData> calendarMonths;

  @override
  void initState() {
    super.initState();
    calendarMonths = _generateCalendar();
    ramadanEcoMode = widget.initialRamadanEcoMode;
  }

  /// React 코드와 동일한 로직: 오늘~2026.04.30까지 캘린더 생성
  List<_MonthData> _generateCalendar() {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(2026, 4, 30);

    final List<_MonthData> months = [];
    DateTime current = DateTime(today.year, today.month, 1);

    while (!current.isAfter(lastDate)) {
      final year = current.year;
      final month = current.month;
      final firstDay = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0);
      final daysInMonth = lastDayOfMonth.day;

      // Dart weekday: Mon=1 ... Sun=7 → Sun을 0으로 맞추기
      final startingDayOfWeek = firstDay.weekday % 7;

      final List<DateTime?> days = [];

      // 앞쪽 빈칸
      for (int i = 0; i < startingDayOfWeek; i++) {
        days.add(null);
      }

      // 날짜 채우기
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(year, month, d);
        if (date.isBefore(todayMidnight)) {
          days.add(null);
        } else {
          days.add(date);
        }
      }

      months.add(
        _MonthData(
          year: year,
          month: month,
          monthName: '${year}년 ${month}월',
          days: days,
        ),
      );

      current = DateTime(year, month + 1, 1);
    }

    return months;
  }

  void _handleQuietModeActivate() {
    // 둘 다 켜져 있으면 둘 다 끄고, 아니면 둘 다 켬
    setState(() {
      if (washerDryerDelay && fridgeDoorAlert) {
        washerDryerDelay = false;
        fridgeDoorAlert = false;
      } else {
        washerDryerDelay = true;
        fridgeDoorAlert = true;
      }
    });
  }

  void _handleRamadanToggle() {
    setState(() {
      if (!ramadanEcoMode) {
        // 켜려는 시점 → 달력 시트 오픈
        showCalendar = true;
        selectingStartDate = true;
        startDate = null;
        endDate = null;
      } else {
        // 끌 때 초기화
        ramadanEcoMode = false;
        startDate = null;
        endDate = null;
        widget.onRamadanModeChange(false);  // 🔥 CardMode에 false 전달
      }
    });
  }

  void _handleDateSelect(DateTime date) {
    setState(() {
      if (selectingStartDate) {
        startDate = date;
        endDate = null;
        selectingStartDate = false;
      } else {
        if (startDate != null &&
            date.isBefore(DateTime(
              startDate!.year,
              startDate!.month,
              startDate!.day,
            ))) {
          // 종료일이 시작일보다 앞이면 다시 시작일로 사용
          startDate = date;
          endDate = null;
          selectingStartDate = false;
        } else {
          endDate = date;
        }
      }
    });
  }

  void _handleCalendarConfirm() {
    if (startDate != null && endDate != null) {
      setState(() {
        ramadanEcoMode = true;
        washerDryerDelay = true;
        fridgeDoorAlert = true;
        showCalendar = false;
        selectingStartDate = true;
      });
      // 🔥 CardMode 상태 갱신
      widget.onRamadanModeChange(true);

      // 시트 닫고 싶으면 여기서 pop
      Navigator.of(context).pop();

    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 메인 시트 내용
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // 상단 핸들
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: const Center(
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
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '조용한 시간 설정',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quiet Home Mode 카드
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _handleQuietModeActivate,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.nightlight_round,
                                          color: Color(0xFF16A34A)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Quiet Home Mode 시행할까요?',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.only(left: 26),
                                    child: Text(
                                      '기도 시간 동안 모든 알림을 최소화합니다',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 토글들
                        Column(
                          children: [
                            _toggleTile(
                              icon: Icons.local_laundry_service_outlined,
                              title: '세탁기/건조기 완료 알림 지연',
                              subtitle: '소리 없이 앱 알림만',
                              value: washerDryerDelay,
                              onChanged: (v) {
                                setState(() {
                                  washerDryerDelay = v;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            _toggleTile(
                              icon: Icons.kitchen_outlined,
                              title: '냉장고 문 열림 알림 최소화',
                              subtitle: '소리 없이 앱 알림만',
                              value: fridgeDoorAlert,
                              onChanged: (v) {
                                setState(() {
                                  fridgeDoorAlert = v;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            _ramadanTile(),
                          ],
                        ),

                        // 적용 버튼
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation:
                              (washerDryerDelay || fridgeDoorAlert || ramadanEcoMode)
                                  ? 6
                                  : 0,
                              backgroundColor:
                              (washerDryerDelay || fridgeDoorAlert || ramadanEcoMode)
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFE5E7EB),
                              foregroundColor:
                              (washerDryerDelay || fridgeDoorAlert || ramadanEcoMode)
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: (washerDryerDelay ||
                                fridgeDoorAlert ||
                                ramadanEcoMode)
                                ? () => Navigator.of(context).pop()
                                : null,
                            child: const Text(
                              '적용',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 달력 오버레이
            if (showCalendar) _buildCalendarOverlay(context),
          ],
        ),
      ),
    );
  }

  /// 세탁기/냉장고용 일반 토글 타일
  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF374151)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          _buildSwitch(value, onChanged),
        ],
      ),
    );
  }

  /// 라마단 절전 모드 타일 (날짜 범위 표시)
  Widget _ramadanTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt_outlined, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '라마단 절전모드',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '야간 전력 사용 최적화, 불필요한 가전 대기전력 차단',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (ramadanEcoMode && startDate != null && endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '📅 ${_formatDate(startDate!)} ~ ${_formatDate(endDate!)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildSwitch(ramadanEcoMode, (_) => _handleRamadanToggle()),
        ],
      ),
    );
  }

  /// 토글 스위치 (Figma 스타일)
  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 달력 오버레이 (메인 시트 위에 덮어쓰기)
  Widget _buildCalendarOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showCalendar = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: GestureDetector(
            onTap: () {}, // 버블링 방지
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Prayer Schedule',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showCalendar = false;
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        selectingStartDate
                            ? '🗓️ 시작 날짜를 선택하세요'
                            : '🗓️ 종료 날짜를 선택하세요',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 요일 헤더
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: Row(
                        children: const [
                          _WeekdayLabel('일'),
                          _WeekdayLabel('월'),
                          _WeekdayLabel('화'),
                          _WeekdayLabel('수'),
                          _WeekdayLabel('목'),
                          _WeekdayLabel('금'),
                          _WeekdayLabel('토'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 월별 캘린더 리스트
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          itemCount: calendarMonths.length,
                          itemBuilder: (context, index) {
                            final month = calendarMonths[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                children: [
                                  Text(
                                    month.monthName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 4,
                                    ),
                                    itemCount: month.days.length,
                                    itemBuilder: (context, dayIndex) {
                                      final day = month.days[dayIndex];

                                      final bool isStart = day != null &&
                                          startDate != null &&
                                          _isSameDay(day, startDate!);
                                      final bool isEnd = day != null &&
                                          endDate != null &&
                                          _isSameDay(day, endDate!);
                                      final bool isInRange = day != null &&
                                          startDate != null &&
                                          endDate != null &&
                                          day.isAfter(startDate!) &&
                                          day.isBefore(endDate!);
                                      final bool isToday = day != null &&
                                          _isSameDay(
                                              day, DateTime.now());

                                      Color bgColor;
                                      Color textColor;
                                      BoxBorder? border;

                                      if (day == null) {
                                        bgColor =
                                        const Color(0xFFF3F4F6);
                                        textColor =
                                        const Color(0xFF9CA3AF);
                                      } else if (isStart || isEnd) {
                                        bgColor =
                                        const Color(0xFF22C55E);
                                        textColor = Colors.white;
                                      } else if (isInRange) {
                                        bgColor =
                                        const Color(0xFFDCFCE7);
                                        textColor =
                                        const Color(0xFF15803D);
                                        border = Border.all(
                                            color:
                                            const Color(0xFF4ADE80));
                                      } else {
                                        bgColor = Colors.white;
                                        textColor =
                                        const Color(0xFF111827);
                                      }

                                      return GestureDetector(
                                        onTap: day == null
                                            ? null
                                            : () => _handleDateSelect(day),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            border: border ??
                                                (isToday
                                                    ? Border.all(
                                                  color: const Color(
                                                      0xFF4ADE80),
                                                )
                                                    : null),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            day?.day.toString() ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 선택 정보 & 확인 버튼
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '시작',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    startDate != null
                                        ? _formatDate(startDate!)
                                        : '-',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const Text(
                                '→',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '종료',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    endDate != null
                                        ? _formatDate(endDate!)
                                        : '-',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (startDate != null &&
                                    endDate != null)
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFE5E7EB),
                                foregroundColor: (startDate != null &&
                                    endDate != null)
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: (startDate != null &&
                                  endDate != null)
                                  ? _handleCalendarConfirm
                                  : null,
                              child: const Text(
                                '라마단 절전모드 설정 완료',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
