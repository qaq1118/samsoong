import 'package:flutter/material.dart';
import 'login_screen.dart'; // 로그인 화면 불러오기

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
      home: const LoginScreen(), // 시작 화면을 LoginScreen으로 설정
    );
  }
}