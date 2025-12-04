import 'package:flutter/material.dart';
import 'sales_list_screen.dart';
import 'purchase_order_list_screen.dart';

class FinanceLandingScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const FinanceLandingScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
  });

  @override
  Widget build(BuildContext context) {
    const oliveGreen = Color(0xFF556B2F);
    const peach = Color(0xFFFFDAB9);
    const brownDark = Color(0xFF5D4037);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text("Finanzas"),
        backgroundColor: oliveGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: oliveGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    "Gestión Financiera",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Administra tus ventas y compras",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón Administrar Ventas
            _FinanceLandingButton(
              text: "Administrar Ventas",
              icon: Icons.monetization_on,
              backgroundColor: peach,
              iconColor: brownDark,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SalesListScreen(portfolioId: portfolioId, selectedSedeId: selectedSedeId)
                ));
              },
            ),
            const SizedBox(height: 24),

            // Botón Administrar Compras
            _FinanceLandingButton(
              text: "Administrar Compras",
              icon: Icons.shopping_cart,
              backgroundColor: peach,
              iconColor: brownDark,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PurchaseOrderListScreen(portfolioId: portfolioId, selectedSedeId: selectedSedeId)
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceLandingButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _FinanceLandingButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}