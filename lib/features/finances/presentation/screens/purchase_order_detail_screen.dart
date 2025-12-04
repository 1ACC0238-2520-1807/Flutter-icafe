import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../inventory/data/network/inventory_service.dart';
import '../../providers/purchase_providers.dart';
import '../../data/network/finance_service.dart';

class PurchaseOrderDetailScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int purchaseOrderId;

  const PurchaseOrderDetailScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    required this.purchaseOrderId
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseOrderDetailProvider(
          Provider.of<FinanceService>(context, listen: false),
          Provider.of<InventoryService>(context, listen: false),
          purchaseOrderId,
          int.parse(selectedSedeId)
      ),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PurchaseOrderDetailProvider>(context);
    final order = provider.purchaseOrder;

    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (order == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Error cargando detalle")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Detalle de Compra"), backgroundColor: const Color(0xFF556B2F), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFA52A2A), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text("Detalle de Orden de Compra", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("ID: ${order.id}", style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                  _InfoRow("Proveedor:", order.providerName),
                  _InfoRow("Insumo:", provider.resolvedSupplyItemName),
                  _InfoRow("Cantidad:", "${order.quantity}"),
                  _InfoRow("Precio Unitario:", "S/. ${order.unitPrice.toStringAsFixed(2)}"),
                  _InfoRow("Monto Total:", "S/. ${order.totalAmount.toStringAsFixed(2)}"),
                  _InfoRow("Fecha:", order.purchaseDate),
                  _InfoRow("Vencimiento:", order.expirationDate ?? "N/A"),
                  _InfoRow("Estado:", order.status),
                  if (order.notes != null) _InfoRow("Notas:", order.notes!),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA52A2A)),
                onPressed: () => Navigator.pop(context),
                child: const Text("Volver", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}