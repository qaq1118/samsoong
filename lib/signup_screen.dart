import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const _apiKey = 'AIzaSyBas48myWR2JBRVnl0-yi39m6PvzDLKcAE';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = '모든 항목을 입력해주세요.');
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = '비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      // Firebase Auth REST API로 회원가입 (reCAPTCHA 없음)
      final res = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'returnSecureToken': true,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        String msg = '회원가입에 실패했습니다.';
        final code = data['error']?['message'] ?? '';
        if (code == 'EMAIL_EXISTS') msg = '이미 사용 중인 이메일입니다.';
        if (code == 'INVALID_EMAIL') msg = '올바른 이메일 형식이 아닙니다.';
        if (code == 'WEAK_PASSWORD : Password should be at least 6 characters') {
          msg = '비밀번호는 6자 이상이어야 합니다.';
        }
        setState(() => _errorMessage = msg);
        return;
      }

      final uid = data['localId'];

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // Firestore에 사용자 정보 저장
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'username': '@$name',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // SharedPreferences에도 캐싱
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', name);
      await prefs.setString('profile_email', email);
      await prefs.setString('profile_username', '@$name');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = '오류: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('가입하기',
                style: TextStyle(color: Color(0xFF1F2024), fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('시작하려면 계정을 생성하세요',
                style: TextStyle(color: Color(0xFF71727A), fontSize: 14)),
            const SizedBox(height: 32),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
              ),

            _buildInputField('이름', '이름을 입력하세요', controller: _nameController),
            const SizedBox(height: 16),
            _buildInputField('이메일 주소', 'name@email.com', controller: _emailController),
            const SizedBox(height: 16),
            _buildInputField('비밀번호', '비밀번호를 입력하세요 (6자 이상)', isPassword: true, controller: _passwordController),
            const SizedBox(height: 16),
            _buildInputField('비밀번호 확인', '비밀번호를 다시 입력하세요', isPassword: true, controller: _passwordConfirmController),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('가입하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint,
      {bool isPassword = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8F9098)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC5C6CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006FFD)),
            ),
          ),
        ),
      ],
    );
  }
}
