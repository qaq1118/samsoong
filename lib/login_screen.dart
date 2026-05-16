import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'signup_screen.dart';
import 'contact_screen.dart';

const _loginApiKey = 'AIzaSyBas48myWR2JBRVnl0-yi39m6PvzDLKcAE';
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
  bool _isPasswordVisible = false;

  Widget _socialButton({required Color color, required Widget icon}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: icon),
    );
  }

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
                            'assets/reborn_logo_v2.png',
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
                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  '비밀번호를 잊으셨나요?',
                                  style: TextStyle(
                                    color: Color(0xFF006FFD),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                    setState(() => errorMessage = '이메일과 비밀번호를 입력해주세요.');
                                    return;
                                  }
                                  try {
                                    final res = await http.post(
                                      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_loginApiKey'),
                                      headers: {'Content-Type': 'application/json'},
                                      body: jsonEncode({
                                        'email': _emailController.text.trim(),
                                        'password': _passwordController.text,
                                        'returnSecureToken': true,
                                      }),
                                    );
                                    final data = jsonDecode(res.body);
                                    if (res.statusCode == 200) {
                                      // uid 저장
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setString('uid', data['localId']);
                                      setState(() => errorMessage = '');
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ContactScreen()),
                                        );
                                      }
                                    } else {
                                      setState(() => errorMessage = '이메일 또는 비밀번호가 일치하지 않습니다.');
                                    }
                                  } catch (e) {
                                    setState(() => errorMessage = '네트워크 오류가 발생했습니다.');
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