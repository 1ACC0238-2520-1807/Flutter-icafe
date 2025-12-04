import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../inventory/data/network/inventory_service.dart';
import '../../../products/data/network/product_service.dart';
import '../../providers/sales_providers.dart';
import '../../data/network/finance_service.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../products/data/models/product_models.dart';

class AddSaleScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const AddSaleScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddSaleProvider(
          Provider.of<FinanceService>(context, listen: false),
          Provider.of<ProductService>(context, listen: false),
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
  final _customerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddSaleProvider>(context);
    const oliveGreen = Color(0xFF556B2F);
    const brownDark = Color(0xFF5D4037);

    if (provider.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    if (provider.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.infoMessage!)));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Venta"), backgroundColor: oliveGreen, foregroundColor: Colors.white),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: oliveGreen))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.errorMessage != null)
              Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red))),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: oliveGreen, borderRadius: BorderRadius.circular(16)),
              child: const Text("Nueva Venta", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _customerCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "ID Cliente", border: OutlineInputBorder()),
              onChanged: (v) => provider.customerId = v,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: "Notas (Opcional)", border: OutlineInputBorder()),
              onChanged: (v) => provider.notes = v,
            ),
            const SizedBox(height: 16),

            const Text("Productos:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
            const SizedBox(height: 8),

            Container(
              height: 250,
              decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
              child: provider.selectedSaleItems.isEmpty
                  ? const Center(child: Text("No hay productos añadidos."))
                  : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: provider.selectedSaleItems.length,
                separatorBuilder: (_,__) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final item = provider.selectedSaleItems[i];
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: brownDark)),
                            Text("S/. ${item.unitPrice}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ]),
                        ),
                        const Text("Cant: "),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(text: item.quantity)..selection = TextSelection.fromPosition(TextPosition(offset: item.quantity.length)),
                            onChanged: (val) => provider.updateSaleItemQuantity(i, val),
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(4)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => provider.removeSaleItem(i),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA52A2A)),
                onPressed: provider.isSubmitting ? null : () => _showProductPicker(context, provider),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Añadir Producto", style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brownDark)),
                Text("S/. ${provider.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brownDark)),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: provider.isSubmitting ? null : () {
                  showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                        title: "¿Registrar esta venta?",
                        onConfirm: () {
                          Navigator.pop(context);
                          provider.registerSale();
                        },
                        onDismiss: () => Navigator.pop(context),
                      )
                  );
                },
                child: provider.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrar Venta", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductPicker(BuildContext context, AddSaleProvider provider) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
          // CORRECCIÓN: Usamos RoundedRectangleBorder en lugar de RoundedCornerShape
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Seleccionar Producto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: provider.availableProducts.length,
                    separatorBuilder: (_,__) => const Divider(),
                    itemBuilder: (c, i) {
                      final p = provider.availableProducts[i];
                      return ListTile(
                        title: Text(p.name),
                        trailing: Text("S/. ${p.salePrice}"),
                        onTap: () {
                          provider.addProductToSale(p);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar"))
              ],
            ),
          ),
        )
    );
  }
}