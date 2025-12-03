import 'package:flutter/material.dart';
import '../ui/cardmode/card_mode.dart';
import '../ui/mypage/my_page.dart';
import '../services/login.dart';
import '../ui/loading/regen_loading.dart';
// 🔥 ESP32 연동
import 'package:dx_projecet_lg_sea/services/esp32_api.dart';

class UiHome extends StatefulWidget {
  const UiHome({super.key});

  @override
  State<UiHome> createState() => _UiHomeState();
}

class _UiHomeState extends State<UiHome> {
  bool isLoggedIn = false;
  String userName = 'Guest';
  String membership = '0';
  String qReward = '0';

  int _currentIndex = 0; // 0: 홈, 1: 카드모드, 2: 마이페이지

  // 로그인 화면으로 이동
  Future<void> _goToLogin() async {
    final result = await Navigator.push<LoginResult>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    if (result != null) {
      setState(() {
        isLoggedIn = true;
        userName = result.userName;
        membership = result.membership;
        qReward = result.qReward;
      });
    }
  }

  /// LG Regen 진입 확인 팝업
  Future<bool?> _showCardModeConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'LG Regen 모드입니다',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('이슬람 문화에 맞춤형 ThinQ 화면으로 이동할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('실행'),
            ),
          ],
        );
      },
    );
  }

  /// 로그아웃
  void _handleLogout() {
    setState(() {
      isLoggedIn = false;
      userName = 'Guest';
      membership = '0';
      qReward = '0';
    });
  }

  /// 🟢 카드모드로 이동 (Regen Loading → CardMode)
  void _openCardMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegenLoading(
          isLoggedIn: isLoggedIn,
          userName: userName,
          membership: membership,
          qReward: qReward,
          onLogout: _handleLogout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          setState(() => _currentIndex = idx);

          // 카드모드 탭 클릭 시 실제 CardMode로 진입
          if (idx == 1) {
            _openCardMode();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: '카드모드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }

  /// 탭별 화면
  Widget _buildBody() {
    if (_currentIndex == 0) {
      return _buildHomeContent();
    } else if (_currentIndex == 1) {
      return const Center(
        child: Text('카드모드는 하단 탭을 통해 진입합니다.'),
      );
    } else {
      return MyPage(
        isLoggedIn: isLoggedIn,
        userName: userName,
        membership: membership,
        qReward: qReward,
        onTapLogin: _goToLogin,
        onTapSignup: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입 화면은 아직 준비 중입니다.')),
          );
        },
        onTapLogout: _handleLogout,
      );
    }
  }

  /// 홈 화면
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 상단 영역
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFBEE0FF),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 55, 30, 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Aisyah의 행복한 홈",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    /// LG Regen 버튼
                    Transform.translate(
                      offset: const Offset(0, 15),
                      child: GestureDetector(
                        onTap: () async {
                          final confirmed =
                          await _showCardModeConfirmDialog(context);

                          if (confirmed == true) {
                            _openCardMode();
                          }
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "LG\nRegen",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const _ThreeDHomeCard(),
              ],
            ),
          ),

          // 하단 이미지
          Image.asset(
            'images/home_section.jpg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// 3D 홈뷰 카드
class _ThreeDHomeCard extends StatelessWidget {
  const _ThreeDHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
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
