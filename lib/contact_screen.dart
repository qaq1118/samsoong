import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_screen2.dart';
import 'question.dart';
import 'chat.dart';
import 'chatting.dart';
import 'setting.dart';
import 'call_log.dart';
import 'summon_screen.dart';
import 'app_state.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 0;
  bool _isSearching = false;
  bool _isChatSearching = false;
  bool _isChatEditMode = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatSearchController = TextEditingController();
  String _chatSearchQuery = '';
  String _contactSearchQuery = '';

  final List<String> _navTitles = ['연락처', '질문과 답변', '문자', '설정'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    AppState.instance.addListener(_rebuild);
    _loadFromFirestore();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_rebuild);
    _tabController.dispose();
    _searchController.dispose();
    _chatSearchController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _loadFromFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('deceased')
        .orderBy('createdAt', descending: false).get();
    for (final doc in snap.docs) {
      final data = doc.data();
      AppState.instance.addPersonFromFirestore(
        doc.id,
        data['name'] as String? ?? '',
        data['relation'] as String? ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _isSearching && _selectedNavIndex == 0
          ? _buildSearchAppBar()
          : _isChatSearching && _selectedNavIndex == 2
          ? _buildChatSearchAppBar()
          : _selectedNavIndex == 0
          ? _buildContactAppBar()
          : _selectedNavIndex == 2
          ? _buildChatAppBar()
          : _selectedNavIndex == 3
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
            )
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                _navTitles[_selectedNavIndex],
                style: const TextStyle(
                  color: Color(0xFF1F2024),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      body: (_isSearching && _selectedNavIndex == 0)
          ? _buildSearchResults()
          : IndexedStack(
        index: _selectedNavIndex,
        children: [
          // 0: 연락처
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildEmptyTab(),
              const CallLogContent(),
              _buildSummonTab(),
            ],
          ),
          // 1: Q&A
          QuestionContent(),
          // 2: 문자
          _isChatSearching
              ? ChatContent(searchQuery: _chatSearchQuery, isEditMode: false, showSearchBar: false)
              : ChatContent(searchQuery: _chatSearchQuery, isEditMode: _isChatEditMode, onEditModeChanged: (v) => setState(() => _isChatEditMode = v), onSearchTap: () => setState(() => _isChatSearching = true)),
          // 3: 설정
          SettingContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            _contactSearchQuery = '';
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (v) => setState(() => _contactSearchQuery = v),
        decoration: InputDecoration(
          hintText: '검색',
          hintStyle: const TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: const Color(0xFFF7F8FD),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF1F2024),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        '문자',
        style: TextStyle(
          color: Color(0xFF1F2024),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => setState(() => _isChatEditMode = !_isChatEditMode),
          child: Text(
            _isChatEditMode ? '완료' : '편집',
            style: const TextStyle(color: Color(0xFF006FFD), fontSize: 16),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildChatSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
        onPressed: () {
          setState(() {
            _isChatSearching = false;
            _chatSearchController.clear();
            _chatSearchQuery = '';
          });
        },
      ),
      title: TextField(
        controller: _chatSearchController,
        autofocus: true,
        onChanged: (value) => setState(() => _chatSearchQuery = value),
        decoration: InputDecoration(
          hintText: '검색',
          hintStyle: const TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: const Color(0xFFF7F8FD),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF1F2024),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  PreferredSizeWidget _buildContactAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF006FFD)),
              onPressed: () => setState(() => _isSearching = true),
            ),
          ),
        ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0x89006FFD),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: const Color(0xFF1F2024),
            unselectedLabelColor: const Color(0xFF71727A),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.transparent,
            onTap: (index) {
            },
            tabs: const [
              Tab(text: '연락처'),
              Tab(text: '통화기록'),
              Tab(text: '추억 불러오기'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final query = _contactSearchQuery.trim().toLowerCase();
    final people = query.isEmpty
        ? AppState.instance.people
        : AppState.instance.people
            .where((p) => p.name.toLowerCase().contains(query) ||
                p.relation.toLowerCase().contains(query))
            .toList();

    if (people.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? '검색어를 입력해주세요.' : '\'$_contactSearchQuery\'에 대한 결과가 없습니다.',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: people.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, i) {
          final p = people[i];
          return ListTile(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ContactDetailScreen(person: p))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: Container(
              width: 48, height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: p.imageBytes == null
                    ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [p.g1, p.g2])
                    : null,
              ),
              child: p.imageBytes != null
                  ? Image.memory(p.imageBytes!, fit: BoxFit.cover)
                  : Center(child: Text(p.initial,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                          color: Color(0xFF334155)))),
            ),
            title: Text(p.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B))),
            subtitle: Text(p.relation,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTab() {
    final people = AppState.instance.people;
    if (people.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_outline, size: 48, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text('아직 추억을 불러온 사람이 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: people.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, i) {
        final p = people[i];
        return ListTile(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ContactDetailScreen(person: p))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: Container(
            width: 48, height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: p.imageBytes == null
                  ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [p.g1, p.g2])
                  : null,
            ),
            child: p.imageBytes != null
                ? Image.memory(p.imageBytes!, fit: BoxFit.cover)
                : Center(child: Text(p.initial,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        color: Color(0xFF334155)))),
          ),
          title: Text(p.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B))),
          subtitle: Text(p.relation,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
        );
      },
    );
  }

  Widget _buildSummonTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '추억을 불러오세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xA01F2024),
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showSummonDialog(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: ShapeDecoration(
                color: const Color(0x89006FFD),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '+ 추억 불러오기',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSummonDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SummonScreen()),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildNavItem('연락처', Icons.contacts_outlined, Icons.contacts, 0),
              _buildNavItem('Q&A', Icons.help_outline_rounded, Icons.help_rounded, 1),
              _buildNavItem('문자', Icons.message_outlined, Icons.message_rounded, 2),
              _buildNavItem('설정', Icons.settings_outlined, Icons.settings_rounded, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, IconData activeIcon, int index) {
    final isActive = _selectedNavIndex == index;
    const activeColor = Color(0xFF3B82F6);
    const inactiveColor = Color(0xFF94A3B8);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedNavIndex = index;
          _isSearching = false;
          _searchController.clear();
          _isChatSearching = false;
          _chatSearchController.clear();
          _chatSearchQuery = '';
        }),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(color: activeColor, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 연락처 상세 화면 (전화번호부 스타일)
// ════════════════════════════════════════════════════════════════════════════
class ContactDetailScreen extends StatefulWidget {
  final PersonModel person;
  const ContactDetailScreen({super.key, required this.person});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  static const _bg     = Color(0xFFF8FAFC);
  static const _border = Color(0xFFF1F5F9);
  static const _s400   = Color(0xFF94A3B8);
  static const _s500   = Color(0xFF64748B);
  static const _s700   = Color(0xFF334155);
  static const _s800   = Color(0xFF1E293B);
  static const _blue   = Color(0xFF3B82F6);

  PersonModel get p => widget.person;
  Map<String, dynamic>? _firestoreData;

  @override
  void initState() {
    super.initState();
    _loadFirestoreData();
  }

  Future<void> _loadFirestoreData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('deceased').doc(p.id).get();
    if (doc.exists && mounted) setState(() => _firestoreData = doc.data());
  }

  Future<void> _logVideoCall() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('call_logs')
        .add({
      'name': p.name,
      'personId': p.id,
      'calledAt': FieldValue.serverTimestamp(),
      'type': 'video',
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      final bytes = await file.readAsBytes();
      AppState.instance.updatePersonImage(p.id, bytes);
      setState(() {});
    }
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _firestoreData;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(children: [
                      Icon(Icons.chevron_left_rounded, color: _s400, size: 22),
                      Text('연락처', style: TextStyle(fontSize: 13, color: _s400)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(children: [
                    Container(
                      width: 100, height: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: p.imageBytes == null
                            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                                colors: [p.g1, p.g2])
                            : null,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                            blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: p.imageBytes != null
                          ? Image.memory(p.imageBytes!, fit: BoxFit.cover)
                          : Center(child: Text(p.initial,
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: _s700))),
                    ),
                    Positioned(bottom: 0, right: 0,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: _blue, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _s800)),
                const SizedBox(height: 4),
                Text(p.relation, style: const TextStyle(fontSize: 14, color: _s400)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _actionButton(Icons.message_rounded, '메세지', _blue, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Chat2(name: p.name)));
                  }),
                  _actionButton(Icons.videocam_rounded, '영상통화', const Color(0xFF22C55E), () async {
                    await _logVideoCall();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.name}와 영상통화가 기록되었습니다.'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                    }
                  }),
                  _actionButton(Icons.edit_outlined, '사진 수정', _s500, _pickPhoto),
                ]),
              ]),
            ),

            const SizedBox(height: 12),

            // ── 기본 정보 카드 ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: Column(children: [
                _infoRow(Icons.favorite_outline_rounded, '관계', p.relation),
                if (d != null && (d['birth'] ?? '').toString().isNotEmpty) ...[
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _infoRow(Icons.cake_outlined, '생년월일', d['birth']),
                ],
                if (d != null && (d['nickname'] ?? '').toString().isNotEmpty) ...[
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _infoRow(Icons.person_outline_rounded, '호칭', d['nickname']),
                ],
                const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                _infoRow(Icons.help_outline_rounded, 'Q&A 질문 수', '15개'),
              ]),
            ),

            // ── 소개/입버릇 카드 ──
            if (d != null && ((d['intro'] ?? '').toString().isNotEmpty || (d['habits'] ?? '').toString().isNotEmpty)) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if ((d['intro'] ?? '').toString().isNotEmpty) ...[
                    const Text('소개', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _s400)),
                    const SizedBox(height: 6),
                    Text(d['intro'], style: const TextStyle(fontSize: 14, color: _s700, height: 1.5)),
                  ],
                  if ((d['intro'] ?? '').toString().isNotEmpty && (d['habits'] ?? '').toString().isNotEmpty)
                    const SizedBox(height: 14),
                  if ((d['habits'] ?? '').toString().isNotEmpty) ...[
                    const Text('입버릇/말투', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _s400)),
                    const SizedBox(height: 6),
                    Text(d['habits'], style: const TextStyle(fontSize: 14, color: _s700, height: 1.5)),
                  ],
                ]),
              ),
            ],
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: const Color(0xFF60A5FA)),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 14, color: _s500)),
        ),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _s700),
            textAlign: TextAlign.right)),
      ]),
    );
  }
}
