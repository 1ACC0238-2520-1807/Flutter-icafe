import 'package:flutter/material.dart';
import 'employee_list_screen.dart';
import 'provider_list_screen.dart';

class ContactsLandingScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const ContactsLandingScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    const oliveGreen = Color(0xFF556B2F);
    const peach = Color(0xFFFFDAB9);
    const brownDark = Color(0xFF5D4037);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Contactos"), backgroundColor: oliveGreen, foregroundColor: Colors.white, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: oliveGreen, borderRadius: BorderRadius.circular(16)),
              child: const Column(
                children: [
                  Text("Gestión de Contactos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Administra tus empleados y proveedores", style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ContactsButton(
                text: "Administrar Empleados",
                icon: Icons.people,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeListScreen(portfolioId: portfolioId, selectedSedeId: selectedSedeId))),
                color: peach, textColor: brownDark
            ),
            const SizedBox(height: 24),
            _ContactsButton(
                text: "Administrar Proveedores",
                icon: Icons.local_shipping,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderListScreen(portfolioId: portfolioId, selectedSedeId: selectedSedeId))),
                color: peach, textColor: brownDark
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsButton extends StatelessWidget {
  final String text; final IconData icon; final VoidCallback onTap; final Color color; final Color textColor;
  const _ContactsButton({required this.text, required this.icon, required this.onTap, required this.color, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [Icon(icon, color: textColor, size: 28), const SizedBox(width: 16), Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))]),
        ),
      ),
    );
  }
}