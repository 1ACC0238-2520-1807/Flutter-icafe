import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../inventory/data/models/inventory_models.dart';
import '../../providers/product_providers.dart';
import '../../data/network/product_service.dart';

class AddEditProductScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int? productId;

  const AddEditProductScreen({super.key, required this.portfolioId, required this.selectedSedeId, this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(Provider.of<ProductService>(context, listen: false), selectedSedeId, productId),
      child: const _AddEditContent(),
    );
  }
}

class _AddEditContent extends StatefulWidget {
  const _AddEditContent();
  @override
  State<_AddEditContent> createState() => _AddEditContentState();
}

class _AddEditContentState extends State<_AddEditContent> {

  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _profitCtrl = TextEditingController();

  SupplyItemResource? _selectedSupplyItem;
  final _qtyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductFormProvider>(context, listen: false);

      provider.addListener(() {
        if (!mounted) return;
        if (_nameCtrl.text.isEmpty && provider.name.isNotEmpty) _nameCtrl.text = provider.name;
        if (_costCtrl.text.isEmpty && provider.costPrice.isNotEmpty) _costCtrl.text = provider.costPrice;
        if (_profitCtrl.text.isEmpty && provider.profitMargin.isNotEmpty) _profitCtrl.text = provider.profitMargin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.productId == null ? "Nuevo Producto" : "Editar Producto"),
        backgroundColor: const Color(0xFF556B2F),
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.errorMessage != null)
              Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Nombre del Producto"),
              onChanged: (v) => provider.name = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costCtrl,
              decoration: const InputDecoration(labelText: "Precio de Costo"),
              keyboardType: TextInputType.number,
              onChanged: (v) => provider.costPrice = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profitCtrl,
              decoration: const InputDecoration(labelText: "Margen de Ganancia (%)"),
              keyboardType: TextInputType.number,
              onChanged: (v) => provider.profitMargin = v,
            ),

            const SizedBox(height: 24),
            const Text("Ingredientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: provider.selectedIngredients.isEmpty
                  ? const Center(child: Text("Sin ingredientes"))
                  : ListView.builder(
                itemCount: provider.selectedIngredients.length,
                itemBuilder: (ctx, i) {
                  final ing = provider.selectedIngredients[i];
                  return ListTile(
                    title: Text(ing.name),
                    subtitle: Text("${ing.quantity} ${ing.unit}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.removeIngredient(ing.supplyItemId),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text("Añadir Ingrediente:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<SupplyItemResource>(
                    isExpanded: true,
                    hint: const Text("Insumo"),
                    initialValue: _selectedSupplyItem,
                    items: provider.availableSupplyItems.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item.name, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSupplyItem = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(labelText: "Cant."),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFFA52A2A), size: 32),
                  onPressed: () {
                    if (_selectedSupplyItem != null && _qtyCtrl.text.isNotEmpty) {
                      provider.addOrUpdateIngredient(_selectedSupplyItem!, _qtyCtrl.text);
                      setState(() {
                        _selectedSupplyItem = null;
                        _qtyCtrl.clear();
                      });
                    }
                  },
                )
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF556B2F)),
                onPressed: () async {
                  final success = await provider.saveProduct(
                    productName: _nameCtrl.text,
                    productCostPrice: _costCtrl.text,
                    productProfitMargin: _profitCtrl.text,
                  );
                  if (success && mounted) Navigator.pop(context);
                },
                child: const Text("Guardar Producto", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}