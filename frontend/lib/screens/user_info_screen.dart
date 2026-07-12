import 'dart:convert';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key, this.isUpdate = false});

  final bool isUpdate;

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color textDark = Color(0xFF2E2440);

  final TextEditingController nicknameController = TextEditingController();

  String selectedAge = '20대';
  int coldSensitivity = 50;
  int heatSensitivity = 50;

  final List<String> ageOptions = ['10대', '20대', '30대', '40대', '50대 이상'];
  final List<int> sensitivityOptions = [0, 25, 50, 75, 100];

  String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8001';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8001';
  }

  return 'http://127.0.0.1:8001';
}

  @override
  void initState() {
    super.initState();
    nicknameController.addListener(() {
      setState(() {});
    });

    if (widget.isUpdate) {
      loadUserInfo();
    }
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nicknameController.text = prefs.getString("nickname") ?? "";
      selectedAge = prefs.getString("age") ?? "20대";

      coldSensitivity =
          prefs.getInt("coldSensitivity") ??
          _valueFromOldLevel(prefs.getString("coldLevel"));

      heatSensitivity =
          prefs.getInt("heatSensitivity") ??
          _valueFromOldLevel(prefs.getString("heatLevel"));
    });
  }

  bool get isReady {
    return nicknameController.text.trim().isNotEmpty;
  }

  int _valueFromOldLevel(String? level) {
    switch (level) {
      case '잘탐':
        return 75;
      case '보통':
        return 50;
      case '안탐':
        return 25;
      default:
        return 50;
    }
  }

  String _sensitivityLabel(int value) {
    switch (value) {
      case 0:
        return '전혀 안 타요';
      case 25:
        return '조금 안 타요';
      case 50:
        return '보통이에요';
      case 75:
        return '조금 잘 타요';
      case 100:
        return '많이 타요';
      default:
        return '보통이에요';
    }
  }

  Future<int> registerUser() async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/user/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "age_group": selectedAge,
        "cold_sensitivity": coldSensitivity,
        "heat_sensitivity": heatSensitivity,
      }),
    );

    final data = jsonDecode(response.body);

    return data["user_id"];
  }

  Future<void> updateUser(int userId) async {
    await http.post(
      Uri.parse('$apiBaseUrl/user/update'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "age_group": selectedAge,
        "cold_sensitivity": coldSensitivity,
        "heat_sensitivity": heatSensitivity,
      }),
    );
  }

  Future<void> saveLocalUserInfo(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("user_id", userId);
    await prefs.setString("nickname", nicknameController.text.trim());
    await prefs.setString("age", selectedAge);

    await prefs.setInt("coldSensitivity", coldSensitivity);
    await prefs.setInt("heatSensitivity", heatSensitivity);

    await prefs.setString("coldLevel", _sensitivityLabel(coldSensitivity));
    await prefs.setString("heatLevel", _sensitivityLabel(heatSensitivity));
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

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

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 29,
                          height: 1.38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.1,
                          color: textDark,
                        ),
                        children: [
                          TextSpan(text: '나에게 맞는 '),
                          TextSpan(
                            text: '추천',
                            style: TextStyle(color: sungshinViolet),
                          ),
                          TextSpan(text: '을 위해\n'),
                          TextSpan(
                            text: '기본 정보',
                            style: TextStyle(color: sungshinViolet),
                          ),
                          TextSpan(text: '를 알려주세요'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    _buildSectionTitle('별명'),
                    const SizedBox(height: 12),
                    _buildNicknameField(),

                    const SizedBox(height: 28),

                    _buildSectionTitle('나이대'),
                    const SizedBox(height: 12),
                    _buildAgeDropdown(),

                    const SizedBox(height: 30),

                    _buildSectionTitle('추위를 얼마나 타나요?'),
                    const SizedBox(height: 10),
                    _buildSensitivitySlider(
                      value: coldSensitivity,
                      onChanged: (value) {
                        setState(() {
                          coldSensitivity = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    _buildSectionTitle('더위를 얼마나 타나요?'),
                    const SizedBox(height: 10),
                    _buildSensitivitySlider(
                      value: heatSensitivity,
                      onChanged: (value) {
                        setState(() {
                          heatSensitivity = value;
                        });
                      },
                    ),

                    const SizedBox(height: 34),

                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: isReady
                            ? () async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                int? userId = prefs.getInt("user_id");

                                if (widget.isUpdate) {
                                  await updateUser(userId!);
                                } else {
                                  userId = await registerUser();
                                }

                                await saveLocalUserInfo(userId!);

                                if (!mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      userId: userId!,
                                      age: selectedAge,
                                      coldLevel:
                                          _sensitivityLabel(coldSensitivity),
                                      heatLevel:
                                          _sensitivityLabel(heatSensitivity),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sungshinViolet,
                          disabledBackgroundColor: const Color(0xFFE1DEE7),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textDark,
      ),
    );
  }

  Widget _buildNicknameField() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: sungshinViolet.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: nicknameController,
        cursorColor: sungshinViolet,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '별명을 입력해주세요',
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB7AEC6),
          ),
        ),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: sungshinBrightViolet,
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: sungshinViolet.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedAge,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: sungshinViolet,
            size: 30,
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: sungshinBrightViolet,
          ),
          items: ageOptions.map((age) {
            return DropdownMenuItem<String>(value: age, child: Text(age));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedAge = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSensitivitySlider({
    required int value,
    required void Function(int value) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: sungshinViolet.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _sensitivityLabel(value),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: sungshinBrightViolet,
            ),
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sungshinViolet,
              inactiveTrackColor: const Color(0xFFE7E1EF),
              thumbColor: sungshinViolet,
              overlayColor: sungshinViolet.withOpacity(0.12),
              valueIndicatorColor: sungshinViolet,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 4,
              label: value.toString(),
              onChanged: (newValue) {
                onChanged(newValue.round());
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sensitivityOptions.map((option) {
              final bool isSelected = option == value;

              return Text(
                option.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? sungshinViolet
                      : sungshinViolet.withOpacity(0.38),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}