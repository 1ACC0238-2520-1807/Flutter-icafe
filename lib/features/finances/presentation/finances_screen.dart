import 'package:flutter/material.dart';
import 'sales/sales_screen.dart';
import 'sales/add_sale_screen.dart';
import 'sales/sale_detail_screen.dart';
import 'purchase_orders/purchase_orders_screen.dart';
import 'purchase_orders/add_purchase_order_screen.dart';
import 'purchase_orders/purchase_order_detail_screen.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../domain/entities/sale.dart';
import '../domain/entities/purchase_order.dart';
import '../../auth/data/secure_storage.dart';

enum _FinancesViewState { lista, ventas, compras, agregarVenta, detalleVenta, agregarCompra, detalleCompra }

class FinancesScreen extends StatefulWidget {
  final int branchId;
  final VoidCallback? onBack;
  
  const FinancesScreen({
    super.key, 
    required this.branchId,
    this.onBack,
  });

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  _FinancesViewState _currentView = _FinancesViewState.lista;
  Sale? _selectedSale;
  PurchaseOrder? _selectedPurchaseOrder;
  int? _portfolioId;

  @override
  void initState() {
    super.initState();
    _loadPortfolioId();
  }

  Future<void> _loadPortfolioId() async {
    final id = await SecureStorage.readUserId();
    if (mounted && id != null) {
      setState(() => _portfolioId = id);
    }
  }

  void _handleAddSale() {
    setState(() {
      _currentView = _FinancesViewState.agregarVenta;
    });
  }

  void _handleAddPurchaseOrder() {
    setState(() {
      _currentView = _FinancesViewState.agregarCompra;
    });
  }

  void _onSaleAdded() {
    setState(() {
      _currentView = _FinancesViewState.ventas;
    });
  }

  void _onPurchaseOrderAdded() {
    setState(() {
      _currentView = _FinancesViewState.compras;
    });
  }

  void _onSaleSelected(Sale sale) {
    setState(() {
      _selectedSale = sale;
      _currentView = _FinancesViewState.detalleVenta;
    });
  }

  void _onPurchaseOrderSelected(PurchaseOrder order) {
    setState(() {
      _selectedPurchaseOrder = order;
      _currentView = _FinancesViewState.detalleCompra;
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
      body: _buildView(),
      floatingActionButton: (_currentView == _FinancesViewState.ventas || _currentView == _FinancesViewState.compras)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton(
                onPressed: _currentView == _FinancesViewState.ventas 
                    ? _handleAddSale 
                    : _handleAddPurchaseOrder,
                backgroundColor: const Color(0xFF8B7355),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case _FinancesViewState.lista:
        return 'Finanzas';
      case _FinancesViewState.ventas:
        return 'Administrar Ventas';
      case _FinancesViewState.compras:
        return 'Administrar Compras';
      case _FinancesViewState.agregarVenta:
        return 'Nueva Venta';
      case _FinancesViewState.detalleVenta:
        return 'Detalle de Venta';
      case _FinancesViewState.agregarCompra:
        return 'Nueva Compra';
      case _FinancesViewState.detalleCompra:
        return 'Detalle de Compra';
    }
  }

  void _handleBack() {
    if (_currentView == _FinancesViewState.agregarVenta || 
        _currentView == _FinancesViewState.detalleVenta) {
      setState(() {
        _currentView = _FinancesViewState.ventas;
        _selectedSale = null;
      });
    } else if (_currentView == _FinancesViewState.agregarCompra ||
               _currentView == _FinancesViewState.detalleCompra) {
      setState(() {
        _currentView = _FinancesViewState.compras;
        _selectedPurchaseOrder = null;
      });
    } else if (_currentView != _FinancesViewState.lista) {
      setState(() {
        _currentView = _FinancesViewState.lista;
      });
    } else {
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildView() {
    switch (_currentView) {
      case _FinancesViewState.lista:
        return _buildListaView();
      case _FinancesViewState.ventas:
        return SalesScreen(
          branchId: widget.branchId,
          onBack: null,
          onSaleSelected: _onSaleSelected,
        );
      case _FinancesViewState.compras:
        return PurchaseOrdersScreen(
          branchId: widget.branchId,
          onBack: null,
          onOrderSelected: _onPurchaseOrderSelected,
        );
      case _FinancesViewState.agregarVenta:
        return AddSaleScreen(
          branchId: widget.branchId,
          onSaleAdded: _onSaleAdded,
        );
      case _FinancesViewState.detalleVenta:
        return SaleDetailScreen(sale: _selectedSale!);
      case _FinancesViewState.agregarCompra:
        return AddPurchaseOrderScreen(
          branchId: widget.branchId,
          portfolioId: _portfolioId ?? 0,
          onOrderAdded: _onPurchaseOrderAdded,
        );
      case _FinancesViewState.detalleCompra:
        return PurchaseOrderDetailScreen(order: _selectedPurchaseOrder!);
    }
  }

  Widget _buildListaView() {
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
                  'Gestión Financiera',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Administra tus ventas y compras',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8B7355).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Botón Administrar Ventas
          _buildFinancesButton(
            context,
            icon: Icons.sell,
            title: 'Administrar Ventas',
            description: 'Gestiona tus ventas y transacciones',
            backgroundColor: oliveGreen,
            onPressed: () {
              setState(() {
                _currentView = _FinancesViewState.ventas;
              });
            },
          ),
          const SizedBox(height: 20),
          // Botón Administrar Compras
          _buildFinancesButton(
            context,
            icon: Icons.shopping_cart,
            title: 'Administrar Compras',
            description: 'Gestiona tus pedidos y compras',
            backgroundColor: darkBrown,
            onPressed: () {
              setState(() {
                _currentView = _FinancesViewState.compras;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancesButton(
    BuildContext context, {
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
