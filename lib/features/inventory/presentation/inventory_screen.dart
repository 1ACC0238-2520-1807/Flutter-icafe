import 'package:flutter/material.dart';
import 'screens/item_list_screen.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class InventoryScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final VoidCallback? onBack;

  const InventoryScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const oliveGreen = Color(0xFF8B7355);
    const darkBrown = Color(0xFF9E8B7E);
    const lightPeach = Color(0xFFF5E6D3);

    return Scaffold(
      backgroundColor: lightPeach,
      appBar: CustomAppBar(
        title: 'Inventario',
        onBackPressed: onBack ?? () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con descripción
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Inventario',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administra tus insumos y productos',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8B7355).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Botón Administrar Insumos
            _buildInventoryButton(
              context,
              icon: Icons.inventory_2,
              title: 'Administrar Insumos',
              description: 'Gestiona tus insumos y materias primas',
              backgroundColor: oliveGreen,
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
            // Botón Administrar Productos
            _buildInventoryButton(
              context,
              icon: Icons.local_cafe,
              title: 'Administrar Productos',
              description: 'Gestiona los productos de tu cafetería',
              backgroundColor: darkBrown,
              onPressed: () {
                // TODO: Conectar ProductListScreen cuando la tengas lista
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
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.black.withValues(alpha: 0.1),
        highlightColor: Colors.black.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Icono
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Flecha
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}