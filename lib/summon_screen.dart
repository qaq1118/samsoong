import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

// 1. 선택 화면
class SummonScreen extends StatelessWidget {
  const SummonScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '추억 불러오기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              '원하시는 방법을 선택해주세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            // 기본 질문 박스
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuestionFormScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF006FFD), width: 1.5),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.question_answer_outlined, color: Color(0xFF006FFD), size: 36),
                    SizedBox(height: 16),
                    Text(
                      '기본 질문',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '고인에 대한 기본 정보를\n질문을 통해 입력합니다',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 데이터 업로드 박스
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadFormScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF006FFD), width: 1.5),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: Color(0xFF006FFD), size: 36),
                    SizedBox(height: 16),
                    Text(
                      '데이터 업로드',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '사진, 음성, 텍스트 파일을\n직접 업로드합니다',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
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
}

// 2. 기본 질문 화면
class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key});

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  String _relation = '부모님';
  final List<String> _relations = ['부모님', '자녀', '친인척', '친구', '기타'];
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _introController = TextEditingController();
  final _habitsController = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('고인의 이름을 입력해주세요.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('deceased')
          .add({
        'name': _nameController.text.trim(),
        'birth': _birthController.text.trim(),
        'relation': _relation,
        'nickname': _nicknameController.text.trim(),
        'intro': _introController.text.trim(),
        'habits': _habitsController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'question_form',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장되었습니다!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('기본 질문', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('몇 가지 질문에 답변해주세요',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 24),

            _label('고인의 이름'),
            _textField(_nameController, '예: 홍길동'),
            const SizedBox(height: 20),

            _label('생년월일'),
            _textField(_birthController, '예: 1950.01.01', inputType: TextInputType.datetime),
            const SizedBox(height: 20),

            _label('고인과의 관계'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _relation,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                items: _relations.map((r) =>
                    DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.black)))).toList(),
                onChanged: (v) => setState(() => _relation = v!),
              ),
            ),
            const SizedBox(height: 20),

            _label('당신을 부르는 호칭'),
            _textField(_nicknameController, '예: 우리딸, 지은아, 강아지'),
            const SizedBox(height: 20),

            _label('고인에 대해서 소개해주세요'),
            _textField(_introController, '고인의 성장, 배경 사용자님과의 추억..', minLines: 4),
            const SizedBox(height: 20),

            _label('기억나는 입버릇/말투'),
            _textField(_habitsController, '아이고 고맙다,"~~했나?","밥 묵었나?"', minLines: 3),
            const SizedBox(height: 40),

            // 버튼
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
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x89006FFD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('저장하기', style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
      );

  Widget _textField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text, int minLines = 1}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: inputType,
      minLines: minLines,
      maxLines: null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

// 3. 데이터 업로드 화면
class UploadFormScreen extends StatefulWidget {
  const UploadFormScreen({super.key});

  @override
  State<UploadFormScreen> createState() => _UploadFormScreenState();
}

class _UploadFormScreenState extends State<UploadFormScreen> {
  final List<File> _photos = [];
  final List<File> _audios = [];
  final _textController = TextEditingController();

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
    );
    if (result != null) {
      setState(() {
        _photos.addAll(result.paths.whereType<String>().map((p) => File(p)));
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'mp4', 'mov'],
    );
    if (result != null) {
      setState(() {
        _audios.addAll(result.paths.whereType<String>().map((p) => File(p)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('데이터 업로드', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('사진 (얼굴이 잘 드러나 있는 영상 또는 사진 5장 이상)',
                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _photos.isEmpty
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.cloud_upload_outlined, color: Colors.black38, size: 36),
                        SizedBox(height: 8),
                        Text('업로드를 위해 파일을 클릭 혹은 드래그하세요',
                            style: TextStyle(color: Colors.black38, fontSize: 13)),
                      ])
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _photos.map((f) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(f, width: 60, height: 60, fit: BoxFit.cover))).toList(),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('음성 (상대방과의 통화녹음, 영상 소리 등)',
                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickAudio,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _audios.isEmpty
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.cloud_upload_outlined, color: Colors.black38, size: 36),
                        SizedBox(height: 8),
                        Text('업로드를 위해 파일을 클릭 혹은 드래그하세요',
                            style: TextStyle(color: Colors.black38, fontSize: 13)),
                      ])
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _audios.map((f) => Text(f.path.split('/').last,
                              style: const TextStyle(color: Colors.black54, fontSize: 12))).toList(),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('텍스트 (상대방의 말투, 성향 파악을 위함)',
                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: '눌러서 정보 입력하기.......',
                  hintStyle: TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 버튼
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
