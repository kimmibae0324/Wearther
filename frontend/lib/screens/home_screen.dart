import 'package:flutter/material.dart'; // 날씨아이콘에 사용
import 'package:lucide_flutter/lucide_flutter.dart'; // 날씨아이콘에 사용
import 'weather_detail_screen.dart';
import 'settings_screen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

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
  String characterState = '보통_무표정';
  List<Map<String, dynamic>> futureForecast = []; //실시간예보를 위한 코드
  List<Map<String, dynamic>> midForecast = []; // [추가됨] 주간예보를 위한 코드

  //안드로이드 에퓰레이터용 api 주소 변환 함수
  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001';
    }

    return 'http://127.0.0.1:8001';
  }

  Future<void> fetchWeather() async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/weather/custom-info'),
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

          print('위젯 recommendedOutfit 값: $recommendedOutfit');

          weather = data['current_weather']['sky'];

          dust = data['current_weather']['pm10_grade'];

          characterState =
              (data['current_weather']['character_state'] ?? '보통_무표정')
                  .toString();

          futureForecast = List<Map<String, dynamic>>.from(
            data['future_forecast'],
          );

          // [추가됨] 백엔드에서 준 주간예보 데이터 저장
          midForecast = List<Map<String, dynamic>>.from(data['mid_forecast']);
        });

        await updateAndroidHomeWidget(); // 안드로이드 홈 위젯 업데이트

        print(futureForecast);
      } else {
        print('API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  //위젯용 변환 함수
  String get widgetFaceEmoji {
    switch (characterState) {
      case '더움_땀뻘뻘':
        return '🥵';

      case '추움_덜덜':
        return '🥶';

      case '습함_불쾌':
        return '😣';

      case '쾌적_스마일':
        return '😊';

      case '보통_무표정':
      default:
        return '😐';
    }
  }

  String get widgetOutfitLabel {
    final outfit = recommendedOutfit.trim();

    switch (outfit) {
      case '숏+숏':
      case 'short_short':
        return '반팔+반바지';

      case '숏+롱':
      case 'short_long':
        return '반팔+긴바지';

      case '롱+롱':
      case 'long_long':
        return '긴팔+긴바지';

      case '가디건+긴':
      case 'cardigan_long':
      case 'cardigan':
        return '가디건+긴바지';

      case '집업+긴':
      case 'zipup_long':
      case 'zipup':
        return '집업+긴바지';

      case '코트+긴':
      case 'coat_long':
      case 'coat':
        return '코트+긴바지';

      case '패딩':
      case 'padding':
        return '패딩';

      default:
        print('매칭 안 된 recommendedOutfit: $recommendedOutfit');
        return recommendedOutfit.isNotEmpty ? recommendedOutfit : '날씨 맞춤 옷차림';
    }
  }

  Future<void> updateAndroidHomeWidget() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await HomeWidget.saveWidgetData<String>(
      'widget_character_state',
      characterState,
    );

    await HomeWidget.saveWidgetData<String>('widget_face', widgetFaceEmoji);

    await HomeWidget.saveWidgetData<String>(
      'widget_outfit',
      '옷 추천: $widgetOutfitLabel',
    );

    await HomeWidget.saveWidgetData<String>(
      'widget_temp',
      '기온: ${temperature.toStringAsFixed(1)}°C',
    );

    await HomeWidget.saveWidgetData<String>('widget_weather', '날씨: $weather');

    await HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.example.wearther.WeartherWidgetProvider',
    );
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
          color: Color(0xFF6B8DD6),
          size: 52,
        );

      case '눈':
        return const Icon(
          LucideIcons.cloudSnow,
          color: Color(0xFF8DBBE8),
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
  // 사용자 맞춤 수룡이 이미지
  String get outfitImagePath {
    // 1순위: 눈
    if (weather == '눈' || recommendedOutfit == 'snow') {
      return 'assets/characters/dragon_outfit_snow.png';
    }

    // 2순위: 비
    // 백엔드가 강수확률 90% 초과일 때 raincoat_umbrella로 보내주면 우비+우산 이미지 사용
    if (recommendedOutfit == 'raincoat_umbrella') {
      return 'assets/characters/dragon_outfit_raincoat_umbrella.png';
    }

    if (weather == '비' || recommendedOutfit == 'raincoat') {
      return 'assets/characters/dragon_outfit_raincoat.png';
    }

    // 3순위: 체감온도 기반 옷차림
    switch (recommendedOutfit) {
      case 'short_short':
        return 'assets/characters/dragon_outfit_short_short.png';

      case 'short_long':
        return 'assets/characters/dragon_outfit_short_long.png';

      case 'long_long':
        return 'assets/characters/dragon_outfit_long_long.png';

      case 'cardigan_long':
      case 'cardigan':
        return 'assets/characters/dragon_outfit_cardigan.png';

      case 'zipup_long':
      case 'zipup':
        return 'assets/characters/dragon_outfit_zipup.png';

      case 'coat_long':
      case 'coat':
        return 'assets/characters/dragon_outfit_coat.png';

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
      return '공기가 많이 탁해요. \n외출을 조심해요.';
    }

    if (dust.contains('나쁨')) {
      return '공기가 탁해요. \n마스크를 챙겨요.';
    }

    if (dust.contains('좋음')) {
      return '공기가 깨끗해요.';
    }

    return '공기는 보통이에요.';
  }

  Map<String, int> get sunriseSunsetMinutes {
    final int month = DateTime.now().month;

    // 겨울: 11, 12, 1, 2월 → 07:30 / 17:40
    if (month == 11 || month == 12 || month == 1 || month == 2) {
      return {'sunrise': 7 * 60 + 30, 'sunset': 17 * 60 + 40};
    }

    // 봄/가을: 3, 9, 10월 → 06:30 / 18:20
    if (month == 3 || month == 9 || month == 10) {
      return {'sunrise': 6 * 60 + 30, 'sunset': 18 * 60 + 20};
    }

    // 여름: 4~8월 → 05:20 / 19:40
    return {'sunrise': 5 * 60 + 20, 'sunset': 19 * 60 + 40};
  }

  bool get isDaytime {
    final DateTime now = DateTime.now();
    final int currentMinutes = now.hour * 60 + now.minute;

    final times = sunriseSunsetMinutes;

    return currentMinutes >= times['sunrise']! &&
        currentMinutes < times['sunset']!;
  }

  String get backgroundImagePath {
    if (isDaytime) {
      return 'assets/backgrounds/bg_day.png';
    }

    return 'assets/backgrounds/bg_night.png';
  }

  bool get isNight {
    return !isDaytime;
  }

  String get outfitMessage {
    if (weather == '눈' || recommendedOutfit == 'snow') {
      return '눈 오는 날엔 미끄럽지 않게,\n따뜻하게 입어요.\n$dustMessage';
    }

    if (recommendedOutfit == 'raincoat_umbrella') {
      return '비가 많이 올 수 있어요.\n우비와 우산을 함께 챙겨요.\n$dustMessage';
    }

    if (weather == '비' || recommendedOutfit == 'raincoat') {
      return '비가 와요.\n우비를 챙기면 좋아요.\n$dustMessage';
    }

    switch (recommendedOutfit) {
      case "short_short":
        return "반팔과 반바지를 추천해요.\n$dustMessage";

      case "short_long":
        return "반팔과 긴바지를 추천해요.\n$dustMessage";

      case "long_long":
        return "긴팔과 긴바지를 추천해요.\n$dustMessage";

      case "cardigan_long":
      case "cardigan":
        return "가디건과 긴바지를 추천해요.\n$dustMessage";

      case "zipup_long":
      case "zipup":
        return "집업과 긴바지를 입으면 좋아요.\n$dustMessage";

      case "coat_long":
      case "coat":
        return "코트와 긴바지로 따뜻하게 입어요.\n$dustMessage";

      case "padding":
        return "패딩으로 든든하게 입어요.\n$dustMessage";

      default:
        return "오늘 날씨에 맞는 옷차림을 확인해보세요.\n$dustMessage";
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

                      const SizedBox(height: 18),

                      _buildPersonalFeelingCard(),

                      const SizedBox(height: 18),

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
              midForecast: midForecast, // [추가됨] 주간예보 전달
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

  String get personalFeelingMessage {
    if (weather == '눈' || recommendedOutfit == 'snow') {
      return '눈 오는 날은 체감상 더 춥게 느껴질 수 있어요. 따뜻한 겉옷과 미끄럽지 않은 신발을 챙겨주세요.';
    }

    if (weather == '비' || recommendedOutfit == 'raincoat') {
      return '비가 오는 날은 습도 때문에 체감이 달라질 수 있어요. 우비나 가벼운 겉옷을 챙기면 좋아요.';
    }

    if (recommendedOutfit == 'raincoat_umbrella') {
      return '비가 많이 올 수 있어요. 우비와 우산을 함께 챙기면 더 편하게 이동할 수 있어요.';
    }

    if (widget.coldLevel.contains('많이') || widget.coldLevel.contains('잘')) {
      return '추위를 잘 타는 편이라 실제 기온보다 더 서늘하게 느낄 수 있어요. 얇은 겉옷을 챙기면 좋아요.';
    }

    if (widget.heatLevel.contains('많이') || widget.heatLevel.contains('잘')) {
      return '더위를 잘 타는 편이라 답답하지 않은 옷차림이 좋아요. 통풍이 잘 되는 옷을 추천해요.';
    }

    switch (recommendedOutfit) {
      case 'short_short':
        return '오늘은 체감상 더운 날씨예요. 반팔과 반바지로 가볍게 입기 좋아요.';

      case 'short_long':
        return '오늘은 체감상 따뜻한 날씨예요. 반팔에 긴바지 정도면 편하게 입을 수 있어요.';

      case 'long_long':
        return '오늘은 체감상 무난한 날씨예요. 긴팔과 긴바지 정도면 편하게 입을 수 있어요.';

      case 'cardigan_long':
      case 'cardigan':
        return '오늘은 살짝 서늘할 수 있어요. 가디건과 긴바지를 함께 입으면 좋아요.';

      case 'zipup_long':
      case 'zipup':
        return '오늘은 제법 선선한 날씨예요. 집업과 긴바지를 챙기면 든든해요.';

      case 'coat_long':
      case 'coat':
        return '오늘은 체감상 쌀쌀한 날씨예요. 코트와 긴바지로 따뜻하게 입는 걸 추천해요.';

      case 'padding':
        return '오늘은 많이 추울 수 있어요. 패딩으로 체온을 따뜻하게 유지해주세요.';

      default:
        return '오늘 날씨와 체감에 맞춰 편안한 옷차림을 추천해드릴게요.';
    }
  }

  Widget _buildPersonalFeelingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Image.asset(
                  'assets/characters/dragon_face_wink.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '사용자 맞춤 체감 설명',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: sungshinViolet,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            personalFeelingMessage,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.55,
              color: textDark,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '나이대 ${widget.age} · 추위 ${widget.coldLevel} · 더위 ${widget.heatLevel}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: sungshinBrightViolet,
              ),
            ),
          ),
        ],
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
              height: 310,
              child: Image.asset(outfitImagePath, fit: BoxFit.contain),
            ),
          ),

          // 수정구에서 나오는 마법 말풍선
          if (showBubble)
            Positioned(right: 118, bottom: 92, child: _buildMagicBubble()),
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
          width: 205,
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
            dustMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: textDark,
            ),
          ),
        ),

        // 수정구 쪽으로 이어지는 마법 연기
        Positioned(
          right: -48,
          bottom: 8,
          child: SizedBox(
            width: 64,
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 2,
                  child: Container(
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
                ),
                Positioned(
                  left: 26,
                  top: 24,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 48,
                  top: 44,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
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
