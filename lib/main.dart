import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ICafeApp());
}

class ICafeApp extends StatelessWidget {
  const ICafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iCafe',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginScreen(),
    );
  }
}
