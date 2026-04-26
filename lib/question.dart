import 'package:flutter/material.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: QuestionContent(),
    );
  }
}

class QuestionContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // 1행: James / Bob 카드
            Row(
              children: [
                Expanded(child: _buildPhotoCard('James')),
                const SizedBox(width: 10),
                Expanded(child: _buildPhotoCard('Bob')),
              ],
            ),
            const SizedBox(height: 10),
            // 2행: Lee / Kim 카드
            Row(
              children: [
                Expanded(child: _buildPhotoCard('Lee')),
                const SizedBox(width: 10),
                Expanded(child: _buildPhotoCard('Kim')),
              ],
            ),
            const SizedBox(height: 20),
            // 질문 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: const Color(0xFFF7F8FD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE8E9F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.help_outline,
                        color: Color(0xFF006FFD),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '오늘의 질문',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '상대방이 가장 좋아하는 음식은?',
                    style: TextStyle(
                      color: Color(0xFF1F2024),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String name) {
    return Container(
      height: 220,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF006FFD)),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // 하단 그라디언트
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00006FFD), Color(0xFF006FFD)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
            ),
          ),
          // 이름
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
