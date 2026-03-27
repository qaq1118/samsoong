import 'package:flutter/material.dart';
import 'home_screen.dart';   // 👈 이 줄이 없으면 MainHomeScreen을 못 찾아요!
import 'signup_screen.dart'; // 👈 회원가입 화면도 연결되어 있어야 합니다.
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RE:Born'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              '환영합니다!\n로그인에 성공했습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}