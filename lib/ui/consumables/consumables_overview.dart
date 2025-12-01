import 'package:flutter/material.dart';
import 'package:dx_projecet_lg_sea/models/device_models.dart';

import '../../data/consumables_data.dart';      // allDevices
import 'consumablesLayer.dart';                // 상세 레이어
import 'consumables_as_modal.dart';            // 간편 AS 모달

class ConsumablesOverviewScreen extends StatelessWidget {
  final List<Device> devices;

  const ConsumablesOverviewScreen({
    super.key,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    // 외부에서 devices를 넘겨주면 그걸 쓰고,
    // 아니라면 allDevices(샘플 데이터)를 사용
    final List<Device> deviceList =
    devices.isNotEmpty ? devices : allDevices;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deviceList.length + 2, // 헤더 1 + 디바이스 N + AS 영역 1
      itemBuilder: (context, index) {
        // 🔥 0번 인덱스 = 상단 헤더
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/Lg_logo.png',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Regen',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 65),  // ← 여기만 조절하면 됨
                    child: const Text(
                      '제품상태 확인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                    ),
                  ),
        ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 20),
            ],
          );
        }

        // 🔢 1 ~ deviceList.length 까지는 디바이스 카드
        if (index <= deviceList.length) {
          final deviceIndex = index - 1;
          final device = deviceList[deviceIndex];

          // 🔥 null이면 빈 리스트로 대체 (length, fold 등에서 에러 안 나게)
          final consumables = device.consumables ?? <Consumable>[];

          final criticalCount =
              consumables.where((c) => c.percentage < 40).length;

          final overallPercent = consumables.isEmpty
              ? 0
              : (consumables.fold<int>(
            0,
                (sum, c) => sum + c.percentage,
          ) /
              consumables.length)
              .round();

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (_) => ConsumablesLayer(
                  device: device,
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: overallPercent < 40
                      ? Colors.red.shade200
                      : overallPercent < 70
                      ? Colors.yellow.shade300
                      : Colors.green.shade300,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 기기 이미지
                  _buildDeviceImage(device),
                  const SizedBox(width: 16),

                  // 텍스트 + 프로그레스
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "전체 소모품 상태"
                              "${criticalCount > 0 ? " · 교체 필요 ${criticalCount}개" : ""}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // 퍼센트 바
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: overallPercent / 100,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: overallPercent < 40
                                      ? Colors.red
                                      : overallPercent < 70
                                      ? Colors.yellow.shade600
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$overallPercent%",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: overallPercent < 40
                              ? Colors.red
                              : overallPercent < 70
                              ? Colors.yellow.shade600
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "상세보기 →",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ 마지막 index = 간편 AS 영역
        return _buildEasyASSection(context);
      },
    );
  }

  Widget _buildDeviceImage(Device device) {
    if (device.iconImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          device.iconImage!,
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
      );
    }
    return Text(
      device.iconEmoji,
      style: const TextStyle(fontSize: 40),
    );
  }
}

/// 🔽 화면 맨 아래에 붙는 "간편 AS 신청" 영역
Widget _buildEasyASSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.build_outlined, color: Color(0xFF2563EB), size: 18),
              SizedBox(width: 6),
              Text(
                '간편 AS 신청',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // AS 신청하기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  builder: (_) => EasyASModal(
                    devices: allDevices, // 샘플 디바이스 리스트
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(18),
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AS 신청하기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '빠르고 간편하게 AS를 신청하세요',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, size: 26, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // AS 신청 내역 (지금은 비어있음)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'AS 신청 내역',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: const Text(
              '신청 내역이 없습니다',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ],
    ),
  );
}
