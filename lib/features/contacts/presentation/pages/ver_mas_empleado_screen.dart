import 'package:flutter/material.dart';
import '../../domain/entities/empleado.dart';
import 'editar_empleado_screen.dart';

class VerMasEmpleadoScreen extends StatelessWidget {
  final Empleado empleado;
  final int portfolioId;
  final VoidCallback? onBack;

  const VerMasEmpleadoScreen({
    super.key,
    required this.empleado,
    required this.portfolioId,
    this.onBack,
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
            // Información del empleado
            _buildInfoCard('Nombre', empleado.nombre),
            const SizedBox(height: 16),
            _buildInfoCard('Rol', empleado.rol),
            const SizedBox(height: 16),
            _buildInfoCard('Gmail', empleado.gmail),
            const SizedBox(height: 16),
            _buildInfoCard('Teléfono', empleado.telefono),
            const SizedBox(height: 16),
            _buildInfoCard('Sueldo', '\$${empleado.sueldo}'),
            const SizedBox(height: 32),
            // Botón Editar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: oliveGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarEmpleadoScreen(
                        empleado: empleado,
                        portfolioId: portfolioId,
                        onBack: onBack,
                      ),
                    ),
                  );
                  if (result == true) {
                    Navigator.pop(context); // Volver a la lista si se guardaron cambios
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

