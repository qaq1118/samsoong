import 'package:flutter/material.dart';
import 'main_frame.dart';
import 'common.dart';

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
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Scaffold(
                  body: ListView(children: [SettingsLightScreen()]),
                )),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('설정 (라이트)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Scaffold(
                  backgroundColor: const Color.fromARGB(255, 18, 32, 47),
                  body: ListView(children: [SettingsDarkScreen()]),
                )),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('설정 (다크)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
            ),
            const SizedBox(height: 12),
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
