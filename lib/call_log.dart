import 'package:flutter/material.dart';

class CallLogScreen extends StatelessWidget {
  const CallLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CallLogContent(),
    );
  }
}

class CallLogContent extends StatelessWidget {
  const CallLogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '통화 기록',
        style: TextStyle(
          color: Color(0xA01F2024),
          fontSize: 20,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
