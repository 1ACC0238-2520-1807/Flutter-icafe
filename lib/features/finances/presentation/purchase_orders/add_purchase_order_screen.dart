import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/secure_storage.dart';
import '../../../contacts/domain/entities/proveedor.dart';
import '../../../inventory/data/models/inventory_models.dart';
import '../../data/repositories/purchase_orders_repository.dart';

class AddPurchaseOrderScreen extends StatefulWidget {
  final int branchId;
  final int portfolioId;
  final VoidCallback onOrderAdded;

  const AddPurchaseOrderScreen({
    super.key,
    required this.branchId,
    required this.portfolioId,
    required this.onOrderAdded,
  });

  @override
  State<AddPurchaseOrderScreen> createState() => _AddPurchaseOrderScreenState();
}

class _AddPurchaseOrderScreenState extends State<AddPurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _notesController = TextEditingController();
  final PurchaseOrdersRepository _repository = PurchaseOrdersRepository();
  
  List<Proveedor> _proveedores = [];
  List<SupplyItemResource> _supplyItems = [];
  Proveedor? _selectedProveedor;
  SupplyItemResource? _selectedSupplyItem;
  DateTime _purchaseDate = DateTime.now();
  DateTime? _expirationDate;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final token = await SecureStorage.readToken();
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Cargar proveedores
      final proveedoresResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/${widget.portfolioId}/providers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Cargar supply items
      final supplyItemsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/supply-items/${widget.branchId}/branch'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (proveedoresResponse.statusCode == 200) {
        final data = jsonDecode(proveedoresResponse.body) as List;
        _proveedores = data.map((json) => Proveedor.fromJson(json)).toList();
      }

      if (supplyItemsResponse.statusCode == 200) {
        final data = jsonDecode(supplyItemsResponse.body) as List;
        _supplyItems = data.map((json) => SupplyItemResource.fromJson(json)).toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    return quantity * unitPrice;
  }

  Future<void> _selectDate(bool isExpirationDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpirationDate ? (_expirationDate ?? DateTime.now().add(const Duration(days: 30))) : _purchaseDate,
      firstDate: isExpirationDate ? DateTime.now() : DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B7355),
              onPrimary: Colors.white,
              onSurface: Color(0xFF6F4E37),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isExpirationDate) {
          _expirationDate = picked;
        } else {
          _purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _savePurchaseOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProveedor == null || _selectedSupplyItem == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final orderData = {
        'branchId': widget.branchId,
        'providerId': int.tryParse(_selectedProveedor!.id) ?? 0,
        'supplyItemId': _selectedSupplyItem!.id,
        'unitPrice': double.tryParse(_unitPriceController.text) ?? 0,
        'quantity': double.tryParse(_quantityController.text) ?? 0,
        'totalAmount': _totalAmount,
        'purchaseDate': _purchaseDate.toIso8601String().split('T')[0],
        'expirationDate': _expirationDate?.toIso8601String().split('T')[0],
        'status': 'PENDING',
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      };

      await _repository.createPurchaseOrder(orderData);

      if (!mounted) return;
      
      widget.onOrderAdded();
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
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
                  // Dropdown Proveedor
                  const Text(
                    'Proveedor *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                    child: DropdownButtonFormField<Proveedor>(
                      initialValue: _selectedProveedor,
                      decoration: InputDecoration(
                        hintText: 'Seleccionar Proveedor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _proveedores.map((proveedor) {
                        return DropdownMenuItem(
                          value: proveedor,
                          child: Text(
                            proveedor.nombre,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedProveedor = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un proveedor';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Insumo
                  const Text(
                    'Insumo *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                    child: DropdownButtonFormField<SupplyItemResource>(
                      initialValue: _selectedSupplyItem,
                      decoration: InputDecoration(
                        hintText: 'Seleccionar Insumo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _supplyItems.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            '${item.name} (${item.unit})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplyItem = value;
                          if (value != null) {
                            _unitPriceController.text = value.unitPrice.toStringAsFixed(2);
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un insumo';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cantidad y Precio en fila
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cantidad *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F4E37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
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
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Inválido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Precio Unitario *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F4E37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _unitPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                prefixText: 'S/. ',
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
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Inválido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fechas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha de Compra *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F4E37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(_purchaseDate),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6F4E37),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Color(0xFF8B7355),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vencimiento',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F4E37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _expirationDate != null 
                                          ? _formatDate(_expirationDate!) 
                                          : 'Opcional',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _expirationDate != null 
                                            ? const Color(0xFF6F4E37)
                                            : Colors.grey,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Color(0xFF8B7355),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

                  // Total
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
                    child: Row(
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
                          'S/. ${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Registrar Compra
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePurchaseOrder,
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
                            'Registrar Compra',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
  }
}
