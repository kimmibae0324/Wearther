import 'package:flutter/material.dart';
import 'user_info_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  static const Color sungshinViolet = Color(0xFF582F82);
  static const Color sungshinBrightViolet = Color(0xFF6B6EB3);
  static const Color softViolet = Color(0xFFF3EFFA);

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
                  children: [
                    const SizedBox(height: 72),

                    const Text(
                      'Wearther',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        color: sungshinViolet,
                      ),
                    ),

                    const Spacer(),
                    //수룡 캐릭터
                    SizedBox(
                      width: 500,
                      height: 500,
                      child: Image.asset(
                        'assets/characters/dragon_base.png',
                        fit: BoxFit.contain,
                      ),
                    ),  
                    
                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sungshinViolet,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserInfoScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '시작하기',
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
}