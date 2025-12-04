import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/supply_item_detail_provider.dart';
import '../../data/network/inventory_service.dart';
import '../../../contacts/data/network/contacts_service.dart';

/// Widget de contenido para mostrar detalles del insumo (sin Scaffold propio)
/// Se usa dentro de InventoryScreen para mantener el bottom nav bar
class SupplyItemDetailContent extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int supplyItemId;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const SupplyItemDetailContent({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    required this.supplyItemId,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplyItemDetailProvider(
        inventoryService: Provider.of<InventoryService>(context, listen: false),
        contactsService: Provider.of<ContactsService>(context, listen: false),
        portfolioId: portfolioId,
        supplyItemId: supplyItemId,
      ),
      child: _SupplyItemDetailBody(
        onEdit: onEdit,
        onDeleted: onDeleted,
      ),
    );
  }
}

class _SupplyItemDetailBody extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const _SupplyItemDetailBody({
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupplyItemDetailProvider>(context);
    final item = provider.supplyItem;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B7355)),
      );
    }

    if (item == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: const Color(0xFF8B7355).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el insumo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Error desconocido',
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B7355),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: const Color(0xFF8B7355),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información principal
            _buildItemHeader(provider, item),
            
            // Información de stock y precio
            _buildStockPriceSection(provider, item),
            
            // Información del proveedor
            _buildProviderSection(provider),
            
            // Fechas
            _buildDatesSection(item),
            
            // Acciones
            _buildActionsSection(context, provider, item),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(SupplyItemDetailProvider provider, dynamic item) {
    final stockColor = item.stock > 0 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);
    final isLowStock = item.stock < 100;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono grande
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Color(0xFF8B7355),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Badge de unidad
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B7355).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.formatUnit(item.unit),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge de stock bajo si aplica
                    if (isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Stock bajo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Stock grande
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.stock.toStringAsFixed(
                    item.stock == item.stock.toInt() ? 0 : 1),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: stockColor,
                ),
              ),
              Text(
                provider.formatUnitShort(item.unit),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockPriceSection(SupplyItemDetailProvider provider, dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.payments_outlined,
              label: 'Precio Unitario',
              value: 'S/ ${item.unitPrice.toStringAsFixed(2)}',
              color: const Color(0xFF8B7355),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Valor en Stock',
              value: 'S/ ${(item.unitPrice * item.stock).toStringAsFixed(2)}',
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(SupplyItemDetailProvider provider) {
    final providerInfo = provider.provider;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business,
                color: Color(0xFF6F4E37),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Proveedor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F4E37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerInfo?.nameCompany ?? 'Proveedor desconocido',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    if (providerInfo?.ruc != null && providerInfo!.ruc.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'RUC: ${providerInfo.ruc}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (providerInfo != null && (providerInfo.email.isNotEmpty || providerInfo.phoneNumber.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  if (providerInfo.phoneNumber.isNotEmpty) ...[
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      providerInfo.phoneNumber,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                  if (providerInfo.phoneNumber.isNotEmpty && providerInfo.email.isNotEmpty)
                    const SizedBox(width: 16),
                  if (providerInfo.email.isNotEmpty) ...[
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        providerInfo.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatesSection(dynamic item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF6F4E37),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Fechas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F4E37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Fecha de Compra',
                  date: item.buyDate,
                  color: const Color(0xFF8B7355),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateItem(
                  icon: Icons.event_busy_outlined,
                  label: 'Fecha de Vencimiento',
                  date: item.expiredDate,
                  color: _getExpiryColor(item.expiredDate),
                  isExpiry: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getExpiryColor(String? expiredDate) {
    if (expiredDate == null) return Colors.grey;
    
    try {
      final expiry = DateTime.parse(expiredDate);
      final now = DateTime.now();
      final daysUntilExpiry = expiry.difference(now).inDays;
      
      if (daysUntilExpiry < 0) {
        return const Color(0xFFEF4444); // Expirado
      } else if (daysUntilExpiry <= 30) {
        return Colors.orange; // Próximo a vencer
      } else {
        return const Color(0xFF10B981); // OK
      }
    } catch (_) {
      return Colors.grey;
    }
  }

  Widget _buildDateItem({
    required IconData icon,
    required String label,
    required String? date,
    required Color color,
    bool isExpiry = false,
  }) {
    String formattedDate = 'Sin fecha';
    String? statusText;
    
    if (date != null && date.isNotEmpty) {
      try {
        final parsed = DateTime.parse(date);
        formattedDate = DateFormat('dd/MM/yyyy').format(parsed);
        
        if (isExpiry) {
          final now = DateTime.now();
          final daysUntilExpiry = parsed.difference(now).inDays;
          
          if (daysUntilExpiry < 0) {
            statusText = 'Vencido hace ${-daysUntilExpiry} días';
          } else if (daysUntilExpiry == 0) {
            statusText = 'Vence hoy';
          } else if (daysUntilExpiry <= 30) {
            statusText = 'Vence en $daysUntilExpiry días';
          }
        }
      } catch (_) {
        formattedDate = date;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: date != null ? color : Colors.grey,
            ),
          ),
          if (statusText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    SupplyItemDetailProvider provider,
    dynamic item,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6F4E37),
            ),
          ),
          const SizedBox(height: 12),
          // Editar
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Editar Insumo',
            color: const Color(0xFF8B7355),
            onTap: onEdit,
          ),
          const SizedBox(height: 10),
          // Eliminar
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Eliminar Insumo',
            color: const Color(0xFFEF4444),
            outlined: true,
            isLoading: provider.isDeleting,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text('Confirmar eliminación'),
                    ],
                  ),
                  content: Text(
                    '¿Estás seguro de eliminar "${item.name}"?\n\nEsta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Color(0xFF8B7355)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await provider.deleteSupplyItem();
                if (success) {
                  onDeleted();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
    bool isLoading = false,
  }) {
    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
