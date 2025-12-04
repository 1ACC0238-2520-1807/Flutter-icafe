import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_providers.dart';
import '../../data/network/contacts_service.dart';
import 'add_edit_employee_screen.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const EmployeeListScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeListProvider(
          Provider.of<ContactsService>(context, listen: false),
          portfolioId,
          selectedSedeId
      ),
      child: const _ListContent(),
    );
  }
}

class _ListContent extends StatelessWidget {
  const _ListContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeListProvider>(context);
    const oliveGreen = Color(0xFF556B2F);
    const brownMedium = Color(0xFFA52A2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Empleados"), backgroundColor: oliveGreen, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Agregar Empleado", style: TextStyle(color: Colors.white, fontSize: 18)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddEditEmployeeScreen(portfolioId: provider.portfolioId, selectedSedeId: provider.selectedSedeId)
                  )).then((_) => provider.loadEmployees());
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: brownMedium, borderRadius: BorderRadius.circular(12)),
              child: const Text("NOMBRE", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: oliveGreen))
                  : provider.employees.isEmpty
                  ? const Center(child: Text("No hay empleados registrados."))
                  : ListView.separated(
                itemCount: provider.employees.length,
                separatorBuilder: (_,__) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final emp = provider.employees[i];
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
                          child: Text(emp.name, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => EmployeeDetailScreen(portfolioId: provider.portfolioId, selectedSedeId: provider.selectedSedeId, employeeId: emp.id)
                          )).then((_) => provider.loadEmployees());
                        },
                        child: const Text("Ver más", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}