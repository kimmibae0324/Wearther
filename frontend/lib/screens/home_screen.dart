import 'package:flutter/material.dart'; // 날씨아이콘에 사용
import 'package:lucide_flutter/lucide_flutter.dart'; // 날씨아이콘에 사용
import 'weather_detail_screen.dart';
import 'settings_screen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userId,
    required this.age,
    required this.coldLevel,
    required this.heatLevel,
  });

  final int userId;
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

    fetchWeather(); //실시간 정보 불러오는 함수

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWeeklyFeedbackDialog();
    });
  }

  double temperature = 0.0;
  double recommendedTemperature = 0.0;
  int humidity = 0;
  String recommendedOutfit = "";
  String weather = '';
  String dust = '나쁨';
  List<Map<String, dynamic>> futureForecast = []; //실시간예보를 위한 코드

  Future<void> fetchWeather() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8001/weather/custom-info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          //'latitude': 37.5665,
          //'longitude': 126.9780, 위치정보 지정해둠(나중에 실시간 위치 도입)
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = (data['current_weather']['temperature'] as num)
              .toDouble();

          recommendedTemperature =
              (data['current_weather']['recommended_temperature'] as num)
                  .toDouble();

          humidity = data['current_weather']['humidity'];

          recommendedOutfit = data['current_weather']['recommended_outfit'];

          weather = data['current_weather']['sky'];

          futureForecast = List<Map<String, dynamic>>.from(
            data['future_forecast'],
          );
          //실시간예보
        });

        print(futureForecast);
      } else {
        print('API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류: $e');
    }
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
                constraints: const BoxConstraints(maxWidth: 360),
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

                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
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

  //(간단 요약) 날씨 아이콘
  Widget get weatherIcon {
    switch (weather) {
      case '맑음':
        return const Icon(
          Icons.wb_sunny_rounded,
          color: Color(0xFFF5B301),
          size: 52,
        );

      case '구름많음':
        return const Icon(
          LucideIcons.cloudSun,
          color: Color(0xFF90A4AE),
          size: 52,
        );

      case '흐림':
        return const Icon(
          Icons.cloud_rounded,
          color: Color(0xFFB8C5D0),
          size: 52,
        );

      case '비':
        return const Icon(
          LucideIcons.cloudRain,
          color: Color.fromRGBO(138, 216, 255, 1),
          size: 52,
        );

      case '눈':
        return const Icon(
          LucideIcons.cloudSnow,
          color: Color(0xFF42A5F5),
          size: 52,
        );

      default:
        return const Icon(
          Icons.ac_unit_rounded,
          color: Color(0xFF81D4FA),
          size: 52,
        );
    }
  }

  // 사용자 맞춤 옷차림
  String get outfitImagePath {
    if (weather == '눈') {
      return 'assets/characters/dragon_outfit_snow.png';
    }

    if (weather == '비') {
      return 'assets/characters/dragon_outfit_raincoat.png';
    }

    //백엔드가 추천한 의상
    switch (recommendedOutfit) {
      case 'short_short':
        return 'assets/characters/dragon_outfit_short_short.png';

      case 'short_long':
        return 'assets/characters/dragon_outfit_short_long.png';

      case 'long_long':
        return 'assets/characters/dragon_outfit_long_long.png';

      case 'cardigan':
        return 'assets/characters/dragon_outfit_cardigan.png';

      case 'zipup':
        return 'assets/characters/dragon_outfit_zipup.png';

      case 'padding':
        return 'assets/characters/dragon_outfit_padding.png';

      default:
        return 'assets/characters/dragon_outfit_long_long.png';
    }
  }

  //수정구 변화
  String get crystalImagePath {
    if (dust.contains('매우')) {
      return 'assets/objects/crystal_very_bad.png';
    }

    if (dust.contains('나쁨')) {
      return 'assets/objects/crystal_bad.png';
    }

    if (dust.contains('좋음')) {
      return 'assets/objects/crystal_good.png';
    }

    return 'assets/objects/crystal_normal.png';
  }

  String get dustMessage {
    if (dust.contains('매우')) {
      return '공기가 많이 탁해요. 외출을 조심해요.';
    }

    if (dust.contains('나쁨')) {
      return '공기가 탁해요. 마스크를 챙겨요.';
    }

    if (dust.contains('좋음')) {
      return '공기가 깨끗해요.';
    }

    return '공기는 보통이에요.';
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
    if (weather == '눈') {
      return '눈 오는 날엔 따뜻하게 입어요.\n$dustMessage';
    }

    if (weather == '비') {
      return '비가 와요. 우비를 챙겨요.\n$dustMessage';
    }

    //백엔드가 추천한 의상
    switch (recommendedOutfit) {
      case "short_short":
        return "반팔과 반바지를 추천해요.\n$dustMessage";

      case "short_long":
        return "반팔과 긴바지를 추천해요.\n$dustMessage";

      case "long_long":
        return "긴팔과 긴바지를 추천해요.\n$dustMessage";

      case "cardigan":
        return "가디건을 함께 입으면 좋아요.\n$dustMessage";

      case "zipup":
        return "집업을 챙기면 든든해요.\n$dustMessage";

      case "padding":
        return "패딩으로 따뜻하게 입어요.\n$dustMessage";

      default:
        return dustMessage;
    }
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

                      Expanded(child: _buildCharacterArea()),

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
        Row(
          children: [
            // 새로고침 버튼
            GestureDetector(
              onTap: () async {
                await fetchWeather();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('최신 날씨 정보를 불러왔습니다.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
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
                  Icons.refresh_rounded,
                  color: sungshinViolet,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(width: 12),

            //설정 버튼
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
              recommendedTemperature: recommendedTemperature,
              humidity: humidity,
              weather: weather,
              dust: dust,
              futureForecast: futureForecast,
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

        //날씨요약칸
        child: Row(
          children: [
            weatherIcon,
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
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
              child: Image.asset(outfitImagePath, fit: BoxFit.contain),
            ),
          ),

          // 수정구에서 나오는 마법 말풍선
          if (showBubble)
            Positioned(right: 46, bottom: 285, child: _buildMagicBubble()),

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
                child: Image.asset(crystalImagePath, fit: BoxFit.contain),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
        border: Border.all(color: const Color(0xFFE2D9F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.checkroom_rounded, color: sungshinViolet),
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
