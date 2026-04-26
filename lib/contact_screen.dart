import 'package:flutter/material.dart';
import 'contact_screen2.dart';
import 'question.dart';
import 'chat.dart';
import 'setting.dart';
import 'call_log.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatSearchController = TextEditingController();
  String _chatSearchQuery = '';

  final List<String> _navTitles = ['연락처', '질문과 답변', '문자', '설정'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _chatSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: IndexedStack(
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
          ChatContent(searchQuery: _chatSearchQuery),
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
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF006FFD)),
            onPressed: () => setState(() => _isChatSearching = true),
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

  Widget _buildEmptyTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '아직 추억을 불러온 사람이 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xA01F2024),
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.09,
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
                '추억 불러오기',
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

  void _showSummonDialog() {    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('추억 불러오기'),
        content: const Text('소환할 고인의 정보를 입력해주세요.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인')),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        children: [
          _buildNavItem('연락처', Icons.contacts, 0),
          _buildNavItem('질문과 답변', Icons.help_outline, 1),
          _buildNavItem('문자', Icons.message_outlined, 2),
          _buildNavItem('설정', Icons.settings_outlined, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    final isActive = _selectedNavIndex == index;
    final color = isActive ? const Color(0xFF006FFD) : const Color(0xFF71727A);
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
        child: Container(
          height: 72,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
