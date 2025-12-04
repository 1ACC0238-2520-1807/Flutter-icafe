import '../../domain/entities/empleado.dart';
import 'empleado_service.dart';

class EmpleadoRepository {
  final EmpleadoService _service = EmpleadoService();

  Future<List<Empleado>> getEmpleados(int portfolioId) async {
    return await _service.getAllEmpleados(portfolioId);
  }

  Future<Empleado> agregarEmpleado(Empleado empleado, int portfolioId) async {
    return await _service.createEmpleado(empleado, portfolioId);
  }

  Future<Empleado> actualizarEmpleado(Empleado empleado, int portfolioId) async {
    return await _service.updateEmpleado(empleado, portfolioId);
  }

  Future<Empleado> obtenerEmpleadoPorId(String id, int portfolioId) async {
    return await _service.getEmpleadoById(id, portfolioId);
  }

  Future<void> eliminarEmpleado(String id, int portfolioId) async {
    await _service.deleteEmpleado(id, portfolioId);
  }
}


