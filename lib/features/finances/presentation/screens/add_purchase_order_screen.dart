import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../contacts/data/models/contact_models.dart';
import '../../../contacts/data/network/contacts_service.dart';
import '../../../inventory/data/models/inventory_models.dart';
import '../../../inventory/data/network/inventory_service.dart';
import '../../providers/purchase_providers.dart';
import '../../data/network/finance_service.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

class AddPurchaseOrderScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const AddPurchaseOrderScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPurchaseOrderProvider(
          Provider.of<FinanceService>(context, listen: false),
          Provider.of<ContactsService>(context, listen: false),
          Provider.of<InventoryService>(context, listen: false),
          portfolioId,
          selectedSedeId
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
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddPurchaseOrderProvider>(context);
    const oliveGreen = Color(0xFF556B2F);

    if (provider.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Compra"), backgroundColor: oliveGreen, foregroundColor: Colors.white),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: oliveGreen))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (provider.errorMessage != null)
              Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red))),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: oliveGreen, borderRadius: BorderRadius.circular(16)),
              child: const Text("Nueva Compra", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<ProviderResource>(
              decoration: const InputDecoration(labelText: "Seleccionar Proveedor *", border: OutlineInputBorder()),
              value: provider.selectedProvider,
              items: provider.availableProviders.map((p) => DropdownMenuItem(value: p, child: Text(p.nameCompany))).toList(),
              onChanged: provider.setProvider,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<SupplyItemResource>(
              decoration: const InputDecoration(labelText: "Seleccionar Insumo *", border: OutlineInputBorder()),
              value: provider.selectedSupplyItem,
              items: provider.availableSupplyItems.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: provider.setSupplyItem,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad *", border: OutlineInputBorder()),
              onChanged: provider.setQuantity,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Precio Unitario *", border: OutlineInputBorder()),
              onChanged: provider.setUnitPrice,
            ),
            const SizedBox(height: 16),

            _DatePickerField(
                label: "Fecha de Compra",
                date: provider.purchaseDate,
                onSelect: provider.setPurchaseDate
            ),
            const SizedBox(height: 16),
            _DatePickerField(
                label: "Vencimiento (Opcional)",
                date: provider.expirationDate,
                onSelect: provider.setExpirationDate
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: "Notas (Opcional)", border: OutlineInputBorder()),
              onChanged: provider.setNotes,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: provider.isSubmitting ? null : () {
                  showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                        title: "¿Registrar esta compra?",
                        onConfirm: () {
                          Navigator.pop(context);
                          provider.registerPurchaseOrder();
                        },
                        onDismiss: () => Navigator.pop(context),
                      )
                  );
                },
                child: provider.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrar Compra", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime) onSelect;

  const _DatePickerField({required this.label, required this.date, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final text = date == null ? "" : "${date!.year}-${date!.month.toString().padLeft(2,'0')}-${date!.day.toString().padLeft(2,'0')}";
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(text: text),
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100)
        );
        if (picked != null) onSelect(picked);
      },
    );
  }
}