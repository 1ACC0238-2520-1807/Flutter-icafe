import 'package:flutter/material.dart';
import 'pages/contactos_screen.dart';
import 'pages/empleados_screen.dart';
import 'pages/proveedores_screen.dart';

class ContactsContainer extends StatefulWidget {
  final int branchId;
  final int selectedIndex; // del nav bar principal
  final Function(int) onNavigationChanged;
  final VoidCallback? onBack; // Callback para retroceder

  const ContactsContainer({
    super.key,
    required this.branchId,
    required this.selectedIndex,
    required this.onNavigationChanged,
    this.onBack,
  });

  @override
  State<ContactsContainer> createState() => _ContactsContainerState();
}

class _ContactsContainerState extends State<ContactsContainer> {
  late int _contactsSubIndex; // 0: Contactos, 1: Empleados, 2: Proveedores

  @override
  void initState() {
    super.initState();
    _contactsSubIndex = 0;
  }

  Widget _buildCurrentContactScreen() {
    switch (_contactsSubIndex) {
      case 0:
        return ContactosScreen(
          branchId: widget.branchId,
          onEmpleadosPressed: () {
            setState(() => _contactsSubIndex = 1);
          },
          onProveedoresPressed: () {
            setState(() => _contactsSubIndex = 2);
          },
          onBack: widget.onBack,
        );
      case 1:
        return EmpleadosScreen(
          branchId: widget.branchId,
          onBack: () {
            setState(() => _contactsSubIndex = 0);
          },
        );
      case 2:
        return ProveedoresScreen(
          branchId: widget.branchId,
          onBack: () {
            setState(() => _contactsSubIndex = 0);
          },
        );
      default:
        return ContactosScreen(
          branchId: widget.branchId,
          onEmpleadosPressed: () {
            setState(() => _contactsSubIndex = 1);
          },
          onProveedoresPressed: () {
            setState(() => _contactsSubIndex = 2);
          },
          onBack: widget.onBack,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentContactScreen();
  }
}
