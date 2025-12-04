import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/inventory_models.dart';
import '../../data/network/inventory_service.dart';
import '../../providers/movements_provider.dart';

class InventoryMovementsScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const InventoryMovementsScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryMovementsProvider(
        Provider.of<InventoryService>(context, listen: false),
        portfolioId,
        selectedSedeId,
      ),
      child: const _MovementsContent(),
    );
  }
}

class _MovementsContent extends StatelessWidget {
  const _MovementsContent();

  static const oliveGreen = Color(0xFF556B2F);
  static const brownDark = Color(0xFF5D4037);
  static const brownMedium = Color(0xFFA52A2A);
  static const peach = Color(0xFFFFDAB9);
  static const offWhite = Color(0xFFF5F3F0);
  static const lightGray = Color(0xFFEEEEEE);
  static const redWarning = Color(0xFFB00020);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryMovementsProvider>(context);

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        title: const Text("Movimientos de Inventario"),
        backgroundColor: oliveGreen,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: oliveGreen));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: oliveGreen),
                    onPressed: provider.loadMovements,
                    child: const Text("Reintentar", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          if (provider.movements.isEmpty) {
            return const Center(
              child: Text(
                "No hay movimientos registrados para esta sede.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Movimientos",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: brownDark
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: brownMedium,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: provider.movements.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                            itemBuilder: (ctx, index) {
                              final movement = provider.movements[index];
                              return _MovementListItem(
                                movement: movement,
                                isSelected: movement == provider.selectedMovement,
                                onTap: () => provider.selectMovement(movement),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),


                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.selectedMovement != null
                            ? "Movimiento ${provider.selectedMovement!.id}"
                            : "Seleccione un movimiento",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: brownDark
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: provider.selectedMovement != null
                            ? _MovementDetailCard(
                          movement: provider.selectedMovement!,
                          supplyItem: provider.supplyItemDetails[provider.selectedMovement!.supplyItemId],
                        )
                            : Container(
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text("No hay movimiento seleccionado", style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MovementListItem extends StatelessWidget {
  final InventoryTransactionResource movement;
  final bool isSelected;
  final VoidCallback onTap;

  const _MovementListItem({
    required this.movement,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final backgroundColor = isSelected ? const Color(0xFFFFDAB9) : const Color(0xFFEEEEEE);
    final contentColor = isSelected ? const Color(0xFF5D4037) : Colors.black;
    final indicatorColor = movement.type == TransactionType.ENTRADA
        ? const Color(0xFF556B2F)
        : const Color(0xFFB00020);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Movimiento ${movement.id}",
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para el detalle completo (Derecha)
class _MovementDetailCard extends StatelessWidget {
  final InventoryTransactionResource movement;
  final SupplyItemResource? supplyItem;

  const _MovementDetailCard({required this.movement, this.supplyItem});

  @override
  Widget build(BuildContext context) {
    const brownDark = Color(0xFF5D4037);
    const oliveGreen = Color(0xFF556B2F);
    const redWarning = Color(0xFFB00020);

    String formattedDate = movement.movementDate;
    try {
      final parsedDate = DateTime.parse(movement.movementDate);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (_) {}

    final typeColor = movement.type == TransactionType.ENTRADA ? oliveGreen : redWarning;
    final typeText = movement.type == TransactionType.ENTRADA ? "ENTRADA" : "SALIDA";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE), // LightGray
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailField(label: "Identificador", value: movement.id.toString()),
            const SizedBox(height: 12),
            _DetailField(label: "Origen", value: movement.origin),
            const SizedBox(height: 12),
            _DetailField(label: "Insumo", value: supplyItem?.name ?? "Desconocido (ID: ${movement.supplyItemId})"),
            const SizedBox(height: 12),

            const Text(
              "Tipo de Movimiento:",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    typeText,
                    style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${movement.quantity.toStringAsFixed(1)} ${supplyItem?.unit ?? ''}",
                  style: const TextStyle(color: brownDark, fontSize: 18, fontWeight: FontWeight.w500),
                )
              ],
            ),

            const SizedBox(height: 12),
            _DetailField(label: "Fecha", value: formattedDate),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;

  const _DetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3F0), // OffWhite
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF5D4037), fontSize: 16),
          ),
        ),
      ],
    );
  }
}