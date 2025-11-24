import 'package:dx_projecet_lg_sea/card_mode.dart';
import 'package:dx_projecet_lg_sea/sea_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiHome extends StatelessWidget {
  const  UiHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 영역
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFBEE0FF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20,55,30,30),
              child: Column(
                children: [
                  // 상단 텍스트 + 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "이지엘의 행복한 홈",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      // === ThinQ Card Mode 버튼 ===
                      Transform.translate(
                        // 오른쪽 그대로 두고, y값만 바꿔서 위/아래로 이동
                        offset: const Offset(0, 15),   // ↓ 12px 내려감 (원하는 값으로 조정)
                      child: GestureDetector(
                        onTap: () async {
                          // 먼저 로딩 화면 보여주기
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SeaLoadingWhite(),
                            ),
                          );

                          // 3초 뒤 CardMode 페이지로 이동
                          await Future.delayed(const Duration(seconds: 3));

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CardMode(),
                            ),
                          );
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "ThinQ\nCard\nMode",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      )],
                  ),

                  const SizedBox(height: 30),

                  // 3D 홈뷰 카드
                  _ThreeDHomeCard(),
                ],
              ),
            ),

            const SizedBox(height: 20),


          ],
        ),
      ),
    );
  }
}
class _ThreeDHomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image, size: 32),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "3D 홈뷰로 우리집과 제품의 실시간 상태를\n한눈에 확인하세요.",
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: const Text(
              "3D 홈뷰 만들기",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF3742FA),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}

