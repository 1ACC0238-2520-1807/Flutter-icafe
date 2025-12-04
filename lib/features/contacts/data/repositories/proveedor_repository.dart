import '../../domain/entities/proveedor.dart';
import 'proveedor_service.dart';

class ProveedorRepository {
  final ProveedorService _service = ProveedorService();

  Future<List<Proveedor>> getProveedores(int portfolioId) async {
    return await _service.getAllProveedores(portfolioId);
  }

  Future<Proveedor> agregarProveedor(Proveedor proveedor, int portfolioId) async {
    return await _service.createProveedor(proveedor, portfolioId);
  }

  Future<Proveedor> actualizarProveedor(Proveedor proveedor, int portfolioId) async {
    return await _service.updateProveedor(proveedor, portfolioId);
  }

  Future<void> eliminarProveedor(String id, int portfolioId) async {
    await _service.deleteProveedor(id, portfolioId);
  }

  Future<Proveedor> obtenerProveedorPorId(String id, int portfolioId) async {
    return await _service.getProveedorById(id, portfolioId);
  }
}


