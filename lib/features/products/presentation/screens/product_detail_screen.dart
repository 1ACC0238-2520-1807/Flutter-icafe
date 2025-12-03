import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_models.dart';
import '../../providers/product_providers.dart';
import '../../data/network/product_service.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int productId;

  const ProductDetailScreen({super.key, required this.portfolioId, required this.selectedSedeId, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailProvider(Provider.of<ProductService>(context, listen: false), productId),
      child: const _ProductDetailContent(),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductDetailProvider>(context);
    final product = provider.product;
    const oliveGreen = Color(0xFF556B2F);

    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (product == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Error cargando producto")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Detalles del Producto"), backgroundColor: oliveGreen, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailCard("Nombre", product.name),
            const SizedBox(height: 8),
            _DetailCard("Precio de Costo", "\$${product.costPrice.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _DetailCard("Margen de Ganancia", "${product.profitMargin.toStringAsFixed(2)}%"),
            const SizedBox(height: 8),
            _DetailCard("Estado", product.status.name),
            const SizedBox(height: 16),

            const Text("Ingredientes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...product.ingredients.map((ing) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ing.name ?? "Desconocido", style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text("${ing.quantity} ${ing.unit ?? 'u'}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 24),
            _ActionButton(
                icon: Icons.edit, label: "Editar Producto", color: const Color(0xFFA52A2A),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddEditProductScreen(portfolioId: "1", selectedSedeId: "1", productId: product.id)
                  )).then((_) => provider.loadProductDetails());
                }
            ),
            const SizedBox(height: 8),
            _ActionButton(
                icon: product.status == ProductStatus.ACTIVE ? Icons.archive : Icons.unarchive,
                label: product.status == ProductStatus.ACTIVE ? "Archivar Producto" : "Activar Producto",
                color: product.status == ProductStatus.ACTIVE ? Colors.orange : oliveGreen,
                onTap: provider.toggleArchiveStatus
            ),
            const SizedBox(height: 8),
            _ActionButton(
                icon: Icons.delete, label: "Eliminar Producto", color: Colors.red,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                          title: const Text("Confirmar"),
                          content: const Text("¿Eliminar producto?"),
                          actions: [TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text("No")), TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text("Si"))]
                      )
                  );
                  if (confirm == true) {
                    final success = await provider.deleteProduct();
                    if (success) Navigator.pop(context);
                  }
                }
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label, value;
  const _DetailCard(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: onTap,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon), const SizedBox(width: 8), Text(label)]),
    );
  }
}