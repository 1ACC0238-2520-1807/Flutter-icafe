import 'package:flutter/material.dart';
import 'agregar_empleado_screen.dart';
import 'ver_mas_empleado_screen.dart';
import '../../data/repositories/empleado_repository.dart';
import '../../domain/entities/empleado.dart';
import '../../../auth/data/secure_storage.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

enum _EmpleadosViewState { lista, agregar, verMas }

class EmpleadosScreen extends StatefulWidget {
  final int branchId;
  final VoidCallback? onBack;
  
  const EmpleadosScreen({
    super.key, 
    required this.branchId,
    this.onBack,
  });

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  final EmpleadoRepository _repository = EmpleadoRepository();
  bool _isLoading = true;
  List<Empleado> _empleados = [];
  String? _error;
  int? _portfolioId;
  _EmpleadosViewState _currentView = _EmpleadosViewState.lista;
  Empleado? _selectedEmpleado;

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
      _loadEmpleados();
    } else {
      setState(() {
        _error = 'No se encontró el ID del usuario';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmpleados() async {
    if (_portfolioId == null) return;
    
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final empleados = await _repository.getEmpleados(_portfolioId!);
      if (!mounted) return;
      setState(() {
        _empleados = empleados;
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
      case _EmpleadosViewState.lista:
        return 'Empleados';
      case _EmpleadosViewState.agregar:
        return 'Agregar Empleado';
      case _EmpleadosViewState.verMas:
        return 'Detalles del Empleado';
    }
  }

  void _handleBack() {
    if (_currentView != _EmpleadosViewState.lista) {
      setState(() {
        _currentView = _EmpleadosViewState.lista;
        _selectedEmpleado = null;
      });
      if (mounted) {
        _loadEmpleados();
      }
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
      case _EmpleadosViewState.lista:
        return _buildListaView();
      case _EmpleadosViewState.agregar:
        if (_portfolioId == null) return const SizedBox();
        return AgregarEmpleadoScreen(
          branchId: widget.branchId,
          portfolioId: _portfolioId!,
          onBack: null,
        );
      case _EmpleadosViewState.verMas:
        if (_selectedEmpleado == null || _portfolioId == null) {
          return const SizedBox();
        }
        return VerMasEmpleadoScreen(
          empleado: _selectedEmpleado!,
          portfolioId: _portfolioId!,
          onBack: null,
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
          // Botón "Agregar Empleado"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: oliveGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentView = _EmpleadosViewState.agregar;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agregar Empleado',
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
          // Lista de empleados
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
                      onPressed: _loadEmpleados,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildListaEmpleados(),
        ],
      ),
    );
  }

  Widget _buildListaEmpleados() {
    if (_empleados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            'No hay empleados registrados.',
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
      itemCount: _empleados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final empleado = _empleados[index];
        return _buildEmpleadoItem(empleado);
      },
    );
  }

  Widget _buildEmpleadoItem(Empleado empleado) {
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
              empleado.nombre,
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
                _selectedEmpleado = empleado;
                _currentView = _EmpleadosViewState.verMas;
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

