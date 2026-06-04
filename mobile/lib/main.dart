import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FishDiseaseApp());
}

class FishDiseaseApp extends StatelessWidget {
  const FishDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Disease Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
