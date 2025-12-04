import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/products_repository.dart';
import '../../data/repositories/sales_repository.dart';

class AddSaleScreen extends StatefulWidget {
  final int branchId;
  final VoidCallback onSaleAdded;

  const AddSaleScreen({
    super.key,
    required this.branchId,
    required this.onSaleAdded,
  });

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _notesController = TextEditingController();
  final ProductsRepository _productsRepository = ProductsRepository();
  final SalesRepository _salesRepository = SalesRepository();
  
  List<Product> _allProducts = [];
  List<Product> _availableProducts = [];
  final List<SaleItemData> _items = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productsRepository.getProducts();
      setState(() {
        _allProducts = products.where((p) => p.branchId == widget.branchId).toList();
        _availableProducts = List.from(_allProducts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  void _addProduct() {
    if (_availableProducts.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ProductSelectionDialog(
        products: _availableProducts,
        onProductSelected: (product, quantity) {
          setState(() {
            final subtotal = product.salePrice * quantity;
            _items.add(SaleItemData(
              product: product,
              quantity: quantity,
              unitPrice: product.salePrice,
              subtotal: subtotal,
            ));
            _availableProducts.removeWhere((p) => p.id == product.id);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      final removedItem = _items[index];
      _items.removeAt(index);
      _availableProducts.add(removedItem.product);
      _availableProducts.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final saleData = {
        'customerId': int.tryParse(_customerIdController.text),
        'branchId': widget.branchId,
        'items': _items.map((item) => {
          'productId': item.product.id,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'subtotal': item.subtotal,
        }).toList(),
        'totalAmount': _totalAmount,
        'status': 'PENDING',
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      };

      await _salesRepository.createSale(saleData);

      if (!mounted) return;
      
      widget.onSaleAdded();
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFF5E6D3);

    return Scaffold(
      backgroundColor: lightPeach,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B7355),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ID Cliente
                    const Text(
                      'ID Cliente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ingrese ID del cliente',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El ID del cliente es requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Notas
                    const Text(
                      'Notas (opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Añadir notas adicionales',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Productos
                    const Text(
                      'Productos:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista de productos
                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No hay productos añadidos.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildProductItem(item, index);
                        },
                      ),
                    const SizedBox(height: 16),

                    // Botón Añadir Producto
                    ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Añadir Producto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B7355),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                        Text(
                          'S/. ${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botón Registrar Venta
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F4E37),
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Registrar Venta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductItem(SaleItemData item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${item.quantity} x S/. ${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subtotal: S/. ${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class SaleItemData {
  final Product product;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemData({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
}

class _ProductSelectionDialog extends StatefulWidget {
  final List<Product> products;
  final Function(Product, int) onProductSelected;

  const _ProductSelectionDialog({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Seleccionar Producto',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6F4E37),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown de productos
            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              decoration: InputDecoration(
                labelText: 'Producto',
                filled: true,
                fillColor: const Color(0xFFF5E6D3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: widget.products.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(
                    '${product.name} - S/. ${product.salePrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedProduct = value);
              },
            ),
            const SizedBox(height: 16),

            // Campo de cantidad
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                filled: true,
                fillColor: const Color(0xFFF5E6D3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedProduct == null) {
              return;
            }

            final quantity = int.tryParse(_quantityController.text);
            if (quantity == null || quantity <= 0) {
              return;
            }

            widget.onProductSelected(_selectedProduct!, quantity);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B7355),
          ),
          child: const Text(
            'Añadir',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
