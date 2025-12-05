import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ESP32 연동
import 'package:dx_projecet_lg_sea/services/esp32_api.dart';

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
  bool washerDryerDelay = false; // Quiet Mode (세탁기)
  bool fridgeDoorAlert = false; // Quiet Mode (냉장고)
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
    _loadQuietModeSettings();
  }

  Future<void> _loadQuietModeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      washerDryerDelay = prefs.getBool('washerDryerDelay') ?? false;
      fridgeDoorAlert = prefs.getBool('fridgeDoorAlert') ?? false;
    });
  }

  Future<void> _saveQuietModeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('washerDryerDelay', washerDryerDelay);
    await prefs.setBool('fridgeDoorAlert', fridgeDoorAlert);
  }

  /// Quiet Home Mode 전체 스위치 눌렀을 때
  Future<void> _handleQuietModeMainToggle(bool value) async {
    setState(() {
      washerDryerDelay = value;
      fridgeDoorAlert = value;
    });

    await _saveQuietModeSettings();

    // 🔥 ESP32로 Quiet ON/OFF 명령 전송
    if (value) {
      await Esp32Api.showQuietHomeModeAll();
    } else {
      await Esp32Api.clearQuietHomeModeAll(
        washerConnected: true,
        fridgeConnected: true,
        acConnected: true,
      );
    }
  }

  /// Quiet 개별 토글(세탁기/냉장고)
  Future<void> _handleQuietIndividualToggle(
      bool value,
      bool isWasher,
      ) async {
    setState(() {
      if (isWasher) {
        washerDryerDelay = value;
      } else {
        fridgeDoorAlert = value;
      }
    });

    await _saveQuietModeSettings();
  }

  /// 오늘~2026.04.30까지 달력 생성
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

      final startingDayOfWeek = firstDay.weekday % 7;

      final List<DateTime?> days = [];

      for (int i = 0; i < startingDayOfWeek; i++) {
        days.add(null);
      }

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
          monthName: '$year년 $month월',
          days: days,
        ),
      );

      current = DateTime(year, month + 1, 1);
    }

    return months;
  }

  /// 라마단 토글
  Future<void> _handleRamadanToggle() async {
    if (!ramadanEcoMode) {
      // 🔼 라마단 모드 켤 때 → 날짜 선택 시트 오픈
      setState(() {
        showCalendar = true;
        selectingStartDate = true;
        startDate = null;
        endDate = null;
      });
    } else {
      // 🔽 라마단 모드 끌 때
      setState(() {
        ramadanEcoMode   = false;
        washerDryerDelay = false;   // Quiet 옵션도 같이 OFF
        fridgeDoorAlert  = false;
        startDate        = null;
        endDate          = null;
      });

      widget.onRamadanModeChange(false);
      await _saveQuietModeSettings();

      // ✅ 하드웨어에 "라마단/Quiet 해제" 명령 전송
      await Esp32Api.clearRamadanModeAll(
        washerConnected: true,
        fridgeConnected: true,
        acConnected: true,
      );
    }
  }

  void _handleDateSelect(DateTime date) {
    setState(() {
      if (selectingStartDate) {
        startDate = date;
        endDate = null;
        selectingStartDate = false;
      } else {
        if (startDate != null &&
            date.isBefore(
              DateTime(startDate!.year, startDate!.month, startDate!.day),
            )) {
          startDate = date;
          endDate = null;
          selectingStartDate = false;
        } else {
          endDate = date;
        }
      }
    });
  }

  /// 달력에서 "설정 완료"
  Future<void> _handleCalendarConfirm() async {
    if (startDate != null && endDate != null) {
      setState(() {
        ramadanEcoMode = true;
        washerDryerDelay = true;
        fridgeDoorAlert = true;
        showCalendar = false;
      });

      // ✅ 라마단 On일 때 Quiet 토글 상태를 디스크에 저장
      await _saveQuietModeSettings();

      widget.onRamadanModeChange(true);
      await Esp32Api.showRamadanModeAll();
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
            /// 메인 스크롤 영역
            SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ Quiet Home 카드 하나만 사용
                  _buildQuietHomeCard(),
                ],
              ),
            ),

            /// 달력 Overlay
            if (showCalendar) _buildCalendarOverlay(context),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// QUIET HOME MODE 카드 UI + 기능
  /// ===============================
  Widget _buildQuietHomeCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Quiet Home 타이틀 + 전체 스위치
              Row(
                children: [
                  const Icon(Icons.nightlight_round, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Quiet Home Mode 시행할까요?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildSwitch(
                    (washerDryerDelay && fridgeDoorAlert),
                        (value) => _handleQuietModeMainToggle(value),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 개별 Quiet 옵션
              _toggleTile(
                icon: Icons.local_laundry_service_outlined,
                title: '세탁기/건조기 완료 알림 지연',
                subtitle: '소리 없이 앱 알림만',
                value: washerDryerDelay,
                onChanged: (v) => _handleQuietIndividualToggle(v, true),
              ),
              const SizedBox(height: 12),

              _toggleTile(
                icon: Icons.kitchen_outlined,
                title: '냉장고 문 열림 알림 최소화',
                subtitle: '소리 없이 앱 알림만',
                value: fridgeDoorAlert,
                onChanged: (v) => _handleQuietIndividualToggle(v, false),
              ),

              const SizedBox(height: 12),

              _ramadanTile(),
            ],
          ),
        ),
      ],
    );
  }

  /// Quiet 개별 옵션 UI
  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                Text(
                  subtitle,
                  style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          /// ✅ 기본 Switch 제거, 커스텀 토글만 사용
          _buildSwitch(value, onChanged),
        ],
      ),
    );
  }

  /// 라마단 타일
  Widget _ramadanTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('라마단 절전모드', style: TextStyle(fontSize: 14)),
                const Text(
                  '야간 전력 사용 최적화',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (ramadanEcoMode && startDate != null && endDate != null)
                  Text(
                    '📅 ${_formatDate(startDate!)} ~ ${_formatDate(endDate!)}',
                    style:
                    const TextStyle(fontSize: 11, color: Colors.green),
                  ),
              ],
            ),
          ),
          _buildSwitch(ramadanEcoMode, (_) => _handleRamadanToggle()),
        ],
      ),
    );
  }

  /// 토글 스위치 (커스텀)
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
            ),
          ),
        ),
      ),
    );
  }

  /// ============= 달력 오버레이 =============
  Widget _buildCalendarOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => showCalendar = false),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: GestureDetector(
            onTap: () {}, // 흘러내림 차단
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
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prayer Schedule',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => showCalendar = false),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24),
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

                    const SizedBox(height: 12),

                    /// 요일
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24),
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

                    const SizedBox(height: 8),

                    /// 월별 리스트
                    Expanded(
                      child: ListView.builder(
                        itemCount: calendarMonths.length,
                        itemBuilder: (context, index) {
                          final month = calendarMonths[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Text(
                                  month.monthName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildMonthGrid(month),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    /// 설정 완료 버튼
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          24, 12, 24, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            (startDate != null && endDate != null)
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFE5E7EB),
                            foregroundColor:
                            (startDate != null && endDate != null)
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                          (startDate != null && endDate != null)
                              ? () async {
                            await _handleCalendarConfirm();
                          }
                              : null,
                          child: const Text(
                            '라마단 절전모드 설정 완료',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
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

  Widget _buildMonthGrid(_MonthData month) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: month.days.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final day = month.days[index];

        final bool isStart =
            day != null && startDate != null && _isSameDay(day, startDate!);
        final bool isEnd =
            day != null && endDate != null && _isSameDay(day, endDate!);
        final bool isInRange = day != null &&
            startDate != null &&
            endDate != null &&
            day.isAfter(startDate!) &&
            day.isBefore(endDate!);
        final bool isToday =
            day != null && _isSameDay(day, DateTime.now());

        Color bgColor;
        Color textColor = const Color(0xFF111827);
        BoxBorder? border;

        if (day == null) {
          bgColor = const Color(0xFFF3F4F6);
          textColor = const Color(0xFF9CA3AF);
        } else if (isStart || isEnd) {
          bgColor = const Color(0xFF22C55E);
          textColor = Colors.white;
        } else if (isInRange) {
          bgColor = const Color(0xFFDCFCE7);
          textColor = const Color(0xFF15803D);
          border =
              Border.all(color: const Color(0xFF4ADE80));
        } else {
          bgColor = Colors.white;
          if (isToday) {
            border =
                Border.all(color: const Color(0xFF4ADE80));
          }
        }

        return GestureDetector(
          onTap: day == null ? null : () => _handleDateSelect(day),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              day?.day.toString() ?? '',
              style:
              TextStyle(fontSize: 12, color: textColor),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
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
