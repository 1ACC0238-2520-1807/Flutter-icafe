import 'package:flutter/material.dart';
import 'empleados_screen.dart';
import 'proveedores_screen.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class ContactosScreen extends StatelessWidget {
  final int branchId;
  final VoidCallback? onEmpleadosPressed;
  final VoidCallback? onProveedoresPressed;
  final VoidCallback? onBack;
  
  const ContactosScreen({
    super.key, 
    required this.branchId,
    this.onEmpleadosPressed,
    this.onProveedoresPressed,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: CustomAppBar(
        title: 'Contactos',
        onBackPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.pop(context);
          }
        },
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
                    'Gestión de Contactos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administra tus empleados y proveedores',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8B7355).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Botón Administrar Empleados
            _buildContactButton(
              context,
              icon: Icons.people,
              title: 'Administrar Empleados',
              description: 'Gestiona tus empleados',
              backgroundColor: const Color(0xFF8B7355),
              onPressed: () {
                if (onEmpleadosPressed != null) {
                  onEmpleadosPressed!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmpleadosScreen(
                        branchId: branchId,
                        onBack: onBack,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Botón Administrar Proveedores
            _buildContactButton(
              context,
              icon: Icons.local_shipping,
              title: 'Administrar Proveedores',
              description: 'Gestiona tus proveedores',
              backgroundColor: const Color(0xFF9E8B7E),
              onPressed: () {
                if (onProveedoresPressed != null) {
                  onProveedoresPressed!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProveedoresScreen(
                        branchId: branchId,
                        onBack: onBack,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
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

