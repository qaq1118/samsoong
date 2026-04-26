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
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
            minimumSize: WidgetStateProperty.all(const Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            minimumSize: WidgetStateProperty.all(const Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            minimumSize: WidgetStateProperty.all(const Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      ),
      home: const LoginScreen(), // 시작 화면을 LoginScreen으로 설정
    );
  }
}