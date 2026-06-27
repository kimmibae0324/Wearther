import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color softViolet = Color(0xFFF3EFFA);
  static const Color textDark = Color(0xFF2E2440);

  bool isAlarmOn = true;

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

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: sungshinViolet,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      '추가 기능',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '알림과 설정을 관리해요',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: sungshinBrightViolet,
                      ),
                    ),

                    const SizedBox(height: 34),

                    _buildAlarmCard(),

                    const SizedBox(height: 18),

                    _buildMenuCard(),

                    const Spacer(),

                    Center(
                      child: Text(
                        'Wearther v1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: sungshinBrightViolet.withOpacity(0.8),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: softViolet,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: sungshinViolet,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시간대별 알림',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '오늘의 옷차림을 알려드려요',
                  style: TextStyle(
                    fontSize: 13,
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
            activeTrackColor: sungshinBrightViolet.withOpacity(0.35),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2D9F0),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2D9F0),
        ),
        boxShadow: [
          BoxShadow(
            color: sungshinViolet.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.person_rounded,
            title: '사용자 정보 수정',
            subtitle: '나이대, 추위/더위 민감도 변경',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('사용자 정보 수정 기능은 추후 연결 예정이에요.'),
                ),
              );
            },
          ),  
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.feedback_rounded,
            title: '피드백 보내기',
            subtitle: '추천이 어땠는지 의견 남기기',
            onTap: () {
              _showFeedbackDialog();
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.info_rounded,
            title: '앱 정보',
            subtitle: 'Wearther 프로젝트 소개',
            onTap: () {
              _showAppInfoDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: softViolet,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(
          icon,
          color: sungshinViolet,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: sungshinBrightViolet,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: sungshinBrightViolet,
      ),
      onTap: onTap,
    ),
  );
}

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 84, right: 20),
      child: Divider(
        height: 1,
        color: const Color(0xFFE2D9F0).withOpacity(0.9),
      ),
    );
  }

  void _showFeedbackDialog() {
  String selectedFeedback = '좋았어요';
  final TextEditingController feedbackController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '오늘 Wearther의 추천은\n어떠셨나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 수룡 캐릭터 임시 영역
                  Container(
                    width: 118,
                    height: 118,
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
                        child: _buildSelectableFeedbackButton(
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
                        child: _buildSelectableFeedbackButton(
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
                        child: _buildSelectableFeedbackButton(
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

                  const SizedBox(height: 18),

                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '추가 의견을 남겨주세요',
                      hintStyle: TextStyle(
                        color: sungshinBrightViolet.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: softViolet,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                              '닫기',
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
          );
        },
      );
    },
  );
}

Widget _buildSelectableFeedbackButton({
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

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Wearther',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: sungshinViolet,
            ),
          ),
          content: const Text(
            'Wearther는 날씨 정보와 사용자 성향을 바탕으로 오늘의 옷차림을 추천하는 앱입니다.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: textDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '닫기',
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
}