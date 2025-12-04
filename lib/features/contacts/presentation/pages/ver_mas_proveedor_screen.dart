import 'package:flutter/material.dart';
import '../../domain/entities/proveedor.dart';

class VerMasProveedorScreen extends StatelessWidget {
  final Proveedor proveedor;
  final int portfolioId;
  final VoidCallback? onBack;
  final VoidCallback? onEditar;

  const VerMasProveedorScreen({
    super.key,
    required this.proveedor,
    required this.portfolioId,
    this.onBack,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFF5E6D3);
    const oliveGreen = Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: lightPeach,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Información del proveedor
            _buildInfoCard('Nombre', proveedor.nombre),
            const SizedBox(height: 16),
            _buildInfoCard('RUC', proveedor.ruc),
            const SizedBox(height: 16),
            _buildInfoCard('Gmail', proveedor.gmail),
            const SizedBox(height: 16),
            _buildInfoCard('Teléfono', proveedor.telefono),
            const SizedBox(height: 32),
            // Botón Editar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: oliveGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  if (onEditar != null) {
                    onEditar!();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.edit, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Editar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}

