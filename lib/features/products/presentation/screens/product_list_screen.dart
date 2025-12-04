import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_providers.dart';
import '../../data/network/product_service.dart';
import '../../data/models/product_models.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

/// Widget que provee el Provider y se usa desde InventoryScreen
class ProductListContent extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final void Function(int productId)? onProductSelected;
  final VoidCallback? onAddProduct;

  const ProductListContent({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    this.onProductSelected,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductListProvider(
        Provider.of<ProductService>(context, listen: false),
        selectedSedeId,
      ),
      child: _ProductListBody(
        portfolioId: portfolioId,
        selectedSedeId: selectedSedeId,
        onProductSelected: onProductSelected,
        onAddProduct: onAddProduct,
      ),
    );
  }
}

/// Contenido principal de la lista de productos (sin Scaffold)
class _ProductListBody extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final void Function(int productId)? onProductSelected;
  final VoidCallback? onAddProduct;

  const _ProductListBody({
    required this.portfolioId,
    required this.selectedSedeId,
    this.onProductSelected,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductListProvider>(context);

    return Stack(
      children: [
        _buildContent(context, provider),
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildFloatingButton(context, provider),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProductListProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8B7355),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(provider);
    }

    if (provider.products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => provider.loadProducts(),
      color: const Color(0xFF8B7355),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: provider.products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(context, provider.products[index], provider);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductResource product, ProductListProvider provider) {
    final isActive = product.status == ProductStatus.ACTIVE;
    final statusColor = isActive 
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
            if (onProductSelected != null) {
              onProductSelected!(product.id);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                    portfolioId: portfolioId,
                    selectedSedeId: selectedSedeId,
                    productId: product.id,
                  ),
                ),
              ).then((_) => provider.loadProducts());
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
                    Icons.local_cafe,
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
                        product.name,
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
                          // Badge de estado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? 'Activo' : 'Archivado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Ingredientes
                          Text(
                            '${product.ingredients.length} ingredientes',
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
                // Precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${product.costPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    Text(
                      '+${product.profitMargin.toStringAsFixed(0)}%',
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

  Widget _buildErrorState(ProductListProvider provider) {
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
              'Error al cargar productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.loadProducts,
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
              Icons.local_cafe_outlined,
              size: 80,
              color: const Color(0xFF8B7355).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin productos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay productos registrados.\nAgrega tu primer producto.',
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

  Widget _buildFloatingButton(BuildContext context, ProductListProvider provider) {
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
        onPressed: () {
          if (onAddProduct != null) {
            onAddProduct!();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditProductScreen(
                  portfolioId: portfolioId,
                  selectedSedeId: selectedSedeId,
                ),
              ),
            ).then((_) => provider.loadProducts());
          }
        },
        backgroundColor: const Color(0xFF8B7355),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Producto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Pantalla completa con Scaffold (para uso independiente con Navigator.push)
class ProductListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const ProductListScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductListProvider(
        Provider.of<ProductService>(context, listen: false),
        selectedSedeId,
      ),
      child: const _ProductListContentWithScaffold(),
    );
  }
}

class _ProductListContentWithScaffold extends StatelessWidget {
  const _ProductListContentWithScaffold();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductListProvider>(context);
    const themeColor = Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text("Productos"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditProductScreen(
                portfolioId: "1",
                selectedSedeId: provider.selectedSedeId,
              ),
            ),
          ).then((_) => provider.loadProducts());
        },
      ),
      body: Builder(builder: (context) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: themeColor),
          );
        }
        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }
        if (provider.products.isEmpty) {
          return const Center(child: Text("No hay productos registrados."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.products.length,
          itemBuilder: (ctx, index) {
            final product = provider.products[index];
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "S/ ${product.costPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        portfolioId: "1",
                        selectedSedeId: provider.selectedSedeId,
                        productId: product.id,
                      ),
                    ),
                  ).then((_) => provider.loadProducts());
                },
              ),
            );
          },
        );
      }),
    );
  }
}