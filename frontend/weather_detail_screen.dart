import 'package:flutter/material.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({
    super.key,
    required this.temperature,
    required this.recommendedTemperature,
    required this.humidity,
    required this.weather,
    required this.dust,
    required this.futureForecast,
    required this.age,
    required this.coldLevel,
    required this.heatLevel,
  });

  final double temperature;
  final double recommendedTemperature;
  final int humidity;
  final String weather;
  final String dust;
  final List<Map<String, dynamic>> futureForecast;

  final String age;
  final String coldLevel;
  final String heatLevel;

  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color softViolet = Color(0xFFF3EFFA);
  static const Color textDark = Color(0xFF2E2440);
  static const Color borderViolet = Color(0xFFE2D9F0);

  IconData getWeatherIcon(String value) {
    if (value.contains('비')) return Icons.umbrella_rounded;
    if (value.contains('눈')) return Icons.ac_unit_rounded;
    if (value.contains('구름')) return Icons.cloud_rounded;
    if (value.contains('흐림')) return Icons.cloud_rounded;
    return Icons.wb_sunny_rounded;
  }

  Color getWeatherIconColor(String value) {
    if (value.contains('비')) return const Color(0xFF6B8DD6);
    if (value.contains('눈')) return const Color(0xFF8DBBE8);
    if (value.contains('구름')) return const Color(0xFFB8C5D0);
    if (value.contains('흐림')) return const Color(0xFFB8C5D0);
    return const Color(0xFFF2B943);
  }

  String getPersonalMessage() {
    if (coldLevel == '잘탐') {
      return '추위를 많이 타는 편이라 실제 기온보다 조금 더 쌀쌀하게 느껴질 수 있어요. 얇은 겉옷을 함께 챙기면 좋아요.';
    }

    if (heatLevel == '잘탐') {
      return '더위를 많이 타는 편이라 두꺼운 겉옷보다는 얇게 입고 조절할 수 있는 옷차림이 좋아요.';
    }

    return '오늘은 체감상 무난한 날씨예요. 긴팔과 긴바지 정도면 편하게 입을 수 있어요.';
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
            colors: [Color(0xFFF7F2FF), Color(0xFFFFFBF4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 26),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 30,
                          color: sungshinViolet,
                        ),
                      ),

                      const SizedBox(height: 38),

                      const Text(
                        '날씨 상세 정보',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildMainWeatherCard(),

                      const SizedBox(height: 18),

                      _buildInfoGrid(),

                      const SizedBox(height: 28),

                      _buildHourlySection(),

                      const SizedBox(height: 28),

                      _buildWeeklySection(),

                      const SizedBox(height: 28),

                      _buildPersonalCard(),

                      const SizedBox(height: 36),
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

  Widget _buildMainWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
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
          SizedBox(
            width: 74,
            height: 74,
            child: Center(
              child: Icon(
                getWeatherIcon(weather),
                size: 54,
                color: getWeatherIconColor(weather),
              ),
            ),
          ),

          const SizedBox(width: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temperature°C',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weather,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: sungshinBrightViolet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallInfoCard(
            title: '체감',
            value: '${recommendedTemperature.toStringAsFixed(1)}°C',
            icon: Icons.thermostat_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallInfoCard(
            title: '습도',
            value: '$humidity%',
            icon: Icons.water_drop_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallInfoCard(
            title: '미세먼지',
            value: dust,
            icon: Icons.air_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderViolet, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: sungshinViolet),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: sungshinBrightViolet,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textDark,
      ),
    );
  }

  Widget _buildHourlySection() {
    final hourly = futureForecast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('시간대별 예보'),
        const SizedBox(height: 14),

        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = hourly[index];
              final String sky = item['sky'].toString();

              return Container(
                width: 86,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderViolet, width: 1.3),
                  boxShadow: [
                    BoxShadow(
                      color: sungshinViolet.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      item['time'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sungshinBrightViolet,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      getWeatherIcon(sky),
                      size: 28,
                      color: getWeatherIconColor(sky),
                    ),
                    const Spacer(),
                    Text(
                      '${item['temperature']}°C',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //주간예보
  Widget _buildWeeklySection() {
    final List<Map<String, dynamic>> weekly = [
      {'day': '오늘', 'sky': '맑음', 'min': 15, 'max': 24},
      {'day': '내일', 'sky': '구름', 'min': 16, 'max': 23},
      {'day': '수', 'sky': '비', 'min': 17, 'max': 21},
      {'day': '목', 'sky': '맑음', 'min': 14, 'max': 25},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('주간 예보'),
        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderViolet, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: sungshinViolet.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: weekly.map((item) {
              final String sky = item['sky'].toString();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        item['day'].toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ),

                    Icon(
                      getWeatherIcon(sky),
                      size: 26,
                      color: getWeatherIconColor(sky),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        sky,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: sungshinBrightViolet,
                        ),
                      ),
                    ),

                    Text(
                      '${item['min']}° / ${item['max']}°',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: softViolet.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: Image.asset(
                    'assets/characters/dragon_face_wink.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '사용자 맞춤 체감 설명',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: sungshinViolet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            getPersonalMessage(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.55,
              color: textDark,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '나이대 $age · 추위 $coldLevel · 더위 $heatLevel',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sungshinBrightViolet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
