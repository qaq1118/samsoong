import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 96,
                child: Container(
                  width: 375,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECENT SEARCHES',
                              style: TextStyle(
                                color: const Color(0xFF71727A),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildRecentItem('인물2'),
                      _buildRecentItem('인물1'),
                      _buildRecentItem('인물3'),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 54,
                child: Container(
                  width: 343,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF7F8FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 16,
                    children: [
                      const Icon(Icons.search, color: Color(0xFF006FFD), size: 16),
                      Expanded(
                        child: Text(
                          '인물',
                          style: TextStyle(
                            color: const Color(0xFF1F2024),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 521,
                child: Container(
                  width: 375,
                  decoration: BoxDecoration(color: const Color(0xFFD2D3D8)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 220,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 3,
                                    top: 8,
                                    child: Container(
                                      width: 369,
                                      height: 150,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: _buildKeyboardRow([
                                              'ㅂ','ㅈ','ㄷ','ㄱ','ㅅ','ㅛ','ㅕ','ㅑ','ㅐ','ㅔ',
                                            ], widths: [32,31,32,31,32,31,31,32,31,32]),
                                          ),
                                          Positioned(
                                            left: 19.5,
                                            top: 54,
                                            child: _buildKeyboardRow([
                                              'ㅁ','ㄴ','ㅇ','ㄹ','ㅎ','ㅗ','ㅓ','ㅏ','ㅣ',
                                            ], widths: [32,30,32,32,30,32,32,30,32]),
                                          ),
                                          Positioned(
                                            left: 0,
                                            top: 108,
                                            child: SizedBox(
                                              width: 369,
                                              height: 42,
                                              child: Row(
                                                children: [
                                                  _buildSpecialKey(44),
                                                  const SizedBox(width: 14),
                                                  ..._buildKeyList(['ㅋ','ㅌ','ㅊ','ㅍ','ㅠ','ㅜ','ㅡ'],
                                                    widths: [31,31,31,30,31,31,31]),
                                                  const SizedBox(width: 14),
                                                  _buildSpecialKey(44),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 3,
                                    top: 170,
                                    child: SizedBox(
                                      width: 369,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 6,
                                        children: [
                                          _buildSpecialKey(42),
                                          _buildSpecialKey(43),
                                          Expanded(
                                            child: Container(
                                              height: 42,
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                shadows: [
                                                  BoxShadow(color: Color(0x4C000000), blurRadius: 0, offset: Offset(0, 1)),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Text('스페이스',
                                                  style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Apple SD Gothic Neo'),
                                                ),
                                              ),
                                            ),
                                          ),
                                          _buildSpecialKey(91),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 71,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 117,
                                    top: 58,
                                    child: Container(
                                      width: 138,
                                      height: 5,
                                      decoration: ShapeDecoration(
                                        color: Colors.black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItem(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF1F2024),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          const Icon(Icons.close, size: 12, color: Color(0xFF8F9098)),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, {required List<int> widths}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(keys.length, (i) {
        return Row(
          children: [
            Container(
              width: widths[i].toDouble(),
              height: 42,
              padding: const EdgeInsets.only(top: 2),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                shadows: [BoxShadow(color: Color(0x4C000000), blurRadius: 0, offset: Offset(0, 1))],
              ),
              child: Center(
                child: Text(keys[i],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Apple SD Gothic Neo'),
                ),
              ),
            ),
            if (i < keys.length - 1) const SizedBox(width: 6),
          ],
        );
      }),
    );
  }

  List<Widget> _buildKeyList(List<String> keys, {required List<int> widths}) {
    return List.generate(keys.length, (i) {
      return Row(children: [
        Container(
          width: widths[i].toDouble(),
          height: 42,
          padding: const EdgeInsets.only(top: 2),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            shadows: [BoxShadow(color: Color(0x4C000000), blurRadius: 0, offset: Offset(0, 1))],
          ),
          child: Center(
            child: Text(keys[i],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Apple SD Gothic Neo'),
            ),
          ),
        ),
        if (i < keys.length - 1) const SizedBox(width: 6),
      ]);
    });
  }

  Widget _buildSpecialKey(double width) {
    return Container(
      width: width,
      height: 42,
      decoration: ShapeDecoration(
        color: const Color(0xFFABB0BC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        shadows: [BoxShadow(color: Color(0x4C000000), blurRadius: 0, offset: Offset(0, 1))],
      ),
    );
  }
}
