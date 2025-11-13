import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'core/ui/theme.dart';
import 'features/auth/data/secure_storage.dart';

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
    final IcafeTheme theme = IcafeTheme(TextTheme());
    return MaterialApp(
      title: 'iCafe_Flutter',
      theme: theme.light(),
      darkTheme: theme.dark(),
      home: FutureBuilder<bool>(
        future: isAuthenticated(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data! ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
