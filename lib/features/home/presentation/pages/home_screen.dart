import 'package:flutter/material.dart';
import '../../../auth/data/secure_storage.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../data/repositories/branch_service.dart';
import '../../domain/entities/branch.dart';
import '../widgets/my_cafeteria_card.dart';
import '../widgets/sede_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Branch>> _sedesFuture;
  final BranchService _branchService = BranchService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSedes();
  }

  Future<void> _loadSedes() async {
    try {
      final userId = await SecureStorage.readUserId();
      
      if (userId == null) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró el ID del usuario. Por favor inicia sesión nuevamente.')),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _sedesFuture = _branchService.getBranchesByOwnerId(userId.toString());
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: ${e.toString()}')),
        );
      }
    }
  }

  void _onSedeSelected(Branch sede) {
    // TODO: Navegar a la próxima pantalla con la sede seleccionada
    print('Sede seleccionada: ${sede.name}');
  }

  void _onEditSede(Branch sede) {
    // TODO: Implementar pantalla de edición
    print('Editar sede: ${sede.name}');
  }

  void _onDeleteSede(Branch sede) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar sede'),
        content: Text('¿Deseas eliminar la sede "${sede.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _branchService.deleteBranch(sede.id);
                Navigator.pop(context);
                _loadSedes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sede eliminada correctamente')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddSede() {
    // TODO: Implementar pantalla de crear sede
    print('Crear nueva sede');
  }

  Future<void> _onLogout() async {
    await SecureStorage.deleteToken();
    await SecureStorage.deleteUserId();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('iCafe'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6F4E37),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo y título
            const Icon(Icons.local_cafe, size: 80, color: Color(0xFF6F4E37)),
            const SizedBox(height: 8),
            const Text(
              'iCafe',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 32),

            // Card "Mi Cafetería"
            MyCafeteriaCard(onTap: () {}),
            const SizedBox(height: 24),

            // Título de Sedes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis sedes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _onAddSede,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Sede'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F4E37),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de Sedes
            if (!_isInitialized)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              FutureBuilder<List<Branch>>(
                future: _sedesFuture,
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSedes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6F4E37),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_mall_directory,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay sedes registradas.\nPresiona "Añadir Sede" para agregar la primera.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final sedes = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sedes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sede = sedes[index];
                    return SedeItem(
                      sede: sede,
                      onTap: () => _onSedeSelected(sede),
                      onEdit: () => _onEditSede(sede),
                      onDelete: () => _onDeleteSede(sede),
                    );
                  },
                );
              },
              ),
          ],
        ),
      ),
    );
  }
}
