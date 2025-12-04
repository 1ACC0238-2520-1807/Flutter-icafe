import 'package:flutter/material.dart';
import 'screens/item_list_screen.dart';
import 'screens/add_edit_supply_item_content.dart';
import 'screens/supply_item_detail_content.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../products/presentation/screens/product_list_screen.dart';
import '../../products/presentation/screens/product_detail_content.dart';
import '../../products/presentation/screens/add_edit_product_content.dart';

enum _InventoryViewState { 
  menu, 
  insumos, 
  insumoDetalle,
  insumoNuevo,
  insumoEditar,
  productos,
  productoDetalle,
  productoEditar,
  productoNuevo,
}

class InventoryScreen extends StatefulWidget {
  final String portfolioId;
  final String selectedSedeId;
  final VoidCallback? onBack;

  const InventoryScreen({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    this.onBack,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  _InventoryViewState _currentView = _InventoryViewState.menu;
  int? _selectedProductId;
  int? _selectedSupplyItemId;

  String _getAppBarTitle() {
    switch (_currentView) {
      case _InventoryViewState.menu:
        return 'Inventario';
      case _InventoryViewState.insumos:
        return 'Administrar Insumos';
      case _InventoryViewState.insumoDetalle:
        return 'Detalle del Insumo';
      case _InventoryViewState.insumoNuevo:
        return 'Nuevo Insumo';
      case _InventoryViewState.insumoEditar:
        return 'Editar Insumo';
      case _InventoryViewState.productos:
        return 'Administrar Productos';
      case _InventoryViewState.productoDetalle:
        return 'Detalle del Producto';
      case _InventoryViewState.productoEditar:
        return 'Editar Producto';
      case _InventoryViewState.productoNuevo:
        return 'Nuevo Producto';
    }
  }

  void _handleBack() {
    switch (_currentView) {
      case _InventoryViewState.menu:
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.pop(context);
        }
        break;
      case _InventoryViewState.insumos:
      case _InventoryViewState.productos:
        setState(() {
          _currentView = _InventoryViewState.menu;
        });
        break;
      case _InventoryViewState.insumoNuevo:
        setState(() {
          _currentView = _InventoryViewState.insumos;
          _selectedSupplyItemId = null;
        });
        break;
      case _InventoryViewState.insumoDetalle:
        setState(() {
          _currentView = _InventoryViewState.insumos;
          _selectedSupplyItemId = null;
        });
        break;
      case _InventoryViewState.insumoEditar:
        if (_selectedSupplyItemId != null) {
          setState(() {
            _currentView = _InventoryViewState.insumoDetalle;
          });
        } else {
          setState(() {
            _currentView = _InventoryViewState.insumos;
          });
        }
        break;
      case _InventoryViewState.productoDetalle:
        setState(() {
          _currentView = _InventoryViewState.productos;
          _selectedProductId = null;
        });
        break;
      case _InventoryViewState.productoEditar:
      case _InventoryViewState.productoNuevo:
        if (_selectedProductId != null) {
          setState(() {
            _currentView = _InventoryViewState.productoDetalle;
          });
        } else {
          setState(() {
            _currentView = _InventoryViewState.productos;
          });
        }
        break;
    }
  }

  void _onProductSelected(int productId) {
    setState(() {
      _selectedProductId = productId;
      _currentView = _InventoryViewState.productoDetalle;
    });
  }

  void _onEditProduct(int productId) {
    setState(() {
      _selectedProductId = productId;
      _currentView = _InventoryViewState.productoEditar;
    });
  }

  void _onAddProduct() {
    setState(() {
      _selectedProductId = null;
      _currentView = _InventoryViewState.productoNuevo;
    });
  }

  void _onProductSaved() {
    if (_selectedProductId != null) {
      setState(() {
        _currentView = _InventoryViewState.productoDetalle;
      });
    } else {
      setState(() {
        _currentView = _InventoryViewState.productos;
      });
    }
  }

  void _onProductDeleted() {
    setState(() {
      _selectedProductId = null;
      _currentView = _InventoryViewState.productos;
    });
  }

  // Métodos para insumos
  void _onSupplyItemSelected(int supplyItemId) {
    setState(() {
      _selectedSupplyItemId = supplyItemId;
      _currentView = _InventoryViewState.insumoDetalle;
    });
  }

  void _onEditSupplyItem(int supplyItemId) {
    setState(() {
      _selectedSupplyItemId = supplyItemId;
      _currentView = _InventoryViewState.insumoEditar;
    });
  }

  void _onAddSupplyItem() {
    setState(() {
      _selectedSupplyItemId = null;
      _currentView = _InventoryViewState.insumoNuevo;
    });
  }

  void _onSupplyItemSaved() {
    if (_selectedSupplyItemId != null) {
      setState(() {
        _currentView = _InventoryViewState.insumoDetalle;
      });
    } else {
      setState(() {
        _currentView = _InventoryViewState.insumos;
      });
    }
  }

  void _onSupplyItemDeleted() {
    setState(() {
      _selectedSupplyItemId = null;
      _currentView = _InventoryViewState.insumos;
    });
  }

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFF5E6D3);

    return Scaffold(
      backgroundColor: lightPeach,
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        onBackPressed: _handleBack,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentView) {
      case _InventoryViewState.menu:
        return _buildMenuContent();
      case _InventoryViewState.insumos:
        return ItemListScreen(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          onItemSelected: _onSupplyItemSelected,
          onAddItem: _onAddSupplyItem,
        );
      case _InventoryViewState.insumoDetalle:
        return SupplyItemDetailContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          supplyItemId: _selectedSupplyItemId!,
          onEdit: () => _onEditSupplyItem(_selectedSupplyItemId!),
          onDeleted: _onSupplyItemDeleted,
        );
      case _InventoryViewState.insumoNuevo:
        return AddEditSupplyItemContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          supplyItemId: null,
          onSaved: _onSupplyItemSaved,
        );
      case _InventoryViewState.insumoEditar:
        return AddEditSupplyItemContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          supplyItemId: _selectedSupplyItemId,
          onSaved: _onSupplyItemSaved,
        );
      case _InventoryViewState.productos:
        return ProductListContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          onProductSelected: _onProductSelected,
          onAddProduct: _onAddProduct,
        );
      case _InventoryViewState.productoDetalle:
        return ProductDetailContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          productId: _selectedProductId!,
          onEdit: () => _onEditProduct(_selectedProductId!),
          onDeleted: _onProductDeleted,
        );
      case _InventoryViewState.productoEditar:
        return AddEditProductContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          productId: _selectedProductId,
          onSaved: _onProductSaved,
        );
      case _InventoryViewState.productoNuevo:
        return AddEditProductContent(
          portfolioId: widget.portfolioId,
          selectedSedeId: widget.selectedSedeId,
          productId: null,
          onSaved: _onProductSaved,
        );
    }
  }

  Widget _buildMenuContent() {
    const oliveGreen = Color(0xFF8B7355);
    const darkBrown = Color(0xFF9E8B7E);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con descripción
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Inventario',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administra tus insumos y productos',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8B7355).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Botón Administrar Insumos
            _buildInventoryButton(
              icon: Icons.inventory_2,
              title: 'Administrar Insumos',
              description: 'Gestiona tus insumos y materias primas',
              backgroundColor: oliveGreen,
              onPressed: () => setState(() => _currentView = _InventoryViewState.insumos),
            ),
            const SizedBox(height: 20),
            // Botón Administrar Productos
            _buildInventoryButton(
              icon: Icons.local_cafe,
              title: 'Administrar Productos',
              description: 'Gestiona los productos de tu cafetería',
              backgroundColor: darkBrown,
              onPressed: () => setState(() => _currentView = _InventoryViewState.productos),
            ),
          ],
        ),
    );
  }

  Widget _buildInventoryButton({
    required IconData icon,
    required String title,
    required String description,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.black.withValues(alpha: 0.1),
        highlightColor: Colors.black.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Icono
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Flecha
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}