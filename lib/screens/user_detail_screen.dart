import 'package:flutter/material.dart';
import '../models/user.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuario: ${user.email}')),
      body: Padding(
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
              children: user.roles
                  .map((role) => Chip(label: Text(role)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
