import 'dart:math' as math;
import 'package:flutter/material.dart';

class RegenLoading extends StatefulWidget {
  const RegenLoading({super.key});

  @override
  State<RegenLoading> createState() => _RegenLoadingState();
}

class _RegenLoadingState extends State<RegenLoading>
    with TickerProviderStateMixin {
  late final AnimationController _sproutController;
  late final AnimationController _particleController;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();

    // 새싹이 자라나는 애니메이션
    _sproutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // 떠다니는 파티클
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // 로고 살짝 커졌다 작아졌다
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sproutController.dispose();
    _particleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Figma 기준 390x844 프레임
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE6F9EF), // from-emerald-50
                Colors.white,
                Color(0xFFE7FBEF), // to-green-50
              ],
            ),
          ),
          child: Stack(
            children: [
              // ===== 땅 / 초록 영역 =====
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF86EFAC),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ===== 새싹 3개 =====
              _buildSprout(
                left: 80,
                bottom: 280,
                delay: 0.3,
                scale: 0.75,
              ),
              _buildSprout(
                left: 175,
                bottom: 260,
                delay: 0.1,
                scale: 1.0,
              ),
              _buildSprout(
                right: 90,
                bottom: 275,
                delay: 0.5,
                scale: 0.85,
              ),

              // ===== 파티클들 =====
              ...List.generate(8, (i) {
                return AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    final t =
                        (_particleController.value + i * 0.12) % 1.0; // 0~1
                    final opacity = t < 0.5 ? t * 2 : (1 - t) * 2;
                    final scale = 0.5 + 0.5 * math.sin(t * math.pi);

                    final dx = 100 + i * 30;
                    final dy = 300 + (t * 100);

                    return Positioned(
                      left: dx.toDouble(),
                      bottom: dy,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // ===== 로고 + LG Regen 텍스트 =====
              Positioned(
                top: 260,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        final t = _logoController.value;
                        final scale = 1 + 0.05 * math.sin(t * 2 * math.pi);
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        // Figma에서 가져온 로고 대신 Flutter asset 사용
                        child: Center(
                          child: Image.asset(
                            'images/Lg_logo.png', // pubspec에 이미 등록돼 있던거
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LG Regen',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== 서브 텍스트 =====
              const Positioned(
                top: 430,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Light Renewed, Home Refined',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(0, 0, 0, 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 새싹 1개를 그리는 헬퍼 위젯 (React 코드에서 새싹 1, 2, 3에 해당)
  Widget _buildSprout({
    double? left,
    double? right,
    required double bottom,
    required double delay,
    required double scale,
  }) {
    return AnimatedBuilder(
      animation: _sproutController,
      builder: (context, child) {
        // delay 적용
        final t = (_sproutController.value - delay).clamp(0.0, 1.0);
        final opacity = t;
        final s = 0.3 + 0.7 * t; // 0.3 ~ 1.0

        return Positioned(
          left: left,
          right: right,
          bottom: bottom,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: s * scale,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
      child: _SproutShape(),
    );
  }
}

/// 실제 새싹 모양 (간단히 줄기 + 잎 2~3개로 표현)
class _SproutShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 줄기
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          // 왼쪽 잎
          Positioned(
            left: 0,
            bottom: 30,
            child: Transform.rotate(
              angle: -0.6,
              child: Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          // 오른쪽 잎
          Positioned(
            right: 0,
            bottom: 24,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          // 위쪽 잎 (살짝 작은거)
          Positioned(
            bottom: 44,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 18,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

