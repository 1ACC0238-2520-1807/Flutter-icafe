import 'package:flutter/material.dart';
import 'agregar_proveedor_screen.dart';
import 'ver_mas_proveedor_screen.dart';
import 'editar_proveedor_screen.dart';
import '../../data/repositories/proveedor_repository.dart';
import '../../domain/entities/proveedor.dart';
import '../../../auth/data/secure_storage.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

enum _ProveedoresViewState { lista, agregar, verMas, editar }

class ProveedoresScreen extends StatefulWidget {
  final int branchId;
  final VoidCallback? onBack;
  
  const ProveedoresScreen({
    super.key, 
    required this.branchId,
    this.onBack,
  });

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final ProveedorRepository _repository = ProveedorRepository();
  bool _isLoading = true;
  List<Proveedor> _proveedores = [];
  String? _error;
  int? _portfolioId;
  _ProveedoresViewState _currentView = _ProveedoresViewState.lista;
  Proveedor? _selectedProveedor;

  @override
  void initState() {
    super.initState();
    _loadPortfolioId();
  }

  Future<void> _loadPortfolioId() async {
    final userId = await SecureStorage.readUserId();
    if (!mounted) return;
    if (userId != null) {
      setState(() {
        _portfolioId = userId;
      });
      _loadProveedores();
    } else {
      setState(() {
        _error = 'No se encontró el ID del usuario';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProveedores() async {
    if (_portfolioId == null) return;
    
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final proveedores = await _repository.getProveedores(_portfolioId!);
      if (!mounted) return;
      setState(() {
        _proveedores = proveedores;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case _ProveedoresViewState.lista:
        return 'Proveedores';
      case _ProveedoresViewState.agregar:
        return 'Agregar Proveedor';
      case _ProveedoresViewState.verMas:
        return 'Detalles del Proveedor';
      case _ProveedoresViewState.editar:
        return 'Editar Proveedor';
    }
  }

  void _handleBack() {
    if (_currentView == _ProveedoresViewState.editar) {
      setState(() {
        _currentView = _ProveedoresViewState.verMas;
      });
    } else if (_currentView != _ProveedoresViewState.lista) {
      setState(() {
        _currentView = _ProveedoresViewState.lista;
        _selectedProveedor = null;
      });
      if (mounted) {
        _loadProveedores();
      }
    } else {
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _goToEditarProveedor() {
    setState(() {
      _currentView = _ProveedoresViewState.editar;
    });
  }

  void _onProveedorEditado() {
    setState(() {
      _currentView = _ProveedoresViewState.lista;
      _selectedProveedor = null;
    });
    _loadProveedores();
  }

  Widget _buildView() {
    switch (_currentView) {
      case _ProveedoresViewState.lista:
        return _buildListaView();
      case _ProveedoresViewState.agregar:
        if (_portfolioId == null) return const SizedBox();
        return AgregarProveedorScreen(
          branchId: widget.branchId,
          portfolioId: _portfolioId!,
          onBack: null,
        );
      case _ProveedoresViewState.verMas:
        if (_selectedProveedor == null || _portfolioId == null) {
          return const SizedBox();
        }
        return VerMasProveedorScreen(
          proveedor: _selectedProveedor!,
          portfolioId: _portfolioId!,
          onBack: null,
          onEditar: _goToEditarProveedor,
        );
      case _ProveedoresViewState.editar:
        if (_selectedProveedor == null || _portfolioId == null) {
          return const SizedBox();
        }
        return EditarProveedorScreen(
          proveedor: _selectedProveedor!,
          portfolioId: _portfolioId!,
          onBack: null,
          onProveedorEditado: _onProveedorEditado,
        );
    }
  }

  Widget _buildListaView() {
    const oliveGreen = Color(0xFF8B7355);
    const darkBrown = Color(0xFF5D4037);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Botón "Agregar Proveedor"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: oliveGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentView = _ProveedoresViewState.agregar;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agregar Proveedor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Botón "NOMBRE"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: darkBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'NOMBRE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Lista de proveedores
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProveedores,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildListaProveedores(),
        ],
      ),
    );
  }

  Widget _buildListaProveedores() {
    if (_proveedores.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            'No hay proveedores registrados.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _proveedores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final proveedor = _proveedores[index];
        return _buildProveedorItem(proveedor);
      },
    );
  }

  Widget _buildProveedorItem(Proveedor proveedor) {
    const oliveGreen = Color(0xFF8B7355);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              proveedor.nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: oliveGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedProveedor = proveedor;
                _currentView = _ProveedoresViewState.verMas;
              });
            },
            child: const Text(
              'Ver más',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

}


