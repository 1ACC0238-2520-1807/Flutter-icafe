import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  final String role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(role),
      backgroundColor: Colors.indigo.shade100,
      labelStyle: const TextStyle(color: Colors.indigo),
    );
  }
}
