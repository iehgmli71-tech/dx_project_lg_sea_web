import 'package:flutter/material.dart';
import 'dialog.dart' as dlg;
import 'prayer_schedule_sheet.dart';

class Device {
  final String id;
  final String name;
  final String status;
  String detail;
  final String iconImage;
  bool active;

  Device({
    required this.id,
    required this.name,
    required this.status,
    required this.detail,
    required this.iconImage,
    this.active = false,
  });

}
// --------------------------
// 2. CardMode 화면
// --------------------------
class CardMode extends StatefulWidget {
  const CardMode({super.key});

  @override
  State<CardMode> createState() => _CardModeState();
}

// --------------------------
// 3. CardMode 상태 클래스
// --------------------------
class _CardModeState extends State<CardMode> {
  Device? selectedDevice;
  bool showPrayerSchedule = false;
  bool _ramadanEcoMode = false;

  late final List<Device> devices = [
    Device(
      id: 'washing',
      name: 'Washing Machine',
      status: 'Running',
      detail: '35 min left',
      iconImage: 'images/WashingMachine.png',
      active: true,
    ),
    Device(
      id: 'dryer',
      name: 'Dryer',
      status: 'Drying',
      detail: '20 min left',
      iconImage: 'images/DryerLayer.png',
      active: true,
    ),
    Device(
      id: 'fridge',
      name: 'Refrigerator',
      status: '5°C',
      detail: '',
      iconImage: 'images/Refrigerator.png',
      active: false,
    ),
    Device(
      id: 'ac',
      name: 'Air Conditioner',
      status: 'Off',
      detail: '',
      iconImage: 'images/air_conditioner.png',
      active: false,
    ),
  ];

  dlg.DeviceType _mapToDeviceType(Device device) {
    // 다이얼로그파일에 있는 각각의 제어센터를 name 기반 매핑
    final name = device.name.toLowerCase();

    if (name.contains('wash')) {
      return dlg.DeviceType.washingMachine;
    } else if (name.contains('dry')) {
      return dlg.DeviceType.dryer;
    } else if (name.contains('air')) {
      return dlg.DeviceType.airConditioner;
    } else if (name.contains('refri') || name.contains('fridge')) {
      return dlg.DeviceType.refrigerator;
    } else {
      // 기본값: 냉장고로
      return dlg.DeviceType.refrigerator;
    }
  }

  IconData _getDialogIcon(Device device) {
    final name = device.name.toLowerCase();

    if (name.contains('wash')) {
      return Icons.local_laundry_service;
    } else if (name.contains('dry')) {
      return Icons.local_fire_department; // 필요하면 다른 아이콘
    } else if (name.contains('air')) {
      return Icons.ac_unit;
    } else if (name.contains('refri') || name.contains('fridge')) {
      return Icons.kitchen;
    } else {
      return Icons.devices_other;
    }
  }

  // 🔥 여기부터가 필수! => build 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildHeader(context),
              if (_ramadanEcoMode) _buildRamadanBanner(),
              //라마단기간의 토글이 켜졌을 경우 배너 추가
              _buildDeviceGrid(context),
              const SizedBox(height: 16),
              const WeatherDashboard(),
              // 🔥 가전카드 밑에 날씨 카드추가 코드
              const EnergyDashboard(),
              // 날씨 카드 아래로 전기 토큰 카드 추가
              const SizedBox(height: 16)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          // 상단: 뒤로가기 + Prayer Schedule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 26,
                    color: Colors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                onPressed: () {
                  showPrayerScheduleBottomSheet(
                    context,
                    onRamadanModeChange: (enabled) {
                      setState(() {
                        _ramadanEcoMode =enabled; // 🔥 Prayer Schedule에서 토글한 값 반영
                      });
                    },
                  );
                },
                icon: const Text('+'),
                label: const Text('Prayer Schedule'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // LG 로고 + LG Sea
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/LG_symbol.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                'LG Sea',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2열
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 165 / 175,
        ),
        itemBuilder: (context, index) {
          final device = devices[index];
          return _buildDeviceCard(context, device); // context 추가
        },
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, Device device) {
    final name = device.name.toLowerCase();
    final isWasher = name.contains('wash');
    final isDryer = name.contains('dry');

    final nameLower = device.name.toLowerCase();
    final bool isFridge =
        nameLower.contains('refri') ||
            nameLower.contains('fridge'); // Refrigerator 판별

    final String statusText = isFridge
        ? 'On' // 🔥 냉장고는 항상 작동 중
        : (device.active ? 'On' : 'Off'); // 나머지 가전은 on/off 표시

    final Color statusColor = isFridge
        ? Colors.grey.shade800
        : (device.active ? Colors.grey.shade800 : Colors.grey.shade500);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        // 1) dialog.dart 쪽 Device로 변환
        final dlgDevice = dlg.Device(
          id: device.id,
          name: device.name,
          icon: _getDialogIcon(device),
          status: device.status,
          color: device.active ? Colors.green : Colors.grey,
        );

        // 2) name 기반으로 DeviceType 매핑
        final dlg.DeviceType type = _mapToDeviceType(device);

        // 3) dialog.dart의 bottom sheet 열기, 카드 모델에 상태 반영
        dlg.showDeviceControlBottomSheet(
          context,
          dlgDevice,
          type,
          initialOn: device.active,
          onPowerChanged: (isOn) {
            setState(() {
              device.active = isOn;

              // 세탁기/건조기 잔여시간 동기화
              if (isWasher) {
                device.detail = isOn ? '35 min left' : '';
              } else if (isDryer) {
                device.detail = isOn ? '20 min left' : '';
              }
            });
          },
        );
      },
      child: Stack(
        children: [
          // 카드 본체
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7EE),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 60,
                    child: Image.asset(
                      device.iconImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor, // 위에서 계산한 색상 사용
                  ),
                ),
                // detail은 세탁기/건조기 + ON인 경우만 표시!
                if (device.active && device.detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    device.detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ⚡ 라마단 절전 배지 (우측 상단)
          if (_ramadanEcoMode)
            Positioned(
              right: 10,
              top: 10,
              child: _buildEcoBadge(), // 아래에 정의한 배지 위젯
            ),
        ],
      ),
    );
  }

  Widget _buildEcoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF59D), // 라이트 옐로우
            Color(0xFFFFB300), // 호박색
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '⚡ 절전',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRamadanBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF3E0), // 밝은 노랑
              Color(0xFFFFB300), // 호박색
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚡',
                style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '라마단 절전모드 활성화',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '모든 가전이 에너지 절약 모드로 작동 중입니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class WeatherDashboard extends StatelessWidget { // 날씨 대시보드 카드 구굴 날씨 API 받아오면 이쪽으로 연결?
  const WeatherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Opacity(
        opacity: 0.85,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4FF), // blue-50 느낌
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFB3D7FF), // blue-200 느낌
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 위치
              Row(
                children: const [
                  Icon(
                    Icons.location_pin,
                    color: Color(0xFF1E88E5), // blue-600
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "말레이시아",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 온도 + 습도
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  // 온도
                  Row(
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: Color(0xFFF57C00), // 주황
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "외부 온도: 33°C",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  // 습도
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: Color(0xFF2196F3), // 파랑
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "습도: 70%",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnergyDashboard extends StatefulWidget { //전기토큰 대시보드 카드 전기사용에 대한 API?
  const EnergyDashboard({super.key});

  @override
  State<EnergyDashboard> createState() => _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
  // React에서 쓰던 데이터 변환
  final List<Map<String, dynamic>> dailyData = [
    {"day": "월", "energy": 12.4},
    {"day": "화", "energy": 15.2},
    {"day": "수", "energy": 11.8},
    {"day": "목", "energy": 14.6},
    {"day": "금", "energy": 13.1},
    {"day": "토", "energy": 16.8},
    {"day": "일", "energy": 10.5},
  ];

  bool tokenSaverMode = true;

  @override
  Widget build(BuildContext context) {
    double totalEnergy =
    dailyData.fold(0, (sum, item) => sum + item['energy']);
    double avgEnergy = totalEnergy / dailyData.length;
    double todayEnergy = dailyData.last['energy'];

    int totalCost = (totalEnergy * 150).toInt();
    int avgCost = (avgEnergy * 150).toInt();
    int todayCost = (todayEnergy * 150).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // TOKEN & ECO SMART CARD
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFE0F7FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Color(0xFF90CAF9), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.flash_on,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.flash_on,
                                size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              "Token & Eco Smart Guard",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Prepaid electricity saver for your AC",
                          style:
                          TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // TOKEN STATUS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.battery_5_bar,
                              color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text("예상 사용 가능 시간: 2.3일",
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Text("전기 토큰 잔액:",
                              style: TextStyle(fontSize: 13)),
                          SizedBox(width: 6),
                          Text("72,000 IDR",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: 0.35,
                          color: Colors.orange,
                          backgroundColor: Colors.grey.shade300,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ECO SMART STATUS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      const Text("에코 스마트 ON",
                          style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text("ON",
                            style:
                            TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      const Text("· 0.4 kWh/h",
                          style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // LOW VOLTAGE PROTECTION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text("저전압 보호:", style: TextStyle(fontSize: 13)),
                      SizedBox(width: 4),
                      Text("Active",
                          style:
                          TextStyle(fontSize: 13, color: Colors.redAccent)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // TOKEN SAVER TOGGLE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.cyan],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        value: tokenSaverMode,
                        onChanged: (val) {
                          setState(() => tokenSaverMode = val);
                        },
                        title: Text(
                          "Token Saver ${tokenSaverMode ? 'ON' : 'OFF'}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                      if (tokenSaverMode)
                        const Text("✓ Automatic power optimization enabled",
                            style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TIPS CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFE0F2F1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.trending_down,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("절약 팁",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      const Text(
                        "에어컨 26°C 설정 시 하루 약 ₩2,500 절약 가능!",
                        style:
                        TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {},
                        child: const Text("자동 적용하기"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}


