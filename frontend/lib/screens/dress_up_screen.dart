import 'package:flutter/material.dart';

class DressUpScreen extends StatefulWidget {
  const DressUpScreen({super.key});

  @override
  State<DressUpScreen> createState() => _DressUpScreenState();
}

class _DressUpScreenState extends State<DressUpScreen> {
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color textDark = Color(0xFF2E2440);

  int selectedBackgroundIndex = 0;
  bool isBgmOn = false;

  final Map<String, String> selectedItemsByCategory = {};

  final List<List<Color>> backgrounds = const [
    [Color(0xFFFFD9EC), Color(0xFFFFF6FB)],
    [Color(0xFFD7F1FF), Color(0xFFFFF8E7)],
    [Color(0xFFE7DCFF), Color(0xFFFFF8F0)],
  ];

  String get selectedItemText {
    if (selectedItemsByCategory.isEmpty) {
      return '아이템을 골라 수룡이를 꾸며보세요!';
    }

    return selectedItemsByCategory.values.join(' · ');
  }

  void toggleItem({
    required String category,
    required String label,
  }) {
    setState(() {
      if (selectedItemsByCategory[category] == label) {
        selectedItemsByCategory.remove(category);
      } else {
        selectedItemsByCategory[category] = label;
      }
    });
  }
  void wearItem({
  required String category,
  required String label,
  }) {
    setState(() {
      selectedItemsByCategory[category] = label;
    });
  }

  void resetItems() {
    setState(() {
      selectedItemsByCategory.clear();
    });
  }
  void completeDressUp() {
    final outfitText = selectedItemsByCategory.isEmpty
        ? '아직 선택한 아이템이 없어요.'
        : selectedItemsByCategory.values.join(' · ');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '수룡이 스타일 완성!',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: sungshinViolet,
            ),
          ),
          content: Text(
            outfitText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: sungshinViolet,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgrounds[selectedBackgroundIndex];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bg,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildTopBar(context),
              _buildTitle(),
              _buildDressUpArea(),
              _buildSelectedItemBox(),
              _buildBottomBackgroundButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 18,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: sungshinViolet.withOpacity(0.18),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 23,
                color: sungshinViolet,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isBgmOn = !isBgmOn;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: sungshinViolet.withOpacity(0.18),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isBgmOn
                        ? Icons.music_note_rounded
                        : Icons.music_off_rounded,
                    size: 20,
                    color: sungshinViolet,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBgmOn ? 'BGM ON' : 'BGM OFF',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: sungshinViolet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Positioned(
      top: 82,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            '수룡이 꾸미기',
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w900,
              color: textDark,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '여름 아이템을 골라주세요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: sungshinBrightViolet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDressUpArea() {
    return Positioned.fill(
      top: 145,
      bottom: 175,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 26,
            left: 24,
            child: _buildClothItem(
                    icon: Icons.checkroom_rounded,
                    label: '나시',
                    category: '상의',
                  ),
          ),
          Positioned(
            top: 112,
            left: 16,
            child: _buildClothItem(
                icon: Icons.dry_cleaning_rounded,
                label: '반팔',
                category: '상의',
              ),
          ),
          Positioned(
            bottom: 88,
            left: 30,
            child: _buildClothItem(
                icon: Icons.water_drop_rounded,
                label: '장화',
                category: '신발',
              ),
          ),
          Positioned(
            top: 24,
            right: 28,
            child: _buildClothItem(
              icon: Icons.wb_sunny_rounded,
              label: '선글라스',
              category: '악세사리',
            ),
          ),
          Positioned(
            top: 112,
            right: 18,
            child: _buildClothItem(
                icon: Icons.sports_baseball_rounded,
                label: '모자',
                category: '악세사리',
              ),
          ),
          Positioned(
            bottom: 88,
            right: 30,
            child: _buildClothItem(
              icon: Icons.style_rounded,
              label: '치마',
              category: '하의',
            ),
          ),
          Positioned(
            bottom: 14,
            left: 95,
            child: _buildClothItem(
              icon: Icons.short_text_rounded,
              label: '반바지',
              category: '하의',
            ),
          ),
          Positioned(
            bottom: 14,
            right: 95,
            child: _buildClothItem(
              icon: Icons.snowshoeing_rounded,
              label: '신발',
              category: '신발',
            ),
          ),

          Positioned(
            bottom: 45,
            child: Container(
              width: 255,
              height: 315,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),

        Positioned(
          bottom: 45,
          child: DragTarget<Map<String, String>>(
            onAcceptWithDetails: (details) {
              final item = details.data;

              wearItem(
                category: item['category']!,
                label: item['label']!,
              );
            },

            builder: (context, candidateData, rejectedData) {
              final bool isHovering = candidateData.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.all(isHovering ? 10 : 0),
                decoration: BoxDecoration(
                  color: isHovering
                      ? Colors.white.withOpacity(0.34)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isHovering
                      ? [
                          BoxShadow(
                            color: sungshinViolet.withOpacity(0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Image.asset(
                  'assets/characters/dragon_base.png',
                  width: 235,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
        ],
      ),
    );
  }
  Widget _buildClothItem({
    required IconData icon,
    required String label,
    required String category,
  }) {
    final bool isSelected = selectedItemsByCategory[category] == label;

    Widget itemCard({bool isDragging = false}) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: isSelected ? 82 : 76,
        height: isSelected ? 82 : 76,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFF0FA)
              : Colors.white.withOpacity(isDragging ? 0.95 : 0.9),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected ? sungshinViolet : Colors.white,
            width: isSelected ? 2.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sungshinViolet.withOpacity(isSelected ? 0.22 : 0.09),
              blurRadius: isSelected ? 20 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: sungshinViolet,
                    size: 29,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: sungshinViolet,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Draggable<Map<String, String>>(
      data: {
        'category': category,
        'label': label,
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.08,
          child: itemCard(isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: itemCard(),
      ),
      child: GestureDetector(
        onTap: () {
          toggleItem(
            category: category,
            label: label,
          );
        },
        child: itemCard(),
      ),
    );
  }

  Widget _buildWearingPreview() {
    if (selectedItemsByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 82,
      child: IgnorePointer(
        child: Column(
          children: [
            if (selectedItemsByCategory['상의'] != null)
              _buildWearingTag(
                category: '상의',
                label: selectedItemsByCategory['상의']!,
              ),
            if (selectedItemsByCategory['하의'] != null)
              _buildWearingTag(
                category: '하의',
                label: selectedItemsByCategory['하의']!,
              ),
            if (selectedItemsByCategory['신발'] != null)
              _buildWearingTag(
                category: '신발',
                label: selectedItemsByCategory['신발']!,
              ),
            if (selectedItemsByCategory['악세사리'] != null)
              _buildWearingTag(
                category: '악세사리',
                label: selectedItemsByCategory['악세사리']!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWearingTag({
    required String category,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sungshinViolet.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$category · $label',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: sungshinViolet,
        ),
      ),
    );
  }
  Widget _buildSelectedItemBox() {
    final bool hasSelectedItems = selectedItemsByCategory.isNotEmpty;

    return Positioned(
      left: 28,
      right: 28,
      bottom: 110,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: sungshinViolet.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: sungshinViolet.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedItemText,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: sungshinViolet,
                ),
              ),
            ),

            if (hasSelectedItems) ...[
              const SizedBox(width: 8),

              GestureDetector(
                onTap: resetItems,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFFA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: sungshinViolet,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '다시',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: sungshinViolet,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              GestureDetector(
                onTap: completeDressUp,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sungshinViolet,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildBottomBackgroundButtons() {
    return Positioned(
      left: 22,
      right: 22,
      bottom: 26,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: sungshinViolet.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildBackgroundButton(0, '핑크룸'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBackgroundButton(1, '해변가'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBackgroundButton(2, '파니룸'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundButton(int index, String label) {
    final bool isSelected = selectedBackgroundIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBackgroundIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? sungshinViolet : const Color(0xFFF3EFFA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : sungshinViolet,
            ),
          ),
        ),
      ),
    );
  }
}