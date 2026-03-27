import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 💡 1. mounted 에러 해결을 위해 StatefulWidget으로 변경했습니다.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 💡 2. 컨트롤러를 클래스 바로 아래로 옮겼습니다.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '가입하기',
              style: TextStyle(color: Color(0xFF1F2024), fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const Text(
              '시작하려면 계정을 생성하세요',
              style: TextStyle(color: Color(0xFF71727A), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // 💡 3. 함수 호출할 때 컨트롤러를 각각 넣어줍니다.
            _buildInputField('이름', '이름을 입력하세요', controller: _nameController),
            const SizedBox(height: 16),
            _buildInputField('이메일 주소', 'name@email.com', controller: _emailController),
            const SizedBox(height: 16),
            _buildInputField('비밀번호', '비밀번호를 입력하세요', isPassword: true, controller: _passwordController),
            const SizedBox(height: 16),
            _buildInputField('비밀번호 확인', '비밀번호를 다시 입력하세요', isPassword: true),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("이메일과 비밀번호를 모두 입력해주세요.")),
                    );
                    return;
                  }

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_email', _emailController.text);
                  await prefs.setString('user_pw', _passwordController.text);
                  await prefs.setString('user_name', _nameController.text);

                  if (mounted) { // 이제 에러 안 남!
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("회원가입이 완료되었습니다!")),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('가입하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 4. 공통 함수에 controller 파라미터를 추가했습니다.
  Widget _buildInputField(String label, String hint, {bool isPassword = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // 👈 여기에 연결해줘야 사용자가 입력한 값을 가져올 수 있어요!
          obscureText: isPassword,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8F9098)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC5C6CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006FFD)),
            ),
          ),
        ),
      ],
    );
  }
}