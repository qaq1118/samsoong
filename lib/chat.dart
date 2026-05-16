import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatting.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: ChatContent(),
    );
  }
}

class ChatContent extends StatefulWidget {
  final String searchQuery;
  final bool isEditMode;
  final bool showSearchBar;
  final ValueChanged<bool>? onEditModeChanged;
  final VoidCallback? onSearchTap;

  const ChatContent({
    super.key,
    this.searchQuery = '',
    this.isEditMode = false,
    this.showSearchBar = true,
    this.onEditModeChanged,
    this.onSearchTap,
  });

  @override
  State<ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<ChatContent> {
  String? _uid;

  @override
  void initState() {
    super.initState();
    _initUid();
  }

  Future<void> _initUid() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (mounted) setState(() => _uid = uid);
  }

  void _deleteItem(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅 삭제'),
        content: const Text('채팅을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('예', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addItem() {}

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006FFD)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('deceased')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF006FFD)));
        }

        final allItems = (snapshot.data?.docs ?? []).map((d) {
          final data = d.data() as Map<String, dynamic>;
          return <String, String?>{
            'name': data['name'] as String? ?? '',
            'message': '',
            'badge': null,
          };
        }).toList();

        final query = widget.searchQuery.toLowerCase();
        final items = query.isEmpty
            ? allItems
            : allItems.where((item) =>
                item['name']!.toLowerCase().contains(query) ||
                item['message']!.toLowerCase().contains(query)).toList();

        if (items.isEmpty && widget.searchQuery.isNotEmpty) {
          return Column(
            children: [
              if (widget.showSearchBar) _buildSearchBar(),
              const Expanded(
                child: Center(
                  child: Text(
                    '검색 결과가 없습니다.',
                    style: TextStyle(color: Color(0xFF8F9098), fontSize: 16, fontFamily: 'Inter'),
                  ),
                ),
              ),
            ],
          );
        }

        if (items.isEmpty) {
          return Column(
            children: [
              if (widget.showSearchBar) _buildSearchBar(),
              const Expanded(
                child: Center(
                  child: Text(
                    '아직 추억을 불러온 분이 없습니다.',
                    style: TextStyle(color: Color(0xFF8F9098), fontSize: 15),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            if (widget.showSearchBar) _buildSearchBar(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length + (widget.isEditMode ? 1 : 0),
                itemBuilder: (context, index) {
                  if (widget.isEditMode && index == items.length) {
                    return _buildAddButton();
                  }
                  final item = items[index];
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
      },
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.search, color: Color(0xFF8F9098), size: 20),
              SizedBox(width: 8),
              Text(
                '검색',
                style: TextStyle(color: Color(0xFF8F9098), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: _addItem,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF006FFD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              '새 대화 추가',
              style: TextStyle(
                color: Color(0xFF006FFD),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(String name, String message, {String? badge}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.isEditMode
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Chat2(name: name)),
              ),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (widget.isEditMode) ...[
            GestureDetector(
              onTap: () => _deleteItem(name),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 10),
          ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF71727A),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isEditMode && badge != null)
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
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
