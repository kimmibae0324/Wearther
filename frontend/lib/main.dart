import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const WeartherApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('알림 초기화 오류: $e');
    }
  });
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
        fontFamily: 'LINESeedKR',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF582F82),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8EC),
      ),
      home: const StartScreen(),
    );
  }
}