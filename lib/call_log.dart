import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallLogScreen extends StatelessWidget {
  const CallLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CallLogContent());
  }
}

class CallLogContent extends StatefulWidget {
  const CallLogContent({super.key});

  @override
  State<CallLogContent> createState() => _CallLogContentState();
}

class _CallLogContentState extends State<CallLogContent> {
  String? _uid;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _uid = prefs.getString('uid'));
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = h < 12 ? '오전' : '오후';
      final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$ampm $hour:$m';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      const days = ['월', '화', '수', '목', '금', '토', '일'];
      return '${days[dt.weekday - 1]}요일';
    } else {
      return '${dt.month}월 ${dt.day}일';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('call_logs')
          .orderBy('calledAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_off_outlined, size: 48, color: Color(0xFF94A3B8)),
                SizedBox(height: 12),
                Text('통화 기록이 없습니다.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF94A3B8))),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1, indent: 72, color: Color(0xFFF1F5F9)),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final name = data['name'] as String? ?? '';
            final calledAt = (data['calledAt'] as Timestamp?)?.toDate();
            final timeStr = calledAt != null ? _formatTime(calledAt) : '';
            final initial = name.isNotEmpty ? name[0] : '?';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              leading: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: Color(0xFF334155))),
                ),
              ),
              title: Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              subtitle: Row(children: [
                const Icon(Icons.videocam_rounded,
                    size: 14, color: Color(0xFF22C55E)),
                const SizedBox(width: 4),
                Text('영상통화',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(timeStr,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 8),
                  const Icon(Icons.videocam_rounded,
                      color: Color(0xFF3B82F6), size: 22),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
