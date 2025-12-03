import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final String membership;
  final String qReward;

  final VoidCallback onTapLogin;
  final VoidCallback onTapSignup;
  final VoidCallback onTapLogout;

  const MyPage({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.membership,
    required this.qReward,
    required this.onTapLogin,
    required this.onTapSignup,
    required this.onTapLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),

                // 로그인 / 프로필 카드
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isLoggedIn
                      ? _ProfileCard(
                    userName: userName,
                    membership: membership,
                    qReward: qReward,
                    onTapLogout: onTapLogout,
                  )
                      : _LoginCard(
                    onTapLogin: onTapLogin,
                    onTapSignup: onTapSignup,
                  ),
                ),

                // 제품 사후 관리
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SectionCard(
                    title: '제품 사후 관리',
                    children: const [
                      _MenuItem(
                        iconBgColor: Color(0xFFEDE9FE),
                        iconColor: Color(0xFF7C3AED),
                        icon: Icons.bolt_outlined,
                        title: '스마트루틴',
                        subtitle: '모드, 자동화',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFFEE2E2),
                        iconColor: Color(0xFFDC2626),
                        icon: Icons.shield_outlined,
                        title: '스마트진단',
                        subtitle: '제품 문제 해결',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFDBEAFE),
                        iconColor: Color(0xFF2563EB),
                        icon: Icons.description_outlined,
                        title: '제품정보와 보증',
                        subtitle: '등록된 제품 관리',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFCCFBF1),
                        iconColor: Color(0xFF0F766E),
                        icon: Icons.menu_book_outlined,
                        title: '제품 사용설명서',
                        subtitle: '매뉴얼 다운로드',
                      ),
                    ],
                  ),
                ),

                // 제품 업그레이드
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SectionCard(
                    title: '제품 업그레이드',
                    children: const [
                      _MenuItem(
                        iconBgColor: Color(0xFFFFEDD5),
                        iconColor: Color(0xFFEA580C),
                        icon: Icons.auto_awesome_outlined,
                        title: 'UP가전 센터',
                        subtitle: '최신 기능 업그레이드',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFFEF9C3),
                        iconColor: Color(0xFFCA8A04),
                        icon: Icons.lightbulb_outline,
                        title: 'UP가전 아이디어 제안',
                        subtitle: '새로운 기능 요청',
                      ),
                    ],
                  ),
                ),

                // 고객지원
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SectionCard(
                    title: '고객지원',
                    children: const [
                      _MenuItem(
                        iconBgColor: Color(0xFFDBEAFE),
                        iconColor: Color(0xFF2563EB),
                        icon: Icons.campaign_outlined,
                        title: '공지사항',
                        subtitle: '최신 소식 확인',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFD1FAE5),
                        iconColor: Color(0xFF16A34A),
                        icon: Icons.chat_bubble_outline,
                        title: '문의하기',
                        subtitle: '1:1 상담',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFE0E7FF),
                        iconColor: Color(0xFF4F46E5),
                        icon: Icons.phone_in_talk_outlined,
                        title: 'LG전자서비스',
                        subtitle: 'A/S 및 수리',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFFCE7F3),
                        iconColor: Color(0xFFDB2777),
                        icon: Icons.workspace_premium_outlined,
                        title: 'LG베스트케어',
                        subtitle: '프리미엄 케어 서비스',
                      ),
                      _MenuItem(
                        iconBgColor: Color(0xFFCFFAFE),
                        iconColor: Color(0xFF0891B2),
                        icon: Icons.science_outlined,
                        title: '실험실',
                        subtitle: '베타 기능 체험',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        'LG ThinQ v2.5.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '© 2024 LG Electronics. All rights reserved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                child: Image.asset(
                  'images/Lg_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Regen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '마이페이지',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final VoidCallback onTapLogin;
  final VoidCallback onTapSignup;

  const _LoginCard({
    required this.onTapLogin,
    required this.onTapSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFBFDBFE),
                  Color(0xFFA5F3FC),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline,
              size: 48,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '로그인이 필요합니다',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'LG 계정으로 로그인하고\n스마트홈을 편리하게 관리하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTapLogin,
              child: const Text('로그인하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String membership;
  final String qReward;
  final VoidCallback onTapLogout;

  const _ProfileCard({
    required this.userName,
    required this.membership,
    required this.qReward,
    required this.onTapLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7EE),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFBFDBFE),
                        Color(0xFFA5F3FC),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '👤',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '프로필 수정하기',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '멤버십',
                  value: membership,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFDBEAFE),
                      Color(0xFFBAE6FD),
                    ],
                  ),
                  borderColor: const Color(0xFFBFDBFE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Q 리워드',
                  value: qReward,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD1FAE5),
                      Color(0xFFA7F3D0),
                    ],
                  ),
                  borderColor: const Color(0xFFBBF7D0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onTapLogout,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBBBB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    '로그아웃',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7EE),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (final child in children) ...[
                child,
                const SizedBox(height: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Color iconBgColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuItem({
    required this.iconBgColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Gradient gradient;
  final Color borderColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.gradient,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
