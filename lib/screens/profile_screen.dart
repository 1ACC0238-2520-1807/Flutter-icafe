import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/secure_storage.dart';
import 'login_screen.dart';
import '../widgets/role_chip.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _user;

  @override
  void initState() {
    super.initState();
    _user = _loadUser();
  }

  Future<User> _loadUser() async {
    final token = await SecureStorage.readToken();
    final email = await SecureStorage.extractEmailFromToken(token!);
    return await UserService().getUserByEmail(email);
  }

  Future<void> _logout() async {
    await SecureStorage.deleteToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar perfil'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${user.id}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Email: ${user.email}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Roles:', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: user.roles.map((r) => RoleChip(role: r)).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
