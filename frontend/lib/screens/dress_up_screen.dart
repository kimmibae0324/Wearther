import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DressUpScreen extends StatefulWidget {
  const DressUpScreen({super.key});

  @override
  State<DressUpScreen> createState() => _DressUpScreenState();
}

class _DressUpScreenState extends State<DressUpScreen> {
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color textDark = Color(0xFF2E2440);

  @override
  void initState() {
    super.initState();
    loadSavedDressUp();
  }

  Future<void> loadSavedDressUp() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedItemsByCategory['상의'] = prefs.getString('dressup_top') ?? '';
      selectedItemsByCategory['하의'] = prefs.getString('dressup_bottom') ?? '';
      selectedItemsByCategory['신발'] = prefs.getString('dressup_shoes') ?? '';
      selectedItemsByCategory['모자'] = prefs.getString('dressup_hat') ?? '';
      selectedItemsByCategory['선글라스'] = prefs.getString('dressup_sunglasses') ?? '';
      selectedBackgroundIndex = prefs.getInt('dressup_background_index') ?? 0;
      
      selectedItemsByCategory.removeWhere((key, value) => value.isEmpty);
    });
  }

  int selectedBackgroundIndex = 0;
  bool isBgmOn = false;

  final Map<String, String> selectedItemsByCategory = {};

  final List<List<Color>> backgrounds = const [
    [Color(0xFFFFD9EC), Color(0xFFFFF6FB)],
    [Color(0xFFD7F1FF), Color(0xFFFFF8E7)],
    [Color(0xFFE7DCFF), Color(0xFFFFF8F0)],
  ];

  String get selectedBackgroundImagePath {
    switch (selectedBackgroundIndex) {
      case 0:
        return 'assets/dressup/background_pink_room.png';
      case 1:
        return 'assets/dressup/background_star_stage.png';
      case 2:
        return 'assets/dressup/background_summer_beach.png';
      default:
        return 'assets/dressup/background_pink_room.png';
    }
  }

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

  Future<void> saveDressUp() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('dressup_top', selectedItemsByCategory['상의'] ?? '');
    await prefs.setString('dressup_bottom', selectedItemsByCategory['하의'] ?? '');
    await prefs.setString('dressup_shoes', selectedItemsByCategory['신발'] ?? '');
    await prefs.setString('dressup_hat', selectedItemsByCategory['모자'] ?? '');
    await prefs.setString('dressup_sunglasses', selectedItemsByCategory['선글라스'] ?? '');
    await prefs.setInt('dressup_background_index', selectedBackgroundIndex);
  }

  void resetItems() {
    setState(() {
      selectedItemsByCategory.clear();
    });
  }
  String? getSelectedImagePath(String category) {
    final label = selectedItemsByCategory[category];

    switch (label) {
      case '나시 1':
        return 'assets/dressup/top_sleeveless_white_lace.png';
      case '나시 2':
        return 'assets/dressup/top_sleeveless_pink_stripe.png';
      case '반팔 1':
        return 'assets/dressup/top_tshirt_blue_stripe.png';
      case '반팔 2':
        return 'assets/dressup/top_tshirt_pink_button.png';

      case '반바지 1':
        return 'assets/dressup/bottom_shorts_gray_sport.png';
      case '반바지 2':
        return 'assets/dressup/bottom_shorts_black_denim.png';
      case '치마 1':
        return 'assets/dressup/bottom_skirt_gray_ruffle.png';
      case '치마 2':
        return 'assets/dressup/bottom_skirt_denim_mini.png';

      case '신발':
        return 'assets/dressup/shoes_black_high_top.png';
      case '장화':
        return 'assets/dressup/shoes_navy_rain_boots.png';

      case '모자':
        return 'assets/dressup/accessory_pink_snapback.png';
      case '선글라스':
        return 'assets/dressup/accessory_black_sunglasses.png';
    }

    return null;
  }

Widget _buildWearingLayer({
  required String category,
  required double top,
  required double width,
  double height = 80,
  double offsetX = 0,
}) {
  final label = selectedItemsByCategory[category];
  final imagePath = getSelectedImagePath(category);

  if (imagePath == null || label == null) {
    return const SizedBox.shrink();
  }

  double adjustedTop = top;
  double adjustedWidth = width;
  double adjustedHeight = height;
  double adjustedOffsetX = offsetX;
  double adjustedRotation = 0;

  switch (label) {
    case '모자':
      adjustedTop = -4;
      adjustedWidth = 100;
      adjustedHeight = 60;
      break;

    case '선글라스':
      adjustedTop = 30;
      adjustedWidth = 78;
      adjustedHeight = 42;
      adjustedRotation = -0.08;
      break;

    case '나시 1':
      adjustedTop = 66;
      adjustedWidth = 70;
      adjustedHeight = 82;
      break;

    case '나시 2':
      adjustedTop = 66;
      adjustedWidth = 72;
      adjustedHeight = 84;
      break;

    case '반팔 1':
      adjustedTop = 70;
      adjustedWidth = 82;
      adjustedHeight = 88;
      break;

    case '반팔 2':
      adjustedTop = 64;
      adjustedWidth = 78;
      adjustedHeight = 86;
      break;

    case '반바지 1':
      adjustedTop = 121;
      adjustedWidth = 90;
      adjustedHeight = 78;
      break;

    case '반바지 2':
      adjustedTop = 121;
      adjustedWidth = 90;
      adjustedHeight = 78;
      break;

    case '치마 1':
      adjustedTop = 120;
      adjustedWidth = 76;
      adjustedHeight = 80;
      adjustedOffsetX = 0;
      adjustedRotation =-0.02;
      break;

    case '치마 2':
      adjustedTop = 122;
      adjustedWidth = 88;
      adjustedHeight = 76;
      adjustedOffsetX = 0;
      adjustedRotation = -0.01;
      break;

    case '신발':
      adjustedTop = 282;
      adjustedWidth = 58;
      adjustedHeight = 44;
      break;

    case '장화':
      adjustedTop = 276;
      adjustedWidth = 62;
      adjustedHeight = 56;
      break;
  }

  return Positioned(
    top: adjustedTop,
    left: (235 - adjustedWidth) / 2 + adjustedOffsetX,
    child: Transform.rotate(
      angle: adjustedRotation,
      child: Image.asset(
        imagePath,
        width: adjustedWidth,
        height: adjustedHeight,
        fit: BoxFit.contain,
      ),
    ),
  );
}
  Future<void> completeDressUp() async {
    await saveDressUp();

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
          image: DecorationImage(
            image: AssetImage(selectedBackgroundImagePath),
            fit: BoxFit.cover,
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
            // 악세사리 - 상단
            Positioned(
              top: 10,
              left: 110,
              child: _buildClothItem(
                imagePath: 'assets/dressup/accessory_pink_snapback.png',
                label: '모자',
                category: '모자',
                size: 66,
              ),
            ),

            Positioned(
              top: 10,
              right: 110,
              child: _buildClothItem(
                imagePath: 'assets/dressup/accessory_black_sunglasses.png',
                label: '선글라스',
                category: '선글라스',
                size: 66,
              ),
            ),

            // 상의 - 왼쪽
            Positioned(
              top: 95,
              left: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/top_sleeveless_white_lace.png',
                label: '나시 1',
                category: '상의',
              ),
            ),

            Positioned(
              top: 168,
              left: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/top_sleeveless_pink_stripe.png',
                label: '나시 2',
                category: '상의',
              ),
            ),

            Positioned(
              top: 241,
              left: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/top_tshirt_blue_stripe.png',
                label: '반팔 1',
                category: '상의',
              ),
            ),

            Positioned(
              top: 314,
              left: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/top_tshirt_pink_button.png',
                label: '반팔 2',
                category: '상의',
              ),
            ),

            // 하의 - 오른쪽
            Positioned(
              top: 95,
              right: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/bottom_shorts_gray_sport.png',
                label: '반바지 1',
                category: '하의',
              ),
            ),

            Positioned(
              top: 168,
              right: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/bottom_shorts_black_denim.png',
                label: '반바지 2',
                category: '하의',
              ),
            ),

            Positioned(
              top: 241,
              right: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/bottom_skirt_gray_ruffle.png',
                label: '치마 1',
                category: '하의',
              ),
            ),

            Positioned(
              top: 314,
              right: 18,
              child: _buildClothItem(
                imagePath: 'assets/dressup/bottom_skirt_denim_mini.png',
                label: '치마 2',
                category: '하의',
              ),
            ),

            // 신발 - 하단
            Positioned(
              bottom: 8,
              left: 125,
              child: _buildClothItem(
                imagePath: 'assets/dressup/shoes_black_high_top.png',
                label: '신발',
                category: '신발',
                size: 72,
              ),
            ),

            Positioned(
              bottom: 8,
              right: 125,
              child: _buildClothItem(
                imagePath: 'assets/dressup/shoes_navy_rain_boots.png',
                label: '장화',
                category: '신발',
                size: 72,
              ),
            ),

          Positioned(
            bottom:65,
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
          bottom: 65,
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
                child:SizedBox(
                        width: 235,
                        height: 330,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/dressup/dressup_character_base.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            // 모자
                            _buildWearingLayer(
                              category: '모자',
                              top: 0,
                              width: 90,
                              height: 60,
                            ),

                            // 선글라스
                            _buildWearingLayer(
                              category: '선글라스',
                              top: 28,
                              width: 80,
                              height: 45,
                            ),

                            // 상의
                            _buildWearingLayer(
                              category: '상의',
                              top: 68,
                              width: 70,
                              height: 82,
                            ),

                            // 하의
                            _buildWearingLayer(
                              category: '하의',
                              top: 120,
                              width: 73,
                              height: 78,
                            ),
                            //신발
                            _buildShoeLayers(),
                          ],
                        ),
                      )
              );
            },
          ),
        ),
        ],
      ),
    );
  }
  Widget _buildShoeLayers() {
    final label = selectedItemsByCategory['신발'];

    if (label == null) {
      return const SizedBox.shrink();
    }

    String leftImagePath;
    String rightImagePath;

    double shoeWidth;
    double shoeHeight;
    double shoeTop;
    double leftX;
    double rightX;

    if (label == '장화') {
      leftImagePath = 'assets/dressup/shoes_navy_rain_boots_left.png';
      rightImagePath = 'assets/dressup/shoes_navy_rain_boots_right.png';

      // 장화용
      shoeWidth = 55;
      shoeHeight = 70;
      shoeTop = 255;
      leftX = 53;
      rightX = 51;
    } else {
      leftImagePath = 'assets/dressup/shoes_black_high_top_left.png';
      rightImagePath = 'assets/dressup/shoes_black_high_top_right.png';

      // 운동화용
      shoeWidth = 55;
      shoeHeight = 70;
      shoeTop = 268;
      leftX = 51;
      rightX = 51;
    }

    return Stack(
      children: [
        Positioned(
          top: shoeTop,
          left: leftX,
          child: Transform.rotate(
            angle: 0.03,
            child: Image.asset(
              leftImagePath,
              width: shoeWidth,
              height: shoeHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: shoeTop,
          right: rightX,
          child: Transform.rotate(
            angle: -0.03,
            child: Image.asset(
              rightImagePath,
              width: shoeWidth,
              height: shoeHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildClothItem({
    required String imagePath,
    required String label,
    required String category,
    double size = 68,
  }) {
    final bool isSelected = selectedItemsByCategory[category] == label;

    Widget itemWidget = GestureDetector(
      onTap: () {
        toggleItem(
          category: category,
          label: label,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: sungshinViolet,
                  width: 3,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sungshinViolet.withOpacity(0.24),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Image.asset(
                imagePath,
                width: size - 8,
                height: size - 8,
                fit: BoxFit.contain,
              ),
            ),

            if (isSelected)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: sungshinViolet,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Draggable<Map<String, String>>(
      data: {
        'category': category,
        'label': label,
        'imagePath': imagePath,
      },
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: itemWidget,
      ),
      child: itemWidget,
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
                onTap: () async {
                  await completeDressUp();
                },
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
              child: _buildBackgroundButton(0, '핑크방'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBackgroundButton(1, '해변가'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBackgroundButton(2, '무대'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundButton(int index, String label) {
    final bool isSelected = selectedBackgroundIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedBackgroundIndex = index;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('dressup_background_index', selectedBackgroundIndex);
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