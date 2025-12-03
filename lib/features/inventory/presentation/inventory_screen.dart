import 'package:flutter/material.dart';
import '../screens/item_list_screen.dart';
// import 'product_list_screen.dart';

class InventoryScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const InventoryScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
  });

  @override
  Widget build(BuildContext context) {
    const oliveGreen = Color(0xFF556B2F);
    const brownDark = Color(0xFF5D4037);
    const peach = Color(0xFFFFDAB9);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: oliveGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'Gestión de Alimentos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Administra tus insumos y productos',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildInventoryButton(
              context,
              icon: Icons.shopping_cart,
              title: 'Administrar Insumos',
              description: 'Gestiona tus insumos y materias primas',
              backgroundColor: peach,
              iconColor: brownDark,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemListScreen(
                      portfolioId: portfolioId,
                      selectedSedeId: selectedSedeId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            _buildInventoryButton(
              context,
              icon: Icons.local_cafe,
              title: 'Administrar Productos',
              description: 'Gestiona los productos de tu cafetería',
              backgroundColor: peach,
              iconColor: brownDark,
              onPressed: () {
                // TODO: Conectar ProductListScreen cuando la tengas lista
                print("Navegar a Productos");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color backgroundColor,
        required Color iconColor,
        required VoidCallback onPressed,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}