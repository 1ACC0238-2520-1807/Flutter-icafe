import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/theme.dart';
import 'utils/secure_storage.dart';

void main() {
  runApp(const ICafeApp());
}

class ICafeApp extends StatelessWidget {
  const ICafeApp({super.key});

  Future<bool> isAuthenticated() async {
    final token = await SecureStorage.readToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iCafe',
      theme: icafeTheme,
      home: FutureBuilder<bool>(
        future: isAuthenticated(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data! ? const DashboardScreen() : const LoginScreen();
        },
      ),
    );
  }
}
