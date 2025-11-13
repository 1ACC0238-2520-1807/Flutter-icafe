import 'package:flutter/material.dart';
import '../../features/auth/domain/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.email),
        subtitle: Text('Roles: ${user.roles.join(', ')}'),
      ),
    );
  }
}
