import 'package:flutter/material.dart';
import 'user_info_screen.dart';
<<<<<<< HEAD
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> 9203642cb738ed838fb46169cbf9bd9ab9ca29f1

class SettingsScreen extends StatefulWidget {
  final int userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color softViolet = Color(0xFFF3EFFA);
  static const Color textDark = Color(0xFF2E2440);
  static const Color borderViolet = Color(0xFFE2D9F0);

  bool isAlarmOn = true;

  static const String umbrellaAlarmKey = 'isUmbrellaAlarmOn';

@override
void initState() {
  super.initState();
  _loadUmbrellaAlarmSetting();
}

Future<void> _loadUmbrellaAlarmSetting() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    isAlarmOn = prefs.getBool(umbrellaAlarmKey) ?? true;
  });
}

Future<void> _saveUmbrellaAlarmSetting(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(umbrellaAlarmKey, value);
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
                padding: const EdgeInsets.symmetric(horizontal: 26),
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

                    const SizedBox(height: 50),

                    const Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 36),

                    _buildAlarmCard(),

                    const SizedBox(height: 24),

                    _buildMenuCard(),

                    const Spacer(),

                    Center(
                      child: Text(
                        'Wearther v1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: sungshinBrightViolet.withOpacity(0.72),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: softViolet.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconBox(icon: Icons.notifications_active_rounded),

          const SizedBox(width: 18),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '우산 알림',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '비 예보가 있으면 알려드려요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sungshinBrightViolet,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: isAlarmOn,
            activeColor: sungshinViolet,
            activeTrackColor: sungshinViolet.withOpacity(0.28),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: borderViolet,
            onChanged: (value) {
              setState(() {
                isAlarmOn = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderViolet, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_rounded,
            title: '사용자 정보 수정',
            subtitle: '나이대, 추위/더위 민감도 변경',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserInfoScreen(isUpdate: true),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildMenuItem(
            icon: Icons.chat_bubble_rounded,
            title: '피드백 보내기',
            subtitle: '추천이 어땠는지 의견 남기기',
            onTap: () {
              _showFeedbackDialog();
            },
          ),
          _buildDivider(),

          _buildMenuItem(
            icon: Icons.info_rounded,
            title: '앱 정보',
            subtitle: 'Wearther 프로젝트 소개',
            onTap: () {
              _showSimpleDialog(
                title: 'Wearther',
                message:
                    'Wearther는 현재 날씨와 사용자의 더위·추위 민감도를 반영해\n'
                    '오늘 입기 좋은 옷차림을 추천해주는 날씨 기반 스타일 추천 앱입니다.\n\n'
                    '캐릭터 수룡이를 통해 날씨 상태를 직관적으로 보여주고,\n'
                    '홈 화면 위젯으로 앱을 열지 않아도 추천 옷차림과 기온을 확인할 수 있습니다.\n\n'
                    '제작자\n'
                    '김미배 · 김서빈 · 정세원\n\n'
                    '제작년월\n'
                    '2026년 6~7월',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox({required IconData icon}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: sungshinViolet, size: 28),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: softViolet.withOpacity(0.88),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: sungshinViolet, size: 26),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: sungshinBrightViolet,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: sungshinBrightViolet,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 68),
      color: borderViolet.withOpacity(0.8),
    );
  }

  void _showSimpleDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/characters/dragon_face_wink.png',
                  width: 92,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: sungshinBrightViolet,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sungshinViolet,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001';
    }

    return 'http://127.0.0.1:8001';
  }

  Future<void> sendFeedback(int userId, String feedback) async {
    await http.post(
      Uri.parse('$apiBaseUrl/user/feedback'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "user_feedback": feedback}),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/characters/dragon_face_wink.png',
                    width: 82,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    '피드백 보내기',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '추천이 어땠는지 자유롭게 알려주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: sungshinBrightViolet,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: feedbackController,
                    maxLines: 6,
                    maxLength: 300,
                    cursorColor: sungshinViolet,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: '예: 추천 옷차림이 조금 추웠어요.\n겉옷을 더 추천해주면 좋겠어요.',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: sungshinBrightViolet.withOpacity(0.55),
                        height: 1.4,
                      ),
                      filled: true,
                      fillColor: softViolet.withOpacity(0.55),
                      counterStyle: TextStyle(
                        color: sungshinBrightViolet.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(
                          color: borderViolet,
                          width: 1.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(
                          color: sungshinViolet,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: sungshinViolet,
                              side: const BorderSide(
                                color: borderViolet,
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              final feedback = feedbackController.text.trim();

                              if (feedback.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('피드백을 입력해주세요.')),
                                );
                                return;
                              }

                              await sendFeedback(widget.userId, feedback);

                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('피드백이 저장되었어요.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sungshinViolet,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              '보내기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
    ).then((_) {
      feedbackController.dispose();
    });
  }
}
