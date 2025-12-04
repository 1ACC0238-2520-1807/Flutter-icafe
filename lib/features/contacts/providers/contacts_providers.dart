import 'package:flutter/material.dart';
import '../data/models/contact_models.dart';
import '../data/network/contacts_service.dart';

// EMPLEADOS - LISTA
class EmployeeListProvider extends ChangeNotifier {
  final ContactsService _service;
  final String portfolioId;
  final String selectedSedeId;

  bool isLoading = false;
  String? errorMessage;
  List<EmployeeResource> employees = [];

  EmployeeListProvider(this._service, this.portfolioId, this.selectedSedeId) {
    loadEmployees();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> loadEmployees() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final allEmployees = await _service.getEmployees(portfolioId);
      employees = allEmployees.where((e) => e.branchId == branchId).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// EMPLEADOS - DETALLE / AGREGAR / EDITAR
class EmployeeDetailProvider extends ChangeNotifier {
  final ContactsService _service;
  final String portfolioId;
  final String selectedSedeId;
  final int? employeeId;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  EmployeeResource? employee;

  // Form Fields
  String name = "";
  String role = "";
  String email = "";
  String phoneNumber = "";
  String salary = "";

  EmployeeDetailProvider(this._service, this.portfolioId, this.selectedSedeId, this.employeeId) {
    if (employeeId != null) {
      _loadEmployee();
    }
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> _loadEmployee() async {
    isLoading = true;
    notifyListeners();
    try {
      employee = await _service.getEmployeeById(portfolioId, employeeId!);
      if (employee != null) {
        name = employee!.name;
        role = employee!.role;
        email = employee!.email;
        phoneNumber = employee!.phoneNumber;
        salary = employee!.salary;
      }
    } catch (e) {
      errorMessage = "Error cargando empleado: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveEmployee() async {
    if (name.isEmpty || role.isEmpty || email.isEmpty || phoneNumber.isEmpty || salary.isEmpty) {
      errorMessage = "Todos los campos son obligatorios";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final request = EmployeeRequest(
        name: name,
        role: role,
        email: email,
        phoneNumber: phoneNumber,
        salary: salary,
        branchId: branchId,
      );

      if (employeeId == null) {
        await _service.addEmployee(portfolioId, request);
      } else {
        await _service.updateEmployee(portfolioId, employeeId!, request);
      }
      successMessage = "Empleado guardado correctamente";
      return true;
    } catch (e) {
      errorMessage = "Error al guardar: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEmployee() async {
    if (employeeId == null) return false;
    isLoading = true;
    notifyListeners();
    try {
      await _service.deleteEmployee(portfolioId, employeeId!);
      successMessage = "Empleado eliminado";
      return true;
    } catch (e) {
      errorMessage = "Error al eliminar: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// PROVEEDORES - LISTA
class ProviderListProvider extends ChangeNotifier {
  final ContactsService _service;
  final String portfolioId;

  bool isLoading = false;
  String? errorMessage;
  List<ProviderResource> providers = [];

  ProviderListProvider(this._service, this.portfolioId) {
    loadProviders();
  }

  Future<void> loadProviders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      providers = await _service.getProviders(portfolioId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// PROVEEDORES - DETALLE / AGREGAR / EDITAR
class ProviderDetailProvider extends ChangeNotifier {
  final ContactsService _service;
  final String portfolioId;
  final int? providerId;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  ProviderResource? provider;

  // Form Fields
  String nameCompany = "";
  String ruc = "";
  String email = "";
  String phoneNumber = "";

  ProviderDetailProvider(this._service, this.portfolioId, this.providerId) {
    if (providerId != null) {
      _loadProvider();
    }
  }

  Future<void> _loadProvider() async {
    isLoading = true;
    notifyListeners();
    try {
      provider = await _service.getProviderById(portfolioId, providerId!);
      if (provider != null) {
        nameCompany = provider!.nameCompany;
        ruc = provider!.ruc;
        email = provider!.email;
        phoneNumber = provider!.phoneNumber;
      }
    } catch (e) {
      errorMessage = "Error cargando proveedor: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProvider() async {
    if (nameCompany.isEmpty || ruc.isEmpty || email.isEmpty || phoneNumber.isEmpty) {
      errorMessage = "Todos los campos son obligatorios";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final request = ProviderRequest(
        nameCompany: nameCompany,
        email: email,
        phoneNumber: phoneNumber,
        ruc: ruc,
      );

      if (providerId == null) {
        await _service.addProvider(portfolioId, request);
      } else {
        await _service.updateProvider(portfolioId, providerId!, request);
      }
      successMessage = "Proveedor guardado correctamente";
      return true;
    } catch (e) {
      errorMessage = "Error al guardar: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProvider() async {
    if (providerId == null) return false;
    isLoading = true;
    notifyListeners();
    try {
      await _service.deleteProvider(portfolioId, providerId!);
      successMessage = "Proveedor eliminado";
      return true;
    } catch (e) {
      errorMessage = "Error al eliminar: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}