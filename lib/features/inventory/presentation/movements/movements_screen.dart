import 'package:flutter/material.dart';
import '../../data/models/inventory_models.dart';
import '../../data/repositories/movements_repository.dart';
import '../../data/services/movements_pdf_service.dart';
import '../../domain/entities/stock_movement.dart';

class MovementsScreen extends StatefulWidget {
  final int branchId;
  final VoidCallback? onBack;

  const MovementsScreen({
    super.key,
    required this.branchId,
    this.onBack,
  });

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final MovementsRepository _repository = MovementsRepository();
  List<StockMovement> _movements = [];
  Map<int, SupplyItemResource> _supplyItemsMap = {};
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  String? _error;
  String _selectedFilter = 'TODOS'; // TODOS, ENTRADA, SALIDA

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movements = await _repository.getMovementsByBranch(widget.branchId);
      final supplyItems = await _repository.getSupplyItemsForMovements(movements);
      
      setState(() {
        _movements = movements;
        _supplyItemsMap = supplyItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshMovements() {
    _loadData();
  }

  Future<void> _generateAndOpenPdf() async {
    if (_movements.isEmpty) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final filteredMovements = _filterMovements(_movements);
      final file = await MovementsPdfService.generateMovementsReport(
        movements: filteredMovements,
        supplyItemsMap: _supplyItemsMap,
        filterType: _selectedFilter,
      );
      
      await MovementsPdfService.openPdf(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<StockMovement> _filterMovements(List<StockMovement> movements) {
    if (_selectedFilter == 'TODOS') {
      return movements;
    }
    return movements.where((m) => m.type.toUpperCase() == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFF5E6D3);

    return Scaffold(
      backgroundColor: lightPeach,
      body: Column(
        children: [
          // Header con título y filtros
          _buildHeader(),
          // Lista de movimientos
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8B7355),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_movements.isEmpty) {
      return _buildEmptyState();
    }

    final filteredMovements = _filterMovements(_movements);
    
    if (filteredMovements.isEmpty) {
      return _buildEmptyFilterState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: const Color(0xFF8B7355),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: filteredMovements.length,
        itemBuilder: (context, index) {
          return _buildMovementCard(filteredMovements[index]);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de Movimientos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Control de entradas y salidas de inventario',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF8B7355).withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón de descargar PDF
              if (!_isLoading && _movements.isNotEmpty)
                _buildDownloadButton(),
            ],
          ),
          const SizedBox(height: 16),
          // Filtros
          Row(
            children: [
              _buildFilterChip('TODOS', 'Todos'),
              const SizedBox(width: 8),
              _buildFilterChip('ENTRADA', 'Entradas'),
              const SizedBox(width: 8),
              _buildFilterChip('SALIDA', 'Salidas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return GestureDetector(
      onTap: _isGeneratingPdf ? null : _generateAndOpenPdf,
      child: Container(
        width: 48,
        height: 48,
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
        child: _isGeneratingPdf
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B7355) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B7355) : const Color(0xFF8B7355).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6F4E37),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementCard(StockMovement movement) {
    final isEntrada = movement.isEntrada;
    final typeColor = isEntrada ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final typeIcon = isEntrada ? Icons.arrow_downward : Icons.arrow_upward;
    final typeLabel = isEntrada ? 'Entrada' : 'Salida';
    
    // Obtener información del supply item
    final supplyItem = _supplyItemsMap[movement.supplyItemId];
    final itemName = supplyItem?.name ?? 'Insumo #${movement.supplyItemId}';
    final itemUnit = _formatUnit(supplyItem?.unit);

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de tipo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Información principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del insumo
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tipo badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ),
                      // Cantidad con unidad
                      Text(
                        '${isEntrada ? '+' : '-'}${movement.quantity.toStringAsFixed(movement.quantity == movement.quantity.toInt() ? 0 : 2)} $itemUnit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Origen
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          movement.origin,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Fecha y hora
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(movement.movementDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(movement.movementDate),
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
          ],
        ),
      ),
    );
  }

  String _formatUnit(String? unit) {
    if (unit == null || unit.isEmpty) return '';
    // Convertir unidades de mayúsculas a formato legible
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
      case 'PIEZAS':
        return 'pzas';
      default:
        return unit.toLowerCase();
    }
  }

  Widget _buildErrorState(String error) {
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
              'Error al cargar movimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshMovements,
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
              Icons.inventory_outlined,
              size: 80,
              color: const Color(0xFF8B7355).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin movimientos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay movimientos de inventario registrados',
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

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: const Color(0xFF8B7355).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin ${_selectedFilter.toLowerCase()}s',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay movimientos de tipo ${_selectedFilter.toLowerCase()}',
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
}
