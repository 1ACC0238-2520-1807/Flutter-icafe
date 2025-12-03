import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_providers.dart';
import '../../data/network/product_service.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const ProductListScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductListProvider(Provider.of<ProductService>(context, listen: false), selectedSedeId),
      child: const _ProductListContent(),
    );
  }
}

class _ProductListContent extends StatelessWidget {
  const _ProductListContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductListProvider>(context);
    final themeColor = const Color(0xFF556B2F); // OliveGreen

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Productos"), backgroundColor: themeColor, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditProductScreen(portfolioId: "1", selectedSedeId: provider.selectedSedeId)));
        },
      ),
      body: Builder(builder: (context) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF556B2F)));
        if (provider.errorMessage != null) return Center(child: Text(provider.errorMessage!));
        if (provider.products.isEmpty) return const Center(child: Text("No hay productos registrados."));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _HeaderCard("Producto")),
                  const SizedBox(width: 8),
                  Expanded(flex: 1, child: _HeaderCard("Precio")),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final product = provider.products[index];
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text("\$${product.costPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(portfolioId: "1", selectedSedeId: provider.selectedSedeId, productId: product.id)
                        )).then((_) => provider.loadProducts());
                      },
                    ),
                  );
                },
              ),
            )
          ],
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String text;
  const _HeaderCard(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFA52A2A), borderRadius: BorderRadius.circular(12)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}