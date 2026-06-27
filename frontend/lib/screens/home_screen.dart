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
                    '더 잘 맞는 옷차림 추천을 위해\n간단히 알려주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: sungshinBrightViolet,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: softViolet,
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: const Center(
                      child: Text(
                        '수룡',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: sungshinBrightViolet,
                        ),
                      ),
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

  final int temperature = 18;
  final String weather = '맑음';
  final String dust = '보통';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F5FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
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
    );
    
  }

  Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wearther',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: sungshinViolet,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '기준 위치의 날씨 정보',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: sungshinBrightViolet,
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: sungshinViolet,
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
        color: Colors.white,
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
          const Text(
            '☀️',
            style: TextStyle(fontSize: 46),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6E8),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: -24,
            right: -24,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFD5EACF),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          if (showBubble)
            Positioned(
              top: 8,
              child: Container(
                width: 260,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: sungshinViolet.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  outfitMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    color: textDark,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 58,
            child: Container(
              width: 210,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: sungshinViolet.withOpacity(0.1),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 170,
                  height: 185,
                  decoration: BoxDecoration(
                    color: softViolet,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const Center(
                    child: Text(
                      '수룡\n+ 옷차림',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                        color: sungshinBrightViolet,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 18,
            bottom: 26,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showBubble = !showBubble;
                });
              },
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: sungshinViolet.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🔮',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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