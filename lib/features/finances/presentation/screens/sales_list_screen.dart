import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_providers.dart';
import '../../data/network/finance_service.dart';
import 'add_sale_screen.dart';
import 'sale_detail_screen.dart';

class SalesListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const SalesListScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesListProvider(
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
    final provider = Provider.of<SalesListProvider>(context);
    const oliveGreen = Color(0xFF556B2F);
    const brownMedium = Color(0xFFA52A2A);
    const brownDark = Color(0xFF5D4037);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text("Lista de Ventas"),
        backgroundColor: oliveGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: oliveGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddSaleScreen(portfolioId: "1", selectedSedeId: provider.selectedSedeId)
          )).then((_) => provider.loadSales());
        },
      ),
      body: Builder(builder: (context) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: oliveGreen));
        if (provider.errorMessage != null) return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)));
        if (provider.sales.isEmpty) return const Center(child: Text("No hay ventas registradas."));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(color: brownMedium, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Row(
                  children: [
                    Expanded(child: Text("ID Venta", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Monto Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Fecha", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.sales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final sale = provider.sales[index];
                  final datePart = sale.saleDate.split('T')[0];

                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(sale.id.toString(), textAlign: TextAlign.center, style: const TextStyle(color: brownDark))),
                          Expanded(child: Text("S/. ${sale.totalAmount.toStringAsFixed(2)}", textAlign: TextAlign.center, style: const TextStyle(color: brownDark))),
                          Expanded(child: Text(datePart, textAlign: TextAlign.center, style: const TextStyle(color: brownDark))),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => SaleDetailScreen(
                                portfolioId: "1",
                                selectedSedeId: provider.selectedSedeId,
                                saleId: sale.id
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