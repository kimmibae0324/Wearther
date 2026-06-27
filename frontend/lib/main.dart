import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const WeartherApp());
}

class WeartherApp extends StatelessWidget {
  const WeartherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wearther',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5F8D72),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8EC),
      ),
      home: const StartScreen(),
    );
  }
}