import 'package:flutter/material.dart';
import 'weather_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.age,
    required this.coldLevel,
    required this.heatLevel,
  });

  final String age;
  final String coldLevel;
  final String heatLevel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showWeeklyFeedbackDialog();
  });
}
void _showWeeklyFeedbackDialog() {
  String selectedFeedback = '좋았어요';

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 360,
              ),
              child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '이번 주 Wearther 추천은\n어떠셨나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    '더 잘 맞는 옷차림을 추천해드릴게요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: sungshinBrightViolet,
                    ),
                  ),

                  //팝업창 수룡이
                  const SizedBox(height: 18),

                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/characters/dragon_face_wink.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFeedbackChoice(
                          label: '추웠어요',
                          isSelected: selectedFeedback == '추웠어요',
                          onTap: () {
                            setDialogState(() {
                              selectedFeedback = '추웠어요';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFeedbackChoice(
                          label: '좋았어요',
                          isSelected: selectedFeedback == '좋았어요',
                          onTap: () {
                            setDialogState(() {
                              selectedFeedback = '좋았어요';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFeedbackChoice(
                          label: '더웠어요',
                          isSelected: selectedFeedback == '더웠어요',
                          onTap: () {
                            setDialogState(() {
                              selectedFeedback = '더웠어요';
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: sungshinViolet,
                              side: const BorderSide(
                                color: Color(0xFFE2D9F0),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              '나중에',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sungshinViolet,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '피드백이 저장되었어요: $selectedFeedback',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          );
        },
      );
    },
  );
}

Widget _buildFeedbackChoice({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 46,
      decoration: BoxDecoration(
        color: isSelected ? sungshinViolet : softViolet,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? sungshinViolet : const Color(0xFFE2D9F0),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : sungshinViolet,
          ),
        ),
      ),
    ),
  );
}
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color softViolet = Color(0xFFF3EFFA);
  static const Color textDark = Color(0xFF2E2440);

  bool showBubble = false;

  final int temperature = 4;
  final String weather = '맑음';
  final String dust = '보통';

  String get outfitImagePath {

    if (weather == '눈') {
      return 'assets/characters/dragon_outfit_snow.png';
    }

    if (weather == '비') {
      return 'assets/characters/dragon_outfit_raincoat.png';
    }

    if (temperature >= 28) {
      return 'assets/characters/dragon_outfit_short_short.png';
    }

    if (temperature >= 20) {
      return 'assets/characters/dragon_outfit_short_long.png';
    }

    if (temperature >= 16) {
      return 'assets/characters/dragon_outfit_long_long.png';
    }

    if (temperature >= 12) {
      return 'assets/characters/dragon_outfit_cardigan.png';
    }

    if (temperature >= 8) {
      return 'assets/characters/dragon_outfit_zipup.png';
    }

    return 'assets/characters/dragon_outfit_padding.png';
  }


  String get backgroundImagePath {
    final int hour = DateTime.now().hour;

    if (hour >= 6 && hour < 18) {
      return 'assets/backgrounds/bg_day.png';
    }

    return 'assets/backgrounds/bg_night.png';
  }
  
  bool get isNight {
    final int hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  String get outfitMessage {
    if (widget.coldLevel == '잘탐') {
      return '긴팔과 긴바지에 가디건을 챙기면 좋아요.';
    }

    if (widget.heatLevel == '잘탐') {
      return '얇은 긴팔이나 반팔에 긴바지를 추천해요.';
    }

    return '긴팔과 긴바지를 추천해요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.18),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      _buildHeader(),

                      const SizedBox(height: 24),

                      _buildWeatherCard(),

                      const SizedBox(height: 22),

                      Expanded(
                        child: _buildCharacterArea(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wearther',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: isNight ? Colors.white : sungshinViolet,
                shadows: isNight
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '기준 위치의 날씨 정보',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isNight
                    ? Colors.white.withOpacity(0.72)
                    : sungshinBrightViolet.withOpacity(0.78),
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isNight
                  ? Colors.white.withOpacity(0.92)
                  : Colors.white.withOpacity(0.86),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isNight ? 0.18 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: sungshinViolet,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildWeatherCard() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDetailScreen(
            temperature: temperature,
            weather: weather,
            dust: dust,
            age: widget.age,
            coldLevel: widget.coldLevel,
            heatLevel: widget.heatLevel,
          ),
        ),
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_rounded,
            size: 52,
            color: Color(0xFFF2B943),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temperature°C',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$weather · 미세먼지 $dust',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: sungshinBrightViolet,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: sungshinBrightViolet,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCharacterArea() {
    return SizedBox(
      height: 560,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 본문 수룡이 캐릭터
          Positioned(
            bottom: 60,
            child: SizedBox(
              width: 330,
              height: 330,
              child: Image.asset(
                outfitImagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 수정구에서 나오는 마법 말풍선
          if (showBubble)
            Positioned(
              right: 46,
              bottom: 285,
              child: _buildMagicBubble(),
            ),

          // 수정구 버튼
          Positioned(
            right: 18,
            bottom: 42,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showBubble = !showBubble;
                });
              },
              child: SizedBox(
                width: 112,
                height: 112,
                //수정구
                child: Image.asset(
                  'assets/objects/crystal_ball.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicBubble() {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      // 말풍선 본체
      Container(
        width: 230,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: sungshinViolet.withOpacity(0.16),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          outfitMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.4,
            color: textDark,
          ),
        ),
      ),

      // 수정구 쪽으로 이어지는 마법 연기
      Positioned(
        right: 22,
        bottom: -46,
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: sungshinBrightViolet.withOpacity(0.18),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),

      // 작은 마법 반짝이
      Positioned(
        right: 12,
        top: -8,
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 20,
          color: sungshinBrightViolet.withOpacity(0.75),
        ),
      ),
    ],
  );
}

  Widget _buildRecommendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2D9F0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.checkroom_rounded,
            color: sungshinViolet,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '오늘 추천: $outfitMessage',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.35,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}