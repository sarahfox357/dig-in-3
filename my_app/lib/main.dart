import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_page.dart';
import 'constants/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Recipe App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: Theme.of(context).textTheme,
      ),
      home: const WelcomeScreen(),
    );
  }
}
