import 'package:flutter/material.dart';

/// 로그인 성공 시 UiHome 으로 넘겨줄 정보
class LoginResult {
  final String userName;
  final String membership;
  final String qReward;

  const LoginResult({
    required this.userName,
    required this.membership,
    required this.qReward,
  });
}

/// 간단한 임시 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _isLoading = false;

  // 🔐 임시 계정 정보 (원하면 여기만 바꾸면 됨)
  static const String _demoId = 'demo';
  static const String _demoPw = '1234';

  Future<void> _handleLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // 약간의 연출

    if (id == _demoId && pw == _demoPw) {
      // ✅ 로그인 성공 → UiHome 으로 결과 전달
      const result = LoginResult(
        userName: 'Aisyah',   // 마이페이지에서 보여줄 이름
        membership: 'Gold',   // 멤버십 등급
        qReward: '120',       // 리워드 포인트
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    } else {
      // ❌ 로그인 실패
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이디 또는 비밀번호가 올바르지 않습니다.')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: '아이디 (임시: demo)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 (임시: 1234)',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('로그인'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, null), // 취소
                child: const Text('취소'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
