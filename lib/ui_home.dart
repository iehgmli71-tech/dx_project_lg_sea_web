import 'package:flutter/material.dart';
import '../ui/cardmode/card_mode.dart';
import '../ui/mypage/my_page.dart';
import '../services/login.dart';
import '../ui/loading/regen_loading.dart';
import '../services/esp32_api.dart';

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

  @override
  void initState() {
    super.initState();
    // 👇 앱이 처음 홈 화면에 들어올 때
    //    세 ESP32 모두에 "Hello ThinQ" + LED OFF
    Esp32Api.showHelloThinqAll();
  }

  // 로그인 화면으로 이동해서 결과 받기
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

  // 로그아웃
  void _handleLogout() {
    setState(() {
      isLoggedIn = false;
      userName = 'Guest';
      membership = '0';
      qReward = '0';
    });
  }

  // 🔥 LG Regen / 카드모드 진입전 regen_loading
  void _openCardMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegenLoading(
          isLoggedIn: isLoggedIn,
          userName: userName,
          membership: membership,
          qReward: qReward,
          onLogout: _handleLogout, // CardMode 안에서 로그아웃 시 UiHome 상태 갱신
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

          // 카드모드 탭을 눌렀을 때 실제 CardMode 화면으로 이동
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

  /// 탭별로 다른 화면 렌더링
  Widget _buildBody() {
    if (_currentIndex == 0) {
      // 🔥 진짜 홈 화면
      return _buildHomeContent();
    } else if (_currentIndex == 1) {
      // 카드모드 탭은 실제 화면은 push 로 띄우고 여기선 안내만
      return const Center(
        child: Text('카드모드는 하단 탭을 통해 진입합니다.'),
      );
    } else {
      // 마이페이지 탭
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

  /// 🏠 홈 화면 레이아웃 (LG Regen 버튼 + 3D홈뷰 + 하단 이미지)
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
                // 상단 텍스트 + 버튼
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

                    // === LG Regen 버튼 ===
                    Transform.translate(
                      offset: const Offset(0, 15),
                      child: GestureDetector(
                        onTap: _openCardMode, // ✅ 여기서 CardMode 열기
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

                // 3D 홈뷰 카드
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
          // TODO: 다른 카드들 추가
        ],
      ),
    );
  }
}

/// 👇 보조 위젯: 3D 홈뷰 카드
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
