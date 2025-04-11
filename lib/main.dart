import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'utils/ad_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdManager.initialize(); // Init ads
  runApp(const ColorSparkApp());
}

class ColorSparkApp extends StatelessWidget {
  const ColorSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ColorSpark 🎨',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.lightBlue[50],
        fontFamily: 'ComicSans',
      ),
      home: const WelcomeScreen(),
    );
  }
}