import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_providers.dart';
import '../../data/network/contacts_service.dart';
import 'add_edit_employee_screen.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int employeeId;

  const EmployeeDetailScreen({super.key, required this.portfolioId, required this.selectedSedeId, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeDetailProvider(
          Provider.of<ContactsService>(context, listen: false),
          portfolioId, selectedSedeId, employeeId
      ),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeDetailProvider>(context);
    final emp = provider.employee;
    const brownMedium = Color(0xFFA52A2A);

    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (emp == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Error cargando empleado")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Ver más Empleado"), backgroundColor: const Color(0xFF556B2F), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: brownMedium, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(child: Text(emp.name, style: const TextStyle(color: Colors.white, fontSize: 20))),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AddEditEmployeeScreen(portfolioId: provider.portfolioId, selectedSedeId: provider.selectedSedeId, employeeId: emp.id)
                      )); // La actualización de la lista se maneja al volver a la lista principal
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DetailItem("Rol", emp.role),
            const SizedBox(height: 16),
            _DetailItem("Gmail", emp.email),
            const SizedBox(height: 16),
            _DetailItem("Teléfono", emp.phoneNumber),
            const SizedBox(height: 16),
            _DetailItem("Sueldo", emp.salary),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: brownMedium, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                          title: "¿Quiere eliminar este empleado?",
                          onConfirm: () async {
                            Navigator.pop(context);
                            final success = await provider.deleteEmployee();
                            if (success && context.mounted) Navigator.pop(context);
                          },
                          onDismiss: () => Navigator.pop(context),
                          backgroundColor: brownMedium
                      )
                  );
                },
                child: const Text("Eliminar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label, value;
  const _DetailItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5D4037))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      )
    ]);
  }
}