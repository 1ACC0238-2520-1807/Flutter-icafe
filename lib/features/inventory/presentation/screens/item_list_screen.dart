import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/inventory_models.dart';
import '../../providers/item_list_provider.dart';
import '../../data/network/inventory_service.dart';

class ItemListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const ItemListScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ItemListProvider(
          Provider.of<InventoryService>(context, listen: false),
          portfolioId,
          selectedSedeId
      )..loadItems(),
      child: const _ItemListContent(),
    );
  }
}

class _ItemListContent extends StatelessWidget {
  const _ItemListContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemListProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Insumos")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF556B2F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
        },
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _HeaderCard("Nombre"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _HeaderCard("Cantidad"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.status == ItemListStatus.loading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF556B2F)));
                  } else if (provider.status == ItemListStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(provider.errorMessage, style: const TextStyle(color: Colors.red)),
                          ElevatedButton(onPressed: provider.loadItems, child: const Text("Reintentar"))
                        ],
                      ),
                    );
                  } else if (provider.items.isEmpty) {
                    return const Center(child: Text("No hay insumos registrados."));
                  }

                  return ListView.separated(
                    itemCount: provider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      return _ItemListItem(
                          item: item,
                          onTap: () {
                          }
                      );
                    },
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

class _HeaderCard extends StatelessWidget {
  final String text;
  const _HeaderCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA52A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ItemListItem extends StatelessWidget {
  final SupplyItemWithCurrentStock item;
  final VoidCallback onTap;

  const _ItemListItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(item.item.name, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "${item.currentStock.toStringAsFixed(1)} ${item.item.unit.toLowerCase()}",
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}