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

class PersonQuestionScreen extends StatefulWidget {
  final String name;
  const PersonQuestionScreen({super.key, required this.name});

  @override
  State<PersonQuestionScreen> createState() => _PersonQuestionScreenState();
}

class _PersonQuestionScreenState extends State<PersonQuestionScreen> {
  final List<Map<String, String>> _questions = [
    {
      'q': '1. 카카오톡이나 문자를 보낼 때 자주 쓰는 말투나 어미, 이모티콘 사용 습관이 있었나요?',
      'hint': '예: "ㅋㅋ" 자주 씀, "~해요" 체로 씀, 하트 이모티콘 많이 씀',
    },
    {
      'q': '2. 감정 상태에 따라 목소리 톤, 말 속도, 크기가 어떻게 달라졌나요?',
      'hint': '예: 기쁠 때 목소리가 높아짐, 화날 때 말이 느려짐',
    },
    {
      'q': '3. 무의식적으로 자주 하던 입버릇이나 감탄사가 있었나요?',
      'hint': '예: "아이고~", "그렇지~", "어머나"',
    },
    {
      'q': '4. 상대방의 이야기를 들을 때 어떻게 반응하셨나요?',
      'hint': '예: 고개를 끄덕이며 들음, 맞장구를 자주 침, 조언을 먼저 함',
    },
    {
      'q': '5. 성향을 비유한다면 어떤 편이었나요? (활동적 vs 조용함, 이성적 vs 감성적)',
      'hint': '예: 집에서 쉬는 걸 좋아하고 감성적인 편',
    },
    {
      'q': '6. 화가 나거나 속상할 때 어떻게 대처하셨나요?',
      'hint': '예: 혼자 조용히 있음, 직접 말함, 한숨을 쉼',
    },
    {
      'q': '7. 일상에서의 분위기와 에너지 수준은 어떠했나요?',
      'hint': '예: 항상 밝고 활기참, 조용하지만 따뜻함',
    },
    {
      'q': '8. 외모적 특징이나 무의식적으로 자주 하던 행동 버릇이 있었나요?',
      'hint': '예: 말할 때 손을 많이 씀, 생각할 때 눈썹을 찌푸림',
    },
    {
      'q': '9. 즐겨 입던 옷 스타일이나 자주 쓰시던 향수/로션 등이 있었나요?',
      'hint': '예: 항상 단정한 편, 꽃향기 나는 로션 쓰심',
    },
    {
      'q': '10. 가장 소중히 여기던 물건이나 즐겨 드시던 음식/음료가 있었나요?',
      'hint': '예: 낡은 시계, 된장찌개, 믹스커피',
    },
    {
      'q': '11. 가족들을 부르는 호칭이 어떻게 되었나요?',
      'hint': '예: 딸을 "우리 강아지", 아들을 "이 녀석"이라 부름',
    },
    {
      'q': '12. 주로 어떤 주제로 대화를 나누셨나요?',
      'hint': '예: 건강, 날씨, 드라마, 손자손녀 이야기',
    },
    {
      'q': '13. 특별히 고집하거나 꼭 지키던 규칙이나 습관이 있었나요?',
      'hint': '예: 밥은 꼭 같이 먹어야 한다, 잠자리에 들기 전 기도함',
    },
    {
      'q': '14. 자주 하시던 칭찬이나 격려의 말이 있었나요?',
      'hint': '예: "잘했어", "우리 딸 최고야", "고생했다"',
    },
    {
      'q': '15. 만났을 때나 헤어질 때 자주 하시던 첫인사나 안부의 말이 있었나요?',
      'hint': '예: "밥은 먹었나?", "잘 자라", "보고 싶었다"',
    },
  ];

  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_questions.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

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
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '질문에 답변해주세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 24),
            ...List.generate(_questions.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _questions[i]['q']!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers[i],
                      minLines: 2,
                      maxLines: null,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: _questions[i]['hint'],
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF0F0F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('되돌아가기', style: TextStyle(color: Colors.grey, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x89006FFD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('저장하기', style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionContent extends StatelessWidget {
  void _onPersonTap(BuildContext context, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PersonQuestionScreen(name: name)),
    );
  }

  void _onQuestionTap(BuildContext context) {
    final answerController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFE8E9F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.help_outline, color: Color(0xFF006FFD), size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '오늘의 질문',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '상대방이 가장 좋아하는 음식은?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2024),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '답변',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: answerController,
                autofocus: true,
                minLines: 3,
                maxLines: null,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: '답변을 입력해주세요',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('닫기', style: TextStyle(color: Colors.grey, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0x89006FFD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('저장하기', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

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
                Expanded(child: GestureDetector(onTap: () => _onPersonTap(context, 'James'), child: _buildPhotoCard('James'))),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(onTap: () => _onPersonTap(context, 'Bob'), child: _buildPhotoCard('Bob'))),
              ],
            ),
            const SizedBox(height: 10),
            // 2행: Lee / Kim 카드
            Row(
              children: [
                Expanded(child: GestureDetector(onTap: () => _onPersonTap(context, 'Lee'), child: _buildPhotoCard('Lee'))),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(onTap: () => _onPersonTap(context, 'Kim'), child: _buildPhotoCard('Kim'))),
              ],
            ),
            const SizedBox(height: 20),
            // 질문 카드
            GestureDetector(
              onTap: () => _onQuestionTap(context),
              child: Container(
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
