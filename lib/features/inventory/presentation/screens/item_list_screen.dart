import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/inventory_models.dart';
import '../../providers/item_list_provider.dart';
import '../../data/network/inventory_service.dart';

class ItemListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final void Function(int supplyItemId)? onItemSelected;
  final VoidCallback? onAddItem;

  const ItemListScreen({
    super.key, 
    required this.portfolioId, 
    required this.selectedSedeId,
    this.onItemSelected,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ItemListProvider(
          Provider.of<InventoryService>(context, listen: false),
          portfolioId,
          selectedSedeId
      )..loadItems(),
      child: _ItemListContent(
        onItemSelected: onItemSelected,
        onAddItem: onAddItem,
      ),
    );
  }
}

class _ItemListContent extends StatelessWidget {
  final void Function(int supplyItemId)? onItemSelected;
  final VoidCallback? onAddItem;

  const _ItemListContent({
    this.onItemSelected,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemListProvider>(context);

    return Stack(
      children: [
        // Contenido principal
        _buildContent(context, provider),
        // Botón flotante
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildFloatingButton(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ItemListProvider provider) {
    if (provider.status == ItemListStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8B7355),
        ),
      );
    }
    
    if (provider.status == ItemListStatus.error) {
      return _buildErrorState(provider);
    }
    
    if (provider.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => provider.loadItems(),
      color: const Color(0xFF8B7355),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(provider.items[index]);
        },
      ),
    );
  }

  Widget _buildItemCard(SupplyItemWithCurrentStock item) {
    final stockColor = item.currentStock > 0 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onItemSelected != null) {
              onItemSelected!(item.item.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF8B7355),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6F4E37),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Badge de unidad
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatUnit(item.item.unit),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Precio unitario
                          Text(
                            'S/ ${item.item.unitPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.currentStock.toStringAsFixed(item.currentStock == item.currentStock.toInt() ? 0 : 1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                    Text(
                      _formatUnitShort(item.item.unit),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black.withValues(alpha: 0.3),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatUnit(String unit) {
    switch (unit.toUpperCase()) {
      case 'GRAMOS':
        return 'Gramos';
      case 'KILOGRAMOS':
        return 'Kilogramos';
      case 'MILILITROS':
        return 'Mililitros';
      case 'LITROS':
        return 'Litros';
      case 'UNIDADES':
        return 'Unidades';
      default:
        return unit;
    }
  }

  String _formatUnitShort(String unit) {
    switch (unit.toUpperCase()) {
      case 'GRAMOS':
        return 'g';
      case 'KILOGRAMOS':
        return 'kg';
      case 'MILILITROS':
        return 'ml';
      case 'LITROS':
        return 'L';
      case 'UNIDADES':
        return 'uds';
      default:
        return unit.toLowerCase();
    }
  }

  Widget _buildErrorState(ItemListProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: const Color(0xFF8B7355).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar insumos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.loadItems,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B7355),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: const Color(0xFF8B7355).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin insumos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay insumos registrados.\nAgrega tu primer insumo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B7355).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onAddItem,
        backgroundColor: const Color(0xFF8B7355),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Insumo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}