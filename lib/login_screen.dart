import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'contact_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = "";
  bool _isPasswordVisible = false; // 비밀번호 보임 여부를 결정하는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 1. 상단 로고 영역
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 2. 하단 로그인 폼
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '환영합니다!',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 30),
                            if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),

                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible, // 💡 눈 모양 상태에 따라 숨김/보임
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                                // 💡 눈 모양 아이콘 버튼
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // 이 부분을 찾으세요!
                            // login_screen.dart의 로그인 버튼 위치
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // 1. DB(저장소) 열기
                                  final prefs = await SharedPreferences.getInstance();

                                  // 2. 저장된 데이터 꺼내기 (signup_screen에서 저장한 이름표로 찾기)
                                  String? savedEmail = prefs.getString('user_email');
                                  String? savedPw = prefs.getString('user_pw');

                                  // 3. 검증 로직
                                  // 입력값이 비어있지 않고, DB에 저장된 값과 정확히 일치하는지 확인
                                  if (savedEmail != null &&
                                      savedEmail == _emailController.text &&
                                      savedPw == _passwordController.text) {

                                    // ✅ 로그인 성공!
                                    setState(() {
                                      errorMessage = ""; // 에러 메시지 초기화
                                    });

                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ContactScreen()),
                                      );
                                    }
                                  } else {
                                    // ❌ 로그인 실패 (DB에 없거나 비번이 틀림)
                                    setState(() {
                                      errorMessage = "이메일 또는 비밀번호가 일치하지 않습니다.";
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006FFD),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 💡 에러났던 텍스트 버튼 부분 수정 완료!
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                  );
                                },
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '아직 회원이 아니신가요? ',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                      const TextSpan(
                                        text: '지금 가입하기',
                                        style: TextStyle(
                                          color: Color(0xFF006FFD),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}