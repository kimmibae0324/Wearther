import 'package:flutter/material.dart';
import 'home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color softViolet = Color(0xFFF3EFFA);
  static const Color textDark = Color(0xFF2E2440);

  String selectedAge = '10대';
  String? coldLevel;
  String? heatLevel;

  final List<String> ages = ['10대', '20대', '30대', '40대', '50대', '60+'];
  final List<String> levels = ['안탐', '보통', '잘탐'];

  bool get isCompleted {
    return coldLevel != null && heatLevel != null;
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
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: sungshinViolet,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      '나에게 맞는 추천을 위해',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      '기본 정보를 알려주세요',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: sungshinViolet,
                      ),
                    ),

                    const SizedBox(height: 42),

                    _buildSectionTitle('나이대'),
                    _buildAgeDropdown(),

                    const SizedBox(height: 34),

                    _buildSectionTitle('추위를 많이 타나요?'),
                    _buildChoiceGroup(
                      items: levels,
                      selectedValue: coldLevel,
                      onSelected: (value) {
                        setState(() {
                          coldLevel = value;
                        });
                      },
                    ),

                    const SizedBox(height: 34),

                    _buildSectionTitle('더위를 많이 타나요?'),
                    _buildChoiceGroup(
                      items: levels,
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
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCompleted ? sungshinViolet : softViolet,
                          foregroundColor:
                              isCompleted ? Colors.white : sungshinBrightViolet,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: isCompleted
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      age: selectedAge,
                                      coldLevel: coldLevel!,
                                      heatLevel: heatLevel!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2D9F0),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 6),
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
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(18),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: sungshinBrightViolet,
          ),
          items: ages.map((age) {
            return DropdownMenuItem<String>(
              value: age,
              child: Text(age),
            );
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

  Widget _buildChoiceGroup({
    required List<String> items,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final bool isSelected = selectedValue == item;

        return GestureDetector(
          onTap: () {
            onSelected(item);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isSelected ? sungshinViolet : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? sungshinViolet : const Color(0xFFE2D9F0),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? sungshinViolet.withOpacity(0.16)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isSelected ? 14 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : sungshinBrightViolet,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}