import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_models.dart';
import '../../providers/product_providers.dart';
import '../../data/network/product_service.dart';
import '../../../inventory/data/network/inventory_service.dart';

/// Widget de contenido para mostrar detalles del producto (sin Scaffold propio)
/// Se usa dentro de InventoryScreen para mantener el bottom nav bar
class ProductDetailContent extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int productId;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const ProductDetailContent({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    required this.productId,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailProvider(
        Provider.of<ProductService>(context, listen: false),
        productId,
        Provider.of<InventoryService>(context, listen: false),
      ),
      child: _ProductDetailBody(
        portfolioId: portfolioId,
        selectedSedeId: selectedSedeId,
        onEdit: onEdit,
        onDeleted: onDeleted,
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const _ProductDetailBody({
    required this.portfolioId,
    required this.selectedSedeId,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductDetailProvider>(context);
    final product = provider.product;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B7355)),
      );
    }

    if (product == null) {
      return Center(
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
              'Error al cargar el producto',
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
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final isActive = product.status == ProductStatus.ACTIVE;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información principal
          _buildProductHeader(product, isActive),
          
          // Información de precios
          _buildPriceSection(product),
          
          // Sección de ingredientes
          _buildIngredientsSection(provider, product),
          
          // Acciones
          _buildActionsSection(context, provider, product, isActive),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProductHeader(ProductResource product, bool isActive) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              color: const Color(0xFF8B7355).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_cafe,
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
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 8),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.check_circle : Icons.archive,
                        size: 16,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? 'Activo' : 'Archivado',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(ProductResource product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceCard(
              icon: Icons.payments_outlined,
              label: 'Costo',
              value: 'S/ ${product.costPrice.toStringAsFixed(2)}',
              color: const Color(0xFF8B7355),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPriceCard(
              icon: Icons.sell_outlined,
              label: 'Venta',
              value: 'S/ ${product.salePrice.toStringAsFixed(2)}',
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPriceCard(
              icon: Icons.trending_up,
              label: 'Margen',
              value: '${product.profitMargin.toStringAsFixed(0)}%',
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(ProductDetailProvider provider, ProductResource product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF6F4E37),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ingredientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F4E37),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${product.ingredients.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (product.ingredients.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sin ingredientes',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: product.ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  final isLast = index == product.ingredients.length - 1;
                  
                  return _buildIngredientItem(
                    provider: provider,
                    ingredient: ingredient,
                    showDivider: !isLast,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem({
    required ProductDetailProvider provider,
    required ProductIngredientResource ingredient,
    required bool showDivider,
  }) {
    final name = provider.getIngredientName(ingredient.ingredientId);
    final unit = provider.getIngredientUnit(ingredient.ingredientId);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF8B7355),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${ingredient.ingredientId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${ingredient.quantity.toStringAsFixed(ingredient.quantity == ingredient.quantity.toInt() ? 0 : 1)} $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E37),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
      ],
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    ProductDetailProvider provider,
    ProductResource product,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            label: 'Editar Producto',
            color: const Color(0xFF8B7355),
            onTap: onEdit,
          ),
          const SizedBox(height: 10),
          // Archivar/Activar
          _buildActionButton(
            icon: isActive ? Icons.archive_outlined : Icons.unarchive_outlined,
            label: isActive ? 'Archivar Producto' : 'Activar Producto',
            color: isActive ? Colors.orange : const Color(0xFF10B981),
            onTap: () async {
              await provider.toggleArchiveStatus();
            },
          ),
          const SizedBox(height: 10),
          // Eliminar
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Eliminar Producto',
            color: const Color(0xFFEF4444),
            outlined: true,
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
                    '¿Estás seguro de eliminar "${product.name}"?\n\nEsta acción no se puede deshacer.',
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
                final success = await provider.deleteProduct();
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
  }) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
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
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
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
