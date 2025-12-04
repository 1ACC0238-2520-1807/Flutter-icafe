import 'package:flutter/material.dart';
import '../../domain/entities/purchase_order.dart';

class PurchaseOrderDetailScreen extends StatelessWidget {
  final PurchaseOrder order;

  const PurchaseOrderDetailScreen({
    super.key,
    required this.order,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'CONFIRMED':
        return const Color(0xFF3B82F6);
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'CONFIRMED':
        return 'Confirmada';
      case 'COMPLETED':
        return 'Completada';
      case 'CANCELLED':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalle de Compra',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Orden #${order.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Información del Proveedor Card
          _buildInfoCard(
            title: 'Proveedor',
            icon: Icons.business,
            children: [
              _buildInfoRow('Nombre', order.providerName ?? 'Sin asignar'),
              if (order.providerRuc != null && order.providerRuc!.isNotEmpty)
                _buildInfoRow('RUC', order.providerRuc!),
              if (order.providerEmail != null && order.providerEmail!.isNotEmpty)
                _buildInfoRow('Email', order.providerEmail!),
              if (order.providerPhone != null && order.providerPhone!.isNotEmpty)
                _buildInfoRow('Teléfono', order.providerPhone!),
            ],
          ),
          const SizedBox(height: 16),

          // Información del Pedido Card
          _buildInfoCard(
            title: 'Información del Pedido',
            icon: Icons.shopping_cart_outlined,
            children: [
              _buildInfoRow('Sucursal ID', order.branchId.toString()),
              _buildInfoRow('Fecha de Compra', _formatDate(order.purchaseDate)),
              if (order.expirationDate != null)
                _buildInfoRow('Vencimiento', _formatDate(order.expirationDate!)),
              if (order.notes != null && order.notes!.isNotEmpty)
                _buildInfoRow('Notas', order.notes!),
            ],
          ),
          const SizedBox(height: 16),

          // Detalle del Insumo Card
          _buildInfoCard(
            title: 'Detalle del Insumo',
            icon: Icons.inventory_2_outlined,
            children: [
              _buildProductDetail(),
            ],
          ),
          const SizedBox(height: 16),

          // Resumen de Pago Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B7355),
                  Color(0xFF6F4E37),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6F4E37).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio Unitario',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'S/. ${order.unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      order.quantity.toStringAsFixed(order.quantity == order.quantity.toInt() ? 0 : 2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'S/. ${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF8B7355),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F4E37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6F4E37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Color(0xFF8B7355),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.supplyItemId != null 
                      ? 'Insumo #${order.supplyItemId}'
                      : 'Insumo no especificado',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.quantity.toStringAsFixed(order.quantity == order.quantity.toInt() ? 0 : 2)} unidades × S/. ${order.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'S/. ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
