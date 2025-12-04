import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/inventory_models.dart';
import '../../providers/supply_item_form_provider.dart';
import '../../data/network/inventory_service.dart';
import '../../../contacts/data/network/contacts_service.dart';
import '../../../contacts/data/models/contact_models.dart';

/// Widget de contenido para agregar/editar insumo (sin Scaffold propio)
/// Se usa dentro de InventoryScreen para mantener el bottom nav bar
class AddEditSupplyItemContent extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int? supplyItemId;
  final VoidCallback onSaved;

  const AddEditSupplyItemContent({
    super.key,
    required this.portfolioId,
    required this.selectedSedeId,
    this.supplyItemId,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final branchId = int.tryParse(selectedSedeId) ?? 1;
    
    return ChangeNotifierProvider(
      create: (_) => SupplyItemFormProvider(
        inventoryService: Provider.of<InventoryService>(context, listen: false),
        contactsService: Provider.of<ContactsService>(context, listen: false),
        portfolioId: portfolioId,
        branchId: branchId,
        supplyItemId: supplyItemId,
      ),
      child: _AddEditSupplyItemBody(
        onSaved: onSaved,
        isEditing: supplyItemId != null,
      ),
    );
  }
}

class _AddEditSupplyItemBody extends StatefulWidget {
  final VoidCallback onSaved;
  final bool isEditing;

  const _AddEditSupplyItemBody({
    required this.onSaved,
    required this.isEditing,
  });

  @override
  State<_AddEditSupplyItemBody> createState() => _AddEditSupplyItemBodyState();
}

class _AddEditSupplyItemBodyState extends State<_AddEditSupplyItemBody> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  
  bool _dataLoaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _loadDataIntoControllers(SupplyItemFormProvider provider) {
    if (!_dataLoaded && provider.name.isNotEmpty) {
      _dataLoaded = true;
      _nameCtrl.text = provider.name;
      _priceCtrl.text = provider.unitPrice;
      _stockCtrl.text = provider.stock;
    }
  }

  Future<void> _selectExpiryDate(BuildContext context, SupplyItemFormProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.expiredDate != null 
          ? DateTime.parse(provider.expiredDate!)
          : DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B7355),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF6F4E37),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.expiredDate = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupplyItemFormProvider>(context);

    if (provider.isLoading && provider.name.isEmpty && widget.isEditing) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B7355)),
      );
    }

    // Cargar datos si es edición
    if (widget.isEditing) {
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
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
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

          // Información del insumo
          _buildSectionTitle('Información del Insumo'),
          const SizedBox(height: 12),

          // Nombre
          _buildTextField(
            controller: _nameCtrl,
            label: 'Nombre del Insumo',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),

          // Proveedor dropdown
          _buildProviderDropdown(provider),
          const SizedBox(height: 16),

          // Unidad de medida dropdown
          _buildUnitDropdown(provider),
          const SizedBox(height: 16),

          // Precio y Stock
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceCtrl,
                  label: 'Precio Unitario',
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefix: 'S/ ',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stockCtrl,
                  label: 'Stock Inicial',
                  icon: Icons.inventory,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  suffix: provider.selectedUnit != null
                      ? _formatUnitShort(provider.selectedUnit!)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fecha de vencimiento
          _buildExpiryDateSelector(provider),

          const SizedBox(height: 32),

          // Botón guardar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success = await provider.saveSupplyItem(
                        itemName: _nameCtrl.text,
                        itemUnitPrice: _priceCtrl.text,
                        itemStock: _stockCtrl.text,
                      );
                      if (success && mounted) {
                        widget.onSaved();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B7355),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF8B7355).withOpacity(0.5),
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
                          widget.isEditing ? Icons.save : Icons.add,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.isEditing ? 'Guardar Cambios' : 'Crear Insumo',
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
            color: Colors.black.withOpacity(0.04),
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
            color: Colors.black.withOpacity(0.5),
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

  Widget _buildProviderDropdown(SupplyItemFormProvider provider) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(
              Icons.business,
              color: Color(0xFF8B7355),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProviderResource>(
                  isExpanded: true,
                  hint: Text(
                    'Seleccionar proveedor',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  value: provider.selectedProvider,
                  items: provider.availableProviders.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(
                        p.nameCompany,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6F4E37),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    provider.selectedProvider = val;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDropdown(SupplyItemFormProvider provider) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(
              Icons.straighten,
              color: Color(0xFF8B7355),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UnitMeasureType>(
                  isExpanded: true,
                  hint: Text(
                    'Seleccionar unidad de medida',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  value: provider.selectedUnit,
                  items: UnitMeasureType.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(
                        _formatUnit(unit),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6F4E37),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    provider.selectedUnit = val;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryDateSelector(SupplyItemFormProvider provider) {
    final hasDate = provider.expiredDate != null && provider.expiredDate!.isNotEmpty;
    
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectExpiryDate(context, provider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF8B7355),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Vencimiento',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasDate
                            ? _formatDisplayDate(provider.expiredDate!)
                            : 'Sin fecha (opcional)',
                        style: TextStyle(
                          fontSize: 16,
                          color: hasDate
                              ? const Color(0xFF6F4E37)
                              : Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDate)
                  IconButton(
                    onPressed: () {
                      provider.expiredDate = null;
                    },
                    icon: const Icon(Icons.clear, size: 20),
                    color: Colors.black.withOpacity(0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatUnit(UnitMeasureType unit) {
    switch (unit) {
      case UnitMeasureType.GRAMOS:
        return 'Gramos (g)';
      case UnitMeasureType.KILOGRAMOS:
        return 'Kilogramos (kg)';
      case UnitMeasureType.MILILITROS:
        return 'Mililitros (ml)';
      case UnitMeasureType.LITROS:
        return 'Litros (L)';
      case UnitMeasureType.UNIDADES:
        return 'Unidades (uds)';
    }
  }

  String _formatUnitShort(UnitMeasureType unit) {
    switch (unit) {
      case UnitMeasureType.GRAMOS:
        return 'g';
      case UnitMeasureType.KILOGRAMOS:
        return 'kg';
      case UnitMeasureType.MILILITROS:
        return 'ml';
      case UnitMeasureType.LITROS:
        return 'L';
      case UnitMeasureType.UNIDADES:
        return 'uds';
    }
  }

  String _formatDisplayDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }
}
