import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../inventory/data/models/inventory_models.dart';
import '../../providers/product_providers.dart';
import '../../data/network/product_service.dart';

/// Widget de contenido para agregar/editar producto (sin Scaffold propio)
/// Se usa dentro de InventoryScreen para mantener el bottom nav bar
class AddEditProductContent extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int? productId;
  final VoidCallback onSaved;

  const AddEditProductContent({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    this.productId,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(
        Provider.of<ProductService>(context, listen: false),
        selectedSedeId,
        productId,
      ),
      child: _AddEditProductBody(
        portfolioId: portfolioId,
        selectedSedeId: selectedSedeId,
        onSaved: onSaved,
      ),
    );
  }
}

class _AddEditProductBody extends StatefulWidget {
  final String portfolioId;
  final String selectedSedeId;
  final VoidCallback onSaved;

  const _AddEditProductBody({
    required this.portfolioId,
    required this.selectedSedeId,
    required this.onSaved,
  });

  @override
  State<_AddEditProductBody> createState() => _AddEditProductBodyState();
}

class _AddEditProductBodyState extends State<_AddEditProductBody> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _profitCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  SupplyItemResource? _selectedSupplyItem;
  bool _dataLoaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    _profitCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _loadDataIntoControllers(ProductFormProvider provider) {
    if (!_dataLoaded && provider.name.isNotEmpty) {
      _dataLoaded = true;
      _nameCtrl.text = provider.name;
      _costCtrl.text = provider.costPrice;
      _profitCtrl.text = provider.profitMargin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductFormProvider>(context);

    // Mostrar loading mientras se cargan los datos del producto existente
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B7355)),
      );
    }

    // Cargar datos del producto existente una sola vez cuando estén listos
    if (provider.productId != null) {
      _loadDataIntoControllers(provider);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          if (provider.errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Información del producto
          _buildSectionTitle('Información del Producto'),
          const SizedBox(height: 12),
          
          // Nombre
          _buildTextField(
            controller: _nameCtrl,
            label: 'Nombre del Producto',
            icon: Icons.local_cafe,
          ),
          const SizedBox(height: 16),

          // Fila de precios
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _costCtrl,
                  label: 'Precio de Costo',
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefix: 'S/ ',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _profitCtrl,
                  label: 'Margen (%)',
                  icon: Icons.trending_up,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  suffix: '%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Ingredientes
          _buildSectionTitle('Ingredientes'),
          const SizedBox(height: 12),

          // Lista de ingredientes seleccionados
          Container(
            width: double.infinity,
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
            child: provider.selectedIngredients.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Añade ingredientes usando el selector de abajo',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: provider.selectedIngredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ing = entry.value;
                      final isLast = index == provider.selectedIngredients.length - 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xFF8B7355),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ing.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6F4E37),
                                        ),
                                      ),
                                      Text(
                                        '${ing.quantity} ${_formatUnit(ing.unit)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => provider.removeIngredient(ing.supplyItemId),
                                  icon: const Icon(Icons.delete_outline),
                                  color: const Color(0xFFEF4444),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 64,
                              endIndent: 12,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 16),

          // Añadir ingrediente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: const Color(0xFF8B7355),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Añadir Ingrediente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Dropdown de insumos
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6D3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SupplyItemResource>(
                      isExpanded: true,
                      hint: Text(
                        'Seleccionar insumo',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                      value: _selectedSupplyItem,
                      items: provider.availableSupplyItems.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            '${item.name} (${_formatUnit(item.unit)})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F4E37),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSupplyItem = val),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Fila de cantidad y botón
                Row(
                  children: [
                    // Campo de cantidad con unidad
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6D3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6F4E37),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cantidad',
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            suffixText: _selectedSupplyItem != null 
                                ? _formatUnit(_selectedSupplyItem!.unit)
                                : null,
                            suffixStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B7355),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón añadir
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B7355),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_selectedSupplyItem != null && _qtyCtrl.text.isNotEmpty) {
                              provider.addOrUpdateIngredient(_selectedSupplyItem!, _qtyCtrl.text);
                              setState(() {
                                _selectedSupplyItem = null;
                                _qtyCtrl.clear();
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Añadir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botón guardar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success = await provider.saveProduct(
                        productName: _nameCtrl.text,
                        productCostPrice: _costCtrl.text,
                        productProfitMargin: _profitCtrl.text,
                      );
                      if (success && mounted) {
                        widget.onSaved();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B7355),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF8B7355).withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: provider.isLoading
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
                        Icon(
                          provider.productId == null ? Icons.add : Icons.save,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          provider.productId == null
                              ? 'Crear Producto'
                              : 'Guardar Cambios',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF8B7355),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6F4E37),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
    String? suffix,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6F4E37),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF8B7355),
          ),
          prefixText: prefix,
          prefixStyle: const TextStyle(
            color: Color(0xFF6F4E37),
            fontSize: 16,
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            color: Color(0xFF8B7355),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  String _formatUnit(String unit) {
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
}
