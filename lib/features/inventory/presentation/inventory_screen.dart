import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  final int branchId;
  final String sedeName;

  const InventoryScreen({
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
            title: const Text('Inventario'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
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
                    'Gestión de Alimentos',
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
              icon: Icons.shopping_cart,
              title: 'Administrar Insumos',
              description: 'Gestiona tus insumos y materias primas',
              backgroundColor: const Color(0xFF8B7355),
              onPressed: () {
                // TODO: Navegar a pantalla de administración de insumos
              },
            ),
            const SizedBox(height: 20),
            // Botón Administrar Productos
            _buildInventoryButton(
              context,
              icon: Icons.local_cafe,
              title: 'Administrar Productos',
              description: 'Gestiona los productos de tu cafetería',
              backgroundColor: const Color(0xFF9E8B7E),
              onPressed: () {
                // TODO: Navegar a pantalla de administración de productos
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
      child: InkWell(
        onTap: onPressed,
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