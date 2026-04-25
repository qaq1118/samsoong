import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ChatContent(),
    );
  }
}

class ChatContent extends StatelessWidget {
  static const _chatItems = [
    {'name': '인물1', 'message': '잘 지내?', 'badge': '9'},
    {'name': '인물2', 'message': '잘 지내?'},
    {'name': '인물3', 'message': '잘 지내?', 'badge': '2'},
    {'name': '인물4', 'message': '잘 지내?'},
    {'name': '인물5', 'message': '잘 지내?'},
    {'name': '인물6', 'message': '잘 지내?'},
    {'name': '인물7', 'message': '잘 지내?'},
    {'name': 'Peyton Sawyer', 'message': '잘 지내?'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: const Color(0xFFF7F8FD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Color(0xFF8F9098), size: 16),
                SizedBox(width: 8),
                Text(
                  '검색',
                  style: TextStyle(
                    color: Color(0xFF8F9098),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 채팅 목록
        Expanded(
          child: ListView.builder(
            itemCount: _chatItems.length,
            itemBuilder: (context, index) {
              final item = _chatItems[index];
              return _buildChatItem(
                item['name']!,
                item['message']!,
                badge: item['badge'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(String name, String message, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: const Color(0xFFEAF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Color(0xFFB3DAFF), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // 이름 & 메시지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF71727A),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // 배지
          if (badge != null)
            Container(
              width: 24,
              height: 24,
              decoration: ShapeDecoration(
                color: const Color(0xFF006FFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
