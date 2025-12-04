import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/purchase_providers.dart';
import '../../data/network/finance_service.dart';
import 'add_purchase_order_screen.dart';
import 'purchase_order_detail_screen.dart';

class PurchaseOrderListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const PurchaseOrderListScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseOrderListProvider(
          Provider.of<FinanceService>(context, listen: false),
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
    final provider = Provider.of<PurchaseOrderListProvider>(context);
    const oliveGreen = Color(0xFF556B2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Lista de Compras"), backgroundColor: oliveGreen, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(
        backgroundColor: oliveGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddPurchaseOrderScreen(portfolioId: "1", selectedSedeId: provider.selectedSedeId)
          )).then((_) => provider.loadPurchaseOrders());
        },
      ),
      body: Builder(builder: (context) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: oliveGreen));
        if (provider.errorMessage != null) return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)));
        if (provider.purchaseOrders.isEmpty) return const Center(child: Text("No hay órdenes de compra registradas."));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFA52A2A), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Row(
                  children: [
                    Expanded(child: Text("ID", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Proveedor", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.purchaseOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final order = provider.purchaseOrders[index];
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(order.id.toString(), textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text(order.providerName, textAlign: TextAlign.center)),
                          Expanded(child: Text("S/. ${order.totalAmount.toStringAsFixed(2)}", textAlign: TextAlign.center)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PurchaseOrderDetailScreen(
                                portfolioId: "1",
                                selectedSedeId: provider.selectedSedeId,
                                purchaseOrderId: order.id
                            )
                        ));
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