import 'dart:typed_data';
import 'package:flutter/material.dart';

// ── 인물 모델 ─────────────────────────────────────────────────────────────────
class PersonModel {
  final String id;
  final String name;
  final String relation;
  Uint8List? imageBytes;
  final Color g1, g2;

  PersonModel({
    required this.id,
    required this.name,
    required this.relation,
    this.imageBytes,
    required this.g1,
    required this.g2,
  });

  String get initial => name.isNotEmpty ? name[0] : '?';
}

// ── 그라데이션 팔레트 (인물 추가 순서대로 자동 배정) ──────────────────────────────
const _kGradients = [
  (Color(0xFFC7D2FE), Color(0xFFA5B4FC)),
  (Color(0xFFFDE68A), Color(0xFFFCA5A5)),
  (Color(0xFFA7F3D0), Color(0xFF6EE7B7)),
  (Color(0xFFFBCFE8), Color(0xFFF9A8D4)),
  (Color(0xFFBFDBFE), Color(0xFF93C5FD)),
  (Color(0xFFDDD6FE), Color(0xFFC4B5FD)),
  (Color(0xFFFED7AA), Color(0xFFFBBF24)),
  (Color(0xFFBBF7D0), Color(0xFF6EE7B7)),
];

// ── 앱 전역 상태 (싱글턴) ────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  final List<PersonModel> _people = [];
  List<PersonModel> get people => List.unmodifiable(_people);

  // 인물별 오늘의 질문 답변 저장
  final Map<String, String> _answers = {};

  // ── 인물 추가 ──
  void addPerson(String name, String relation) {
    final idx = _people.length % _kGradients.length;
    final (g1, g2) = _kGradients[idx];
    _people.add(PersonModel(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_people.length}',
      name: name,
      relation: relation,
      g1: g1,
      g2: g2,
    ));
    notifyListeners();
  }

  // ── 인물 사진 업데이트 ──
  void updatePersonImage(String id, Uint8List bytes) {
    final idx = _people.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _people[idx].imageBytes = bytes;
      notifyListeners();
    }
  }

  // ── 오늘의 질문 답변 저장/조회 ──
  void saveAnswer(String personId, String answer) {
    _answers[personId] = answer;
    notifyListeners();
  }

  String getAnswer(String personId) => _answers[personId] ?? '';
  bool hasAnswer(String personId) => (_answers[personId] ?? '').isNotEmpty;

  // ── Firestore에서 불러온 인물 추가 (중복 방지) ──
  void addPersonFromFirestore(String firestoreId, String name, String relation) {
    if (_people.any((p) => p.id == firestoreId)) return;
    final idx = _people.length % _kGradients.length;
    final (g1, g2) = _kGradients[idx];
    _people.add(PersonModel(
      id: firestoreId,
      name: name,
      relation: relation,
      g1: g1,
      g2: g2,
    ));
    notifyListeners();
  }
}
