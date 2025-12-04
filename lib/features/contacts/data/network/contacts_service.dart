import 'package:dio/dio.dart';
import '../models/contact_models.dart';

class ContactsService {
  final Dio _dio;

  ContactsService(this._dio);

  // ==========================================
  //               EMPLOYEES
  // ==========================================

  Future<List<EmployeeResource>> getEmployees(String portfolioId) async {
    final response = await _dio.get('/api/v1/contact-portfolios/$portfolioId/employees');
    return (response.data as List).map((x) => EmployeeResource.fromJson(x)).toList();
  }

  Future<EmployeeResource> addEmployee(String portfolioId, EmployeeRequest request) async {
    final response = await _dio.post(
      '/api/v1/contact-portfolios/$portfolioId/employees',
      data: request.toJson(),
    );
    return EmployeeResource.fromJson(response.data);
  }

  Future<EmployeeResource> getEmployeeById(String portfolioId, int employeeId) async {
    final response = await _dio.get('/api/v1/contact-portfolios/$portfolioId/employees/$employeeId');
    return EmployeeResource.fromJson(response.data);
  }

  Future<EmployeeResource> updateEmployee(String portfolioId, int employeeId, EmployeeRequest request) async {
    final response = await _dio.put(
      '/api/v1/contact-portfolios/$portfolioId/employees/$employeeId',
      data: request.toJson(),
    );
    return EmployeeResource.fromJson(response.data);
  }

  Future<void> deleteEmployee(String portfolioId, int employeeId) async {
    await _dio.delete('/api/v1/contact-portfolios/$portfolioId/employees/$employeeId');
  }

  // ==========================================
  //               PROVIDERS
  // ==========================================

  Future<List<ProviderResource>> getProviders(String portfolioId) async {
    final response = await _dio.get('/api/v1/contact-portfolios/$portfolioId/providers');
    return (response.data as List).map((x) => ProviderResource.fromJson(x)).toList();
  }

  Future<ProviderResource> addProvider(String portfolioId, ProviderRequest request) async {
    final response = await _dio.post(
      '/api/v1/contact-portfolios/$portfolioId/providers',
      data: request.toJson(),
    );
    return ProviderResource.fromJson(response.data);
  }

  Future<ProviderResource> getProviderById(String portfolioId, int providerId) async {
    final response = await _dio.get('/api/v1/contact-portfolios/$portfolioId/providers/$providerId');
    return ProviderResource.fromJson(response.data);
  }

  Future<ProviderResource> updateProvider(String portfolioId, int providerId, ProviderRequest request) async {
    final response = await _dio.put(
      '/api/v1/contact-portfolios/$portfolioId/providers/$providerId',
      data: request.toJson(),
    );
    return ProviderResource.fromJson(response.data);
  }

  Future<void> deleteProvider(String portfolioId, int providerId) async {
    await _dio.delete('/api/v1/contact-portfolios/$portfolioId/providers/$providerId');
  }
}