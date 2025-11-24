import 'package:flutter/material.dart';

class SeaLoadingWhite extends StatelessWidget {
  const SeaLoadingWhite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔵 파도 일러스트 배경
          Positioned.fill(
            child: Image.asset(
              'images/blue_waves_bg.jpg',   // <- 저장한 파일 이름
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // 🎯 중앙 LG 로고 + 텍스트 + 로딩 인디케이터
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LG 로고
                Image.asset(
                  'images/LG_symbol.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 12),
                const Text(
                  'LG Sea',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

