import 'package:flutter/material.dart';
import '../../data/repositories/sales_repository.dart';
import '../../domain/entities/sale.dart';

class SalesScreen extends StatefulWidget {
  final int branchId;
  final VoidCallback? onBack;
  final Function(Sale)? onSaleSelected;
  
  const SalesScreen({
    super.key, 
    required this.branchId,
    this.onBack,
    this.onSaleSelected,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SalesRepository _repository = SalesRepository();
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _repository.getSalesByBranch(widget.branchId);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFD97706); // Naranja
      case 'COMPLETED':
        return const Color(0xFF10B981); // Verde
      case 'CANCELLED':
        return const Color(0xFFEF4444); // Rojo
      default:
        return const Color(0xFF6B7280); // Gris
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          FutureBuilder<List<Sale>>(
            future: _salesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFF8B7355),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar ventas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _salesFuture = _repository.getSalesByBranch(widget.branchId);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B7355),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black.withValues(alpha: 0.3),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ventas registradas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final sales = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return _buildSaleCard(sale);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onSaleSelected != null) {
              widget.onSaleSelected!(sale);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con ID, Cliente y Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Venta #${sale.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F4E37),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sale.customerId != null 
                                ? 'Cliente ID: ${sale.customerId}' 
                                : 'Sin cliente asignado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(sale.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(sale.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(sale.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                // Fecha y cantidad de items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(sale.saleDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sale.items.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    Text(
                      '\S/.${sale.totalAmount.toStringAsFixed(2)}',
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
          ),
        ),
      ),
    );
  }
}

