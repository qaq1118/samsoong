import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'login_screen.dart';
import 'profile.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<void> scheduleDailyNotification(TimeOfDay time) async {
  await flutterLocalNotificationsPlugin.cancelAll();

  final now = DateTime.now();
  var scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '오늘의 질문이 도착했어요 💬',
    '지금 바로 답변해보세요!',
    tz.TZDateTime.from(scheduled, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_question_channel',
        '오늘의 질문 알림',
        channelDescription: '매일 설정한 시간에 오늘의 질문 알림을 보냅니다',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> cancelNotification() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SettingContent(),
    );
  }
}

class SettingContent extends StatefulWidget {
  @override
  State<SettingContent> createState() => _SettingContentState();
}

class _SettingContentState extends State<SettingContent> {
  File? _profileImage;
  String _name = '최지우';
  String _username = '@okong';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? '최지우';
      _username = prefs.getString('profile_username') ?? '@okong';
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null) _profileImage = File(imagePath);
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF1F2024)),
              title: const Text('갤러리에서 선택',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  setState(() => _profileImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF1F2024)),
              title: const Text('카메라로 촬영',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  setState(() => _profileImage = File(picked.path));
                }
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFFF4949)),
                title: const Text('사진 삭제',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFFFF4949))),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _profileImage = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 프로필 섹션
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEAF2FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(44),
                          ),
                        ),
                        child: _profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(44),
                                child: Image.file(
                                  _profileImage!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFFB4DBFF),
                                  size: 56,
                                ),
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Frame()),
                            );
                            _loadProfile();
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF006FFD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _username,
                  style: const TextStyle(
                    color: Color(0xFF71727A),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 설정 메뉴 목록
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  title: '알림',
                  icon: Icons.notifications_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationSettingScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: '자주 묻는 질문',
                  icon: Icons.help_outline,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FaqScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: '개인정보 및 보안',
                  icon: Icons.lock_outline,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: '로그아웃',
                  icon: Icons.logout,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF1F2024),
    Color iconColor = const Color(0xFF8F9098),
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8F9098),
                    size: 20,
                  ),
              ],
            ),
          ),
          if (showArrow) const Divider(height: 1, color: Color(0xFFE5E5E5)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '로그아웃',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(
            color: Color(0xFF71727A),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF8F9098)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Color(0xFFFF4949)),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool _notificationEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('notification_enabled') ?? false;
      final hour = prefs.getInt('notification_hour') ?? 9;
      final minute = prefs.getInt('notification_minute') ?? 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', _notificationEnabled);
    await prefs.setInt('notification_hour', _selectedTime.hour);
    await prefs.setInt('notification_minute', _selectedTime.minute);

    if (_notificationEnabled) {
      await scheduleDailyNotification(_selectedTime);
    } else {
      await cancelNotification();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006FFD),
              onSurface: Color(0xFF1F2024),
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      await _saveSettings();
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? '오전' : '오후';
    return '$period $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E9F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.help_outline, color: Color(0xFF006FFD), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '오늘의 질문 알림',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2024),
                          ),
                        ),
                      ),
                      Switch(
                        value: _notificationEnabled,
                        activeColor: const Color(0xFF006FFD),
                        onChanged: (val) async {
                          setState(() => _notificationEnabled = val);
                          await _saveSettings();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '매일 설정한 시간에 오늘의 질문 알림을 받아보세요',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8F9098)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_notificationEnabled) ...[
              const Text(
                '알림 시간',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2024),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF006FFD), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF006FFD), size: 22),
                      const SizedBox(width: 12),
                      Text(
                        _formatTime(_selectedTime),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2024),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '시간 변경',
                        style: TextStyle(fontSize: 13, color: Color(0xFF006FFD)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF006FFD), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '매일 ${_formatTime(_selectedTime)}에 알림이 전송됩니다',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF006FFD)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'RE:Born은 어떤 서비스인가요?',
      'a': 'RE:Born은 고인의 말투, 성향, 추억을 바탕으로 AI와 대화할 수 있는 서비스입니다. 소중한 분과의 기억을 간직하고 싶을 때 활용해보세요.',
    },
    {
      'q': '추억 불러오기는 어떻게 하나요?',
      'a': '연락처 탭의 "추억 불러오기"에서 기본 질문 입력 또는 사진·음성·텍스트 파일을 업로드하여 고인의 정보를 등록할 수 있습니다.',
    },
    {
      'q': '업로드한 데이터는 안전한가요?',
      'a': '업로드된 모든 데이터는 암호화되어 안전하게 저장되며, 서비스 운영 외 목적으로 사용되지 않습니다.',
    },
    {
      'q': '오늘의 질문 알림은 어떻게 설정하나요?',
      'a': '설정 → 알림에서 스위치를 켜고 원하는 시간을 선택하면 매일 해당 시간에 알림이 전송됩니다.',
    },
    {
      'q': '프로필 정보를 수정하고 싶어요.',
      'a': '설정 화면에서 프로필 사진 옆의 편집 버튼을 눌러 이름과 아이디를 변경할 수 있습니다.',
    },
    {
      'q': '계정을 삭제하려면 어떻게 하나요?',
      'a': '설정 → 개인정보 및 보안 → 썸원 탈퇴하기를 통해 계정을 삭제할 수 있습니다. 탈퇴 시 모든 데이터가 영구 삭제됩니다.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '자주 묻는 질문',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE5E5E5)),
        itemBuilder: (context, i) {
          return _FaqTile(q: _faqs[i]['q']!, a: _faqs[i]['a']!);
        },
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String q;
  final String a;
  const _FaqTile({required this.q, required this.a});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Q', style: TextStyle(color: Color(0xFF006FFD), fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.q,
                    style: const TextStyle(color: Color(0xFF1F2024), fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8F9098),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('A', style: TextStyle(color: Color(0xFF8F9098), fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.a,
                        style: const TextStyle(color: Color(0xFF1F2024), fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '썸원 탈퇴',
          style: TextStyle(color: Color(0xFF1F2024), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '탈퇴하시면 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠습니까?',
          style: TextStyle(color: Color(0xFF71727A), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF8F9098))),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('탈퇴하기', style: TextStyle(color: Color(0xFFFF4949))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '개인정보 및 보안',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            InkWell(
              onTap: () => _showWithdrawDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, color: Color(0xFFFF4949), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '썸원 탈퇴하기',
                        style: TextStyle(
                          color: Color(0xFFFF4949),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF8F9098), size: 20),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '준비 중입니다.',
          style: TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
