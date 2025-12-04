import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_providers.dart';
import '../../data/network/finance_service.dart';

class SaleDetailScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int saleId;

  const SaleDetailScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    required this.saleId
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SaleDetailProvider(
          Provider.of<FinanceService>(context, listen: false),
          saleId
      ),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SaleDetailProvider>(context);
    final sale = provider.sale;
    const brownMedium = Color(0xFFA52A2A);
    const brownDark = Color(0xFF5D4037);

    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (sale == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Error cargando detalle")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Detalle de Venta"), backgroundColor: const Color(0xFF556B2F), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: brownMedium, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text("Detalle de Venta", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("ID: ${sale.id}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Detalles adicionales:", style: TextStyle(color: brownDark, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Cliente ID: ${sale.customerId}", style: TextStyle(color: brownDark)),
                  Text("Monto Total: S/. ${sale.totalAmount.toStringAsFixed(2)}", style: TextStyle(color: brownDark)),
                  Text("Fecha: ${sale.saleDate.replaceAll('T', ' ').split('.')[0]}", style: TextStyle(color: brownDark)),
                  Text("Estado: ${sale.status}", style: TextStyle(color: brownDark)),
                  if (sale.notes != null) Text("Notas: ${sale.notes}", style: TextStyle(color: brownDark)),

                  const Divider(height: 24),
                  Text("Productos Vendidos:", style: TextStyle(color: brownDark, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (sale.items.isEmpty)
                    const Text("No hay productos.", style: TextStyle(color: Colors.grey))
                  else
                    ...sale.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Prod ID: ${item.productId}", style: TextStyle(color: brownDark, fontSize: 12)),
                          Text("${item.quantity} x S/. ${item.unitPrice.toStringAsFixed(2)} = S/. ${item.subtotal.toStringAsFixed(2)}", style: TextStyle(color: brownDark, fontSize: 12)),
                        ],
                      ),
                    )),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: brownMedium),
                onPressed: () => Navigator.pop(context),
                child: const Text("Volver a la lista", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}