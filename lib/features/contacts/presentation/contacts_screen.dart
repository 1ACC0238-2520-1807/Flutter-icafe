import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  final int branchId;
  final String sedeName;

  const ContactsScreen({
    super.key,
    required this.branchId,
    required this.sedeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D4037),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: AppBar(
            title: const Text('Contactos'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Gestión de Contactos',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF6F4E37),
          ),
        ),
      ),
    );
  }
}
