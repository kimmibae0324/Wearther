import 'dart:convert';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  String selectedAge = '10대';
  String? coldLevel;
  String? heatLevel;
  @override
  void initState() {
    super.initState();

    if (widget.isUpdate) {
      loadUserInfo();
    }
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedAge = prefs.getString("age") ?? "20대";

      coldLevel = prefs.getString("coldLevel");

      heatLevel = prefs.getString("heatLevel");
    });
  }

  final List<String> ageOptions = ['10대', '20대', '30대', '40대', '50대 이상'];

  final List<String> levelOptions = ['안탐', '보통', '잘탐'];

  bool get isReady {
    return coldLevel != null && heatLevel != null;
  }

  int convertLevel(String level) {
    switch (level) {
      case '잘탐':
        return 1;
      case '보통':
        return 0;
      case '안탐':
        return -1;
      default:
        return 0;
    }
  }

  Future<int> registerUser() async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8001/user/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "age_group": selectedAge,
        "cold_sensitivity": convertLevel(coldLevel!),
        "heat_sensitivity": convertLevel(heatLevel!),
      }),
    );

    final data = jsonDecode(response.body);

    return data["user_id"];
  }

  Future<void> updateUser(int userId) async {
    await http.post(
      Uri.parse("http://127.0.0.1:8001/user/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "age_group": selectedAge,
        "cold_sensitivity": convertLevel(coldLevel!),
        "heat_sensitivity": convertLevel(heatLevel!),
      }),
    );
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

                const SizedBox(height: 46),

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
                const SizedBox(height: 44),

                _buildSectionTitle('나이대'),
                const SizedBox(height: 12),
                _buildAgeDropdown(),

                const SizedBox(height: 34),

                _buildSectionTitle('추위를 많이 타나요?'),
                const SizedBox(height: 14),
                _buildLevelButtons(
                  selectedValue: coldLevel,
                  onSelected: (value) {
                    setState(() {
                      coldLevel = value;
                    });
                  },
                ),

                const SizedBox(height: 34),

                _buildSectionTitle('더위를 많이 타나요?'),
                const SizedBox(height: 14),
                _buildLevelButtons(
                  selectedValue: heatLevel,
                  onSelected: (value) {
                    setState(() {
                      heatLevel = value;
                    });
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: isReady
                        ? () async {
                            final prefs = await SharedPreferences.getInstance();

                            int? userId = prefs.getInt("user_id");

                            if (widget.isUpdate) {
                              // 설정 화면에서 들어온 경우
                              await updateUser(userId!);
                            } else {
                              // 첫 실행
                              userId = await registerUser();
                              await prefs.setInt("user_id", userId);
                            }

                            //항상 최신정보 저장
                            await prefs.setString("age", selectedAge);
                            await prefs.setString("coldLevel", coldLevel!);
                            await prefs.setString("heatLevel", heatLevel!);

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                  userId: userId!,
                                  age: selectedAge,
                                  coldLevel: coldLevel!,
                                  heatLevel: heatLevel!,
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

  Widget _buildLevelButtons({
    required String? selectedValue,
    required void Function(String value) onSelected,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(levelOptions.length, (index) {
        final String option = levelOptions[index];
        final bool isSelected = selectedValue == option;

        return GestureDetector(
          onTap: () {
            onSelected(option);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 108,
            height: 54,
            decoration: BoxDecoration(
              color: isSelected
                  ? sungshinViolet
                  : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? sungshinViolet
                    : sungshinViolet.withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: sungshinViolet.withOpacity(isSelected ? 0.18 : 0.05),
                  blurRadius: isSelected ? 14 : 10,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : sungshinBrightViolet,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
