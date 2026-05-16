import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Frame extends StatefulWidget {
  const Frame({super.key});

  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _gender = '여자';
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences에서 즉시 로드 (캐시된 값)
    if (mounted) {
      setState(() {
        _nameController.text = prefs.getString('profile_name') ?? '';
        _emailController.text = prefs.getString('profile_email') ?? '';
        _phoneController.text = prefs.getString('profile_phone') ?? '';
        _gender = prefs.getString('profile_gender') ?? '여자';
        final bday = prefs.getString('profile_birthday');
        if (bday != null) _birthday = DateTime.tryParse(bday);
      });
    }
    // Firestore에서 최신 값으로 덮어쓰기
    final uid = prefs.getString('uid');
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final name = doc.data()?['name'] ?? '';
        final email = doc.data()?['email'] ?? '';
        setState(() {
          if (name.isNotEmpty) _nameController.text = name;
          if (email.isNotEmpty) _emailController.text = email;
        });
        // 캐시 갱신
        if (name.isNotEmpty) await prefs.setString('profile_name', name);
        if (email.isNotEmpty) await prefs.setString('profile_email', email);
      }
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text.trim());
    await prefs.setString('profile_phone', _phoneController.text.trim());
    await prefs.setString('profile_email', _emailController.text.trim());
    await prefs.setString('profile_gender', _gender);
    if (_birthday != null) await prefs.setString('profile_birthday', _birthday!.toIso8601String());
    // Firestore에도 업데이트
    final uid = prefs.getString('uid');
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'username': '@${_nameController.text.trim()}',
      });
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  String get _birthdayText {
    if (_birthday == null) return '';
    return '${_birthday!.month.toString().padLeft(2, '0')}/${_birthday!.day.toString().padLeft(2, '0')}/${_birthday!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름
            _buildLabel('이름'),
            _buildTextField(_nameController, hint: 'John Lennon'),
            const SizedBox(height: 16),

            // 번호
            _buildLabel('번호'),
            _buildPhoneField(),
            const SizedBox(height: 16),

            // 성
            _buildLabel('성'),
            _buildGenderDropdown(),
            const SizedBox(height: 16),

            // 생년월일
            _buildLabel('생년월일'),
            _buildDateField(),
            const SizedBox(height: 16),

            // 이메일
            _buildLabel('이메일'),
            _buildTextField(_emailController, hint: 'hello@mail.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 40),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF006FFD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      '이전',
                      style: TextStyle(color: Color(0xFF006FFD), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006FFD),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF71727A),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF1F2024), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8F9098)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E9F1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E9F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006FFD)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E9F1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: const [
                Text('🇰🇷', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text('(+82)', style: TextStyle(color: Color(0xFF71727A), fontSize: 14)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE8E9F1)),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Color(0xFF1F2024), fontSize: 15),
              decoration: const InputDecoration(
                hintText: '1234 5678',
                hintStyle: TextStyle(color: Color(0xFF8F9098)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E9F1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFF1F2024), fontSize: 15),
          items: const [
            DropdownMenuItem(value: '여자', child: Text('여자')),
            DropdownMenuItem(value: '남자', child: Text('남자')),
            DropdownMenuItem(value: '기타', child: Text('기타')),
          ],
          onChanged: (v) => setState(() => _gender = v!),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8E9F1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _birthdayText.isEmpty ? '생년월일 선택' : _birthdayText,
                style: TextStyle(
                  color: _birthdayText.isEmpty ? const Color(0xFF8F9098) : const Color(0xFF1F2024),
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF71727A), size: 18),
          ],
        ),
      ),
    );
  }
}
