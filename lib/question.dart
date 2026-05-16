import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF8FAFC);
const _border  = Color(0xFFF1F5F9);
const _divider = Color(0xFFE2E8F0);
const _blue50  = Color(0xFFEFF6FF);
const _blue100 = Color(0xFFDBEAFE);
const _blue200 = Color(0xFFBFDBFE);
const _blue400 = Color(0xFF60A5FA);
const _blue500 = Color(0xFF3B82F6);
const _s400    = Color(0xFF94A3B8);
const _s500    = Color(0xFF64748B);
const _s600    = Color(0xFF475569);
const _s700    = Color(0xFF334155);
const _s800    = Color(0xFF1E293B);

// ── 이미지 선택 헬퍼 ─────────────────────────────────────────────────────────
Future<void> pickAndUpdateImage(PersonModel person) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (file != null) {
    final bytes = await file.readAsBytes();
    AppState.instance.updatePersonImage(person.id, bytes);
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final PersonModel person;
  final double size;
  const _Avatar({required this.person, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: person.imageBytes == null
            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [person.g1, person.g2])
            : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.09),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: person.imageBytes != null
          ? Image.memory(person.imageBytes!, fit: BoxFit.cover)
          : Center(child: Text(person.initial,
              style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w700, color: _s700))),
    );
  }
}

class _QuestionBanner extends StatelessWidget {
  const _QuestionBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_blue50, _blue100]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _blue200),
    ),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: _blue100, shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.favorite_rounded, color: _blue400, size: 16)),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('오늘의 질문',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _blue400)),
            SizedBox(height: 3),
            Text('상대방이 가장 좋아하는 음식은?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _s600)),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded, color: _blue400, size: 18),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final bool answered;
  const _StatusBadge({required this.answered});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: answered ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: answered ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A)),
    ),
    child: Text(
      answered ? '완료' : '답변 대기',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: answered ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// 화면 1 — 질문과 답변 (인물 그리드)
// ════════════════════════════════════════════════════════════════════════════
class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(backgroundColor: _bg, body: QuestionContent());
}

class QuestionContent extends StatefulWidget {
  const QuestionContent({super.key});

  @override
  State<QuestionContent> createState() => _QuestionContentState();
}

class _QuestionContentState extends State<QuestionContent> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final people = AppState.instance.people;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('질문과 답변',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _s800)),
                SizedBox(height: 4),
                Text('고인과의 소중한 기억을 기록해보세요',
                    style: TextStyle(fontSize: 13, color: _s400)),
              ]),
              Container(
                width: 34, height: 34,
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: const Icon(Icons.edit_outlined, size: 15, color: _s400),
              ),
            ],
          ),
        ),
        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('인물 선택',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: _s400, letterSpacing: 0.6)),
                const SizedBox(height: 14),

                // ── 인물이 없을 때 ──
                if (people.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: const Column(children: [
                      Icon(Icons.person_add_alt_1_outlined, size: 40, color: _s400),
                      SizedBox(height: 12),
                      Text('연락처에서 인물을 추가해보세요',
                          style: TextStyle(fontSize: 14, color: _s400)),
                    ]),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: people.length,
                    itemBuilder: (context, i) {
                      final p = people[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => PersonQuestionScreen(personId: p.id))),
                        child: _PersonCard(person: p),
                      );
                    },
                  ),

                const SizedBox(height: 24),
                const Text('오늘의 질문',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: _s400, letterSpacing: 0.6)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TodayQuestionScreen())),
                  child: const _QuestionBanner(),
                ),
                const SizedBox(height: 12),
                // ── 답변 모아보기 버튼 ──
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AnswerSummaryScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _border),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                          blurRadius: 8, offset: const Offset(0, 1))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4), shape: BoxShape.circle),
                        child: const Center(
                          child: Icon(Icons.collections_bookmark_outlined,
                              color: Color(0xFF22C55E), size: 17)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('답변 모아보기',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _s800)),
                          SizedBox(height: 2),
                          Text('모든 답변을 한눈에 확인하세요',
                              style: TextStyle(fontSize: 12, color: _s400)),
                        ],
                      )),
                      const Icon(Icons.chevron_right_rounded, color: _s400, size: 18),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 인물 카드 (사진 편집 버튼 포함) ─────────────────────────────────────────────
class _PersonCard extends StatelessWidget {
  final PersonModel person;
  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 14, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 파스텔 배경
          if (person.imageBytes == null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [person.g1.withOpacity(0.22), person.g2.withOpacity(0.38)],
                  ),
                ),
              ),
            ),

          // 아바타 + 이름 (세로 중앙 정렬)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52, height: 52,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: person.imageBytes == null
                        ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [person.g1, person.g2])
                        : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                        blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: person.imageBytes != null
                      ? Image.memory(person.imageBytes!, fit: BoxFit.cover)
                      : Center(child: Text(person.initial,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _s700))),
                ),
                const SizedBox(height: 8),
                Text(person.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _s700)),
              ],
            ),
          ),

          // 사진 편집 버튼
          Positioned(top: 8, right: 8,
            child: GestureDetector(
              onTap: () => pickAndUpdateImage(person),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 14, color: _s500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 화면 3 — 오늘의 질문 고인별 현황
// ════════════════════════════════════════════════════════════════════════════
class TodayQuestionScreen extends StatefulWidget {
  const TodayQuestionScreen({super.key});

  @override
  State<TodayQuestionScreen> createState() => _TodayQuestionScreenState();
}

class _TodayQuestionScreenState extends State<TodayQuestionScreen> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final people = AppState.instance.people;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(children: [
                    Icon(Icons.chevron_left_rounded, color: _s400, size: 22),
                    Text('뒤로', style: TextStyle(fontSize: 13, color: _s400)),
                  ]),
                ),
                const SizedBox(height: 16),
                const Text('오늘의 질문',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _s800)),
                const SizedBox(height: 12),
                const _QuestionBanner(),
              ]),
            ),

            // ── 목록 ──
            Expanded(
              child: people.isEmpty
                  ? const Center(
                      child: Text('연락처에 인물을 추가해보세요',
                          style: TextStyle(fontSize: 14, color: _s400)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: people.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final p = people[i];
                        final answered = AppState.instance.hasAnswer(p.id);
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => PersonAnswerScreen(person: p)));
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _border),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8, offset: const Offset(0, 1))],
                            ),
                            child: Row(children: [
                              _Avatar(person: p, size: 44),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w700, color: _s800)),
                                  const SizedBox(height: 3),
                                  const Text('상대방이 가장 좋아하는 음식은?',
                                      style: TextStyle(fontSize: 12, color: _s400),
                                      overflow: TextOverflow.ellipsis),
                                ],
                              )),
                              const SizedBox(width: 8),
                              _StatusBadge(answered: answered),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 화면 4 — 고인별 개별 답변 입력
// ════════════════════════════════════════════════════════════════════════════
class PersonAnswerScreen extends StatefulWidget {
  final PersonModel person;
  const PersonAnswerScreen({super.key, required this.person});

  @override
  State<PersonAnswerScreen> createState() => _PersonAnswerScreenState();
}

class _PersonAnswerScreenState extends State<PersonAnswerScreen> {
  late final TextEditingController _ctrl =
      TextEditingController(text: AppState.instance.getAnswer(widget.person.id));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() async {
    final answerText = _ctrl.text.trim();
    if (answerText.isEmpty) {
      Navigator.pop(context);
      return;
    }
    AppState.instance.saveAnswer(widget.person.id, answerText);

    // Also save to Firestore
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid') ?? '';
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users').doc(uid)
            .collection('deceased').doc(widget.person.id)
            .collection('daily_answers')
            .add({
          'question': '상대방이 가장 좋아하는 음식은?',
          'answer': answerText,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.person;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(children: [
                    Icon(Icons.chevron_left_rounded, color: _s400, size: 22),
                    Text('뒤로', style: TextStyle(fontSize: 13, color: _s400)),
                  ]),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  _Avatar(person: p, size: 48),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('에게 전하는 말',
                        style: TextStyle(fontSize: 12, color: _s400)),
                    Text(p.name,
                        style: const TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700, color: _s800)),
                  ]),
                ]),
              ]),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(children: [
                  const _QuestionBanner(),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _divider),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                          blurRadius: 12, offset: const Offset(0, 2))],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      TextField(
                        controller: _ctrl,
                        minLines: 6,
                        maxLines: null,
                        maxLength: 500,
                        style: const TextStyle(fontSize: 14, color: _s600, height: 1.6),
                        decoration: const InputDecoration(
                          hintText: '답변을 입력해주세요...',
                          hintStyle: TextStyle(color: _s400),
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 1, color: _border),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _ctrl,
                        builder: (_, v, __) =>
                            Text('${v.text.length} / 500',
                                style: const TextStyle(fontSize: 11, color: _s400)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),

            // ── 하단 버튼 ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                  color: Colors.white, border: Border(top: BorderSide(color: _border))),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mic_none_rounded, size: 18),
                    label: const Text('음성 인식'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _s500,
                      side: const BorderSide(color: _divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_alt_rounded, size: 18, color: Colors.white),
                    label: const Text('저장하기',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue500,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 화면 2 — 인물 상세 질문 (15개 항목)
// ════════════════════════════════════════════════════════════════════════════
class PersonQuestionScreen extends StatefulWidget {
  final String personId;
  const PersonQuestionScreen({super.key, required this.personId});

  @override
  State<PersonQuestionScreen> createState() => _PersonQuestionScreenState();
}

class _PersonQuestionScreenState extends State<PersonQuestionScreen> {
  static const _questions = [
    ('카카오톡이나 문자를 보낼 때 자주 쓰는 말투나 어미, 이모티콘 사용 습관이 있었나요?', '"ㅋㅋ" 자주 씀, "~해요" 체로 씀'),
    ('감정 상태에 따라 목소리 톤, 말 속도, 크기가 어떻게 달라졌나요?', '기쁠 때 목소리가 높아짐, 화날 때 말이 느려짐'),
    ('무의식적으로 자주 하던 입버릇이나 감탄사가 있었나요?', '"아이고~", "그렇지~", "어머나"'),
    ('상대방의 이야기를 들을 때 어떻게 반응하셨나요?', '고개를 끄덕이며 들음, 맞장구를 자주 침'),
    ('성향을 비유한다면 어떤 편이었나요?', '집에서 쉬는 걸 좋아하고 감성적인 편'),
    ('화가 나거나 속상할 때 어떻게 대처하셨나요?', '혼자 조용히 있음, 직접 말함, 한숨을 쉼'),
    ('일상에서의 분위기와 에너지 수준은 어떠했나요?', '항상 밝고 활기참, 조용하지만 따뜻함'),
    ('외모적 특징이나 자주 하던 행동 버릇이 있었나요?', '말할 때 손을 많이 씀'),
    ('즐겨 입던 옷 스타일이나 자주 쓰시던 향수/로션이 있었나요?', '항상 단정한 편, 꽃향기 나는 로션 쓰심'),
    ('가장 소중히 여기던 물건이나 즐겨 드시던 음식/음료가 있었나요?', '낡은 시계, 된장찌개, 믹스커피'),
    ('가족들을 부르는 호칭이 어떻게 되었나요?', '딸을 "우리 강아지", 아들을 "이 녀석"이라 부름'),
    ('주로 어떤 주제로 대화를 나누셨나요?', '건강, 날씨, 드라마, 손자손녀 이야기'),
    ('특별히 고집하거나 꼭 지키던 규칙이나 습관이 있었나요?', '밥은 꼭 같이 먹어야 한다'),
    ('자주 하시던 칭찬이나 격려의 말이 있었나요?', '"잘했어", "우리 딸 최고야"'),
    ('만났을 때나 헤어질 때 자주 하시던 말이 있었나요?', '"밥은 먹었나?", "잘 자라"'),
  ];

  late final List<TextEditingController> _controllers =
      List.generate(_questions.length, (_) => TextEditingController());

  PersonModel? get _person =>
      AppState.instance.people.where((p) => p.id == widget.personId).firstOrNull;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  Future<QuerySnapshot> _loadDailyAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid') ?? '';
    if (uid.isEmpty) return FirebaseFirestore.instance.collection('_empty').get();
    return FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('deceased').doc(widget.personId)
        .collection('daily_answers')
        .orderBy('createdAt', descending: false)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final p = _person;
    if (p == null) return const Scaffold(body: Center(child: Text('인물을 찾을 수 없습니다')));

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(children: [
                    Icon(Icons.chevron_left_rounded, color: _s400, size: 22),
                    Text('뒤로', style: TextStyle(fontSize: 13, color: _s400)),
                  ]),
                ),
                const Spacer(),
                // 사진 편집 버튼
                GestureDetector(
                  onTap: () => pickAndUpdateImage(p),
                  child: Container(
                    width: 34, height: 34,
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_outlined, size: 16, color: _s400),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              _Avatar(person: p, size: 70),
              const SizedBox(height: 10),
              Text(p.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _s800)),
              Text(p.relation,
                  style: const TextStyle(fontSize: 13, color: _s400)),
            ]),
          ),
          // ── Questions ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 32),
              child: Column(children: [
                ...List.generate(_questions.length, (i) {
                  final (q, hint) = _questions[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _border),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                            blurRadius: 8, offset: const Offset(0, 1))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: _blue100, shape: BoxShape.circle),
                            child: Center(child: Text('${i + 1}',
                                style: const TextStyle(fontSize: 11,
                                    fontWeight: FontWeight.w700, color: _blue500))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(q,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w600, color: _s700, height: 1.5))),
                        ]),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controllers[i],
                          minLines: 2, maxLines: null,
                          style: const TextStyle(fontSize: 14, color: _s700),
                          decoration: InputDecoration(
                            hintText: '예: $hint',
                            hintStyle: const TextStyle(color: _s400, fontSize: 13),
                            filled: true, fillColor: _bg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _divider)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _divider)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _blue400, width: 1.5)),
                          ),
                        ),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _s500,
                        side: const BorderSide(color: _divider),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('되돌아가기',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue500,
                        foregroundColor: Colors.white,
                        elevation: 0, shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('저장하기',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                FutureBuilder<QuerySnapshot>(
                  future: _loadDailyAnswers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                    final docs = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 8),
                        const Text('오늘의 질문 답변 기록',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _s700)),
                        const SizedBox(height: 10),
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(data['question'] ?? '',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _blue400)),
                              const SizedBox(height: 6),
                              Text(data['answer'] ?? '',
                                  style: const TextStyle(fontSize: 13, color: _s600)),
                            ]),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 답변 모아보기 화면
// ════════════════════════════════════════════════════════════════════════════
class AnswerSummaryScreen extends StatefulWidget {
  const AnswerSummaryScreen({super.key});

  @override
  State<AnswerSummaryScreen> createState() => _AnswerSummaryScreenState();
}

class _AnswerSummaryScreenState extends State<AnswerSummaryScreen> {
  static const _green50  = Color(0xFFF0FDF4);
  static const _green100 = Color(0xFFBBF7D0);
  static const _green500 = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final people = AppState.instance.people;
    final answered = people.where((p) => AppState.instance.hasAnswer(p.id)).toList();
    final pending  = people.where((p) => !AppState.instance.hasAnswer(p.id)).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(children: [
                  Icon(Icons.chevron_left_rounded, color: _s400, size: 22),
                  Text('뒤로', style: TextStyle(fontSize: 13, color: _s400)),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('답변 모아보기',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _s800)),
              const SizedBox(height: 4),
              Text('${answered.length}명 답변 완료 · ${pending.length}명 대기 중',
                  style: const TextStyle(fontSize: 13, color: _s400)),
            ]),
          ),

          // ── 진행률 바 ──
          if (people.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: people.isEmpty ? 0 : answered.length / people.length,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(_green500),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${people.isEmpty ? 0 : (answered.length / people.length * 100).round()}% 완료',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _green500)),
              ]),
            ),

          // ── 목록 ──
          Expanded(
            child: people.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.inbox_outlined, size: 48, color: _s400),
                      SizedBox(height: 12),
                      Text('아직 인물이 없습니다', style: TextStyle(fontSize: 14, color: _s400)),
                    ]),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 완료된 답변
                      if (answered.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(children: [
                            const Text('완료된 답변',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: _green500, letterSpacing: 0.5)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _green50, borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _green100),
                              ),
                              child: Text('${answered.length}',
                                  style: const TextStyle(fontSize: 10,
                                      fontWeight: FontWeight.w700, color: _green500)),
                            ),
                          ]),
                        ),
                        ...answered.map((p) => _AnswerCard(person: p, hasAnswer: true)),
                        const SizedBox(height: 20),
                      ],

                      // 미답변
                      if (pending.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(children: [
                            const Text('답변 대기',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: _s400, letterSpacing: 0.5)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text('${pending.length}',
                                  style: const TextStyle(fontSize: 10,
                                      fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                            ),
                          ]),
                        ),
                        ...pending.map((p) => _AnswerCard(person: p, hasAnswer: false)),
                      ],
                    ],
                  ),
          ),
        ]),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final PersonModel person;
  final bool hasAnswer;
  const _AnswerCard({required this.person, required this.hasAnswer});

  @override
  Widget build(BuildContext context) {
    final answer = AppState.instance.getAnswer(person.id);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PersonAnswerScreen(person: person))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: hasAnswer
              ? const Color(0xFFBBF7D0) : const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 인물 정보 행
          Row(children: [
            _Avatar(person: person, size: 36),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(person.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _s800)),
              const Text('상대방이 가장 좋아하는 음식은?',
                  style: TextStyle(fontSize: 11, color: _s400),
                  overflow: TextOverflow.ellipsis),
            ])),
            _StatusBadge(answered: hasAnswer),
          ]),

          // 답변 내용
          if (hasAnswer && answer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(answer,
                  style: const TextStyle(fontSize: 13, color: _s600, height: 1.5)),
            ),
          ] else if (!hasAnswer) ...[
            const SizedBox(height: 10),
            const Text('아직 답변이 없어요. 탭해서 답변해보세요.',
                style: TextStyle(fontSize: 12, color: _s400)),
          ],
        ]),
      ),
    );
  }
}
