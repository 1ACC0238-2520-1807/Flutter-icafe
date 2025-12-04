import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_providers.dart';
import '../../data/network/contacts_service.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

class AddEditEmployeeScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int? employeeId;

  const AddEditEmployeeScreen({super.key, required this.portfolioId, required this.selectedSedeId, this.employeeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeDetailProvider(
          Provider.of<ContactsService>(context, listen: false),
          portfolioId, selectedSedeId, employeeId
      ),
      child: const _FormContent(),
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent();
  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeDetailProvider>(context, listen: false);
      provider.addListener(() {
        if (!mounted) return;
        if (_nameCtrl.text.isEmpty && provider.name.isNotEmpty) _nameCtrl.text = provider.name;
        if (_roleCtrl.text.isEmpty && provider.role.isNotEmpty) _roleCtrl.text = provider.role;
        if (_emailCtrl.text.isEmpty && provider.email.isNotEmpty) _emailCtrl.text = provider.email;
        if (_phoneCtrl.text.isEmpty && provider.phoneNumber.isNotEmpty) _phoneCtrl.text = provider.phoneNumber;
        if (_salaryCtrl.text.isEmpty && provider.salary.isNotEmpty) _salaryCtrl.text = provider.salary;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeDetailProvider>(context);
    final isEdit = provider.employeeId != null;
    final color = isEdit ? const Color(0xFFFFDAB9) : const Color(0xFF556B2F);
    final textColor = isEdit ? const Color(0xFF5D4037) : Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: Text(isEdit ? "Editar Empleado" : "Agregar Empleado"), backgroundColor: color, foregroundColor: textColor),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
              child: Text(
                  isEdit ? "Editar Empleado" : "Agregar Empleado",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)
              ),
            ),
            const SizedBox(height: 24),
            _StyledField("Nombre", _nameCtrl, (v) => provider.name = v),
            _StyledField("Rol", _roleCtrl, (v) => provider.role = v),
            _StyledField("Gmail", _emailCtrl, (v) => provider.email = v, TextInputType.emailAddress),
            _StyledField("Teléfono", _phoneCtrl, (v) => provider.phoneNumber = v, TextInputType.phone),
            _StyledField("Sueldo", _salaryCtrl, (v) => provider.salary = v, TextInputType.number),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                          title: isEdit ? "¿Guardar cambios?" : "¿Agregar empleado?",
                          onConfirm: () async {
                            Navigator.pop(context);
                            final success = await provider.saveEmployee();
                            if (success && context.mounted) Navigator.pop(context);
                          },
                          onDismiss: () => Navigator.pop(context),
                          backgroundColor: color,
                          textColor: textColor
                      )
                  );
                },
                child: Text(isEdit ? "Guardar Cambios" : "Guardar", style: TextStyle(fontSize: 18, color: textColor)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _StyledField(String label, TextEditingController ctrl, Function(String) onChange, [TextInputType type = TextInputType.text]) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5D4037))),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        keyboardType: type,
        onChanged: onChange,
        decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEEEEEE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
        ),
      )
    ]),
  );
}