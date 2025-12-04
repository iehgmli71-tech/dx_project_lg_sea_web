import 'package:flutter/material.dart';
import 'dart:convert'; // 데이터 포장용 (JSON)
import 'package:http/http.dart' as http; // 서버 통신용

/// 로그인 성공 시 UiHome 으로 넘겨줄 정보
class LoginResult {
  final int userId;
  final String userName;
  final String membership;
  final String qReward;

  const LoginResult({
    required this.userId,
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
  bool _pwVisible = false;

  // 서버에 로그인 요청
  Future<void> _handleLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    // 입력 확인
    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500)); // 약간의 연출

    // 서버 주소 설정 (안드로이드 에뮬레이터 전용 주소)
    // 실제 폰이라면 컴퓨터 IP(예: 192.168.x.x)를 써야 한다.
    final url = Uri.parse('http://10.0.2.2:8082/api/login');

    try {
      print("서버로 요그인 요청 보냄 : $id");

      // 서버 전송 (Post) 백엔드 LoginDTO가 {email, password}를 받으므로 키값을 맞춰줌
      final response = await http.post(
        url,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "email": id,      // 사용자 입력 아이디
          "password" : pw,  // 사용자 입력 비밀번호
        }),
      );

      // 결과 처리
      if(response.statusCode == 200) {
        if(response.body.isNotEmpty) {
          final userData = jsonDecode(response.body);
          print("${userData['name']}님 환영합니다.");

          //서버에서 받은 닉네임을 UiHome으로 전달
          // 멤버십이나 포인트는 아직 DB에 없으니 임시값 유지
          final result = LoginResult(
              userId: userData['id'] as int, // DB의 id
              userName: userData['name'] ?? 'User', // DB의 이름 사용
            // 아래 두 개는 나중에 DB에 추가하면 바꿀 수 있음
              membership: 'Gold',
              qReward: "120",
          );

          if(mounted) {
            Navigator.pop(context, result); // 이전 화면으로 정보 듣고 복귀
          }
        } else {
          // 200 OK이지만 데이터가 비어있을 경우 예외처리
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("로그인에 실패했습니다.")),
            );
          }
        }
      } else {
        // 404, 500 등 (아이디 또는 비밀번호 틀릴 시)
        print("로그인 실패 상태코드 : ${response.statusCode}");
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('아이디 또는 비밀번호가 올바르지 않습니다.'))
          );
        }
      }
    } catch(e) {
      // 서버 연결 실패
      print("서버 연결 에러: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버와 연결할 수 없습니다.'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              obscureText: !_pwVisible, // true면 **** / false면 숫자 보임
              decoration: InputDecoration(
                labelText: '비밀번호 (임시: 1234)',
                suffixIcon: IconButton(
                  icon: Icon(
                    _pwVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _pwVisible = !_pwVisible;  // 아이콘 클릭 시 값 반전
                    });
                  },
                ),
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
