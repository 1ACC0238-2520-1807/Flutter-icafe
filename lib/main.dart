import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Necesitas el paquete provider
import 'package:dio/dio.dart'; // IMPORTANTE: Necesitas el paquete dio

// --- Imports de tus Servicios (Asegúrate de que las rutas sean correctas) ---
import 'features/inventory/data/network/inventory_service.dart';
import 'features/products/data/network/product_service.dart';
import 'features/finances/data/network/finance_service.dart';
import 'features/contacts/data/network/contacts_service.dart'; // Asumiendo que ya tienes este

// --- Imports existentes ---
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'core/ui/theme.dart';
import 'features/auth/data/secure_storage.dart';

void main() {
  runApp(const ICafeApp());
}

class ICafeApp extends StatelessWidget {
  const ICafeApp({super.key});

  Future<bool> isAuthenticated() async {
    final token = await SecureStorage.readToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    // Instanciamos el tema
    final IcafeTheme theme = IcafeTheme(const TextTheme());

    return MultiProvider(
      providers: [
        // 1. Proveedor Global de Dio (Cliente HTTP)
        Provider<Dio>(
          create: (_) {
            final dio = Dio(BaseOptions(
              baseUrl: 'http://10.0.2.2:8080', // CAMBIA ESTO por tu IP real o URL de producción
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

            // Interceptor para agregar el Token automáticamente a cada petición
            dio.interceptors.add(InterceptorsWrapper(
              onRequest: (options, handler) async {
                final token = await SecureStorage.readToken();
                if (token != null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
              onError: (DioException e, handler) {
                // Aquí podrías manejar errores globales, como 401 Unauthorized (cerrar sesión)
                print("Error de Dio: ${e.response?.statusCode} - ${e.message}");
                return handler.next(e);
              },
            ));

            return dio;
          },
        ),

        // 2. Inyección de Servicios (Dependen de Dio)
        // Usamos ProxyProvider porque necesitan la instancia de Dio creada arriba
        ProxyProvider<Dio, InventoryService>(
          update: (_, dio, __) => InventoryService(dio),
        ),
        ProxyProvider<Dio, ProductService>(
          update: (_, dio, __) => ProductService(dio),
        ),
        ProxyProvider<Dio, FinanceService>(
          update: (_, dio, __) => FinanceService(dio),
        ),
        ProxyProvider<Dio, ContactsService>(
          update: (_, dio, __) => ContactsService(dio),
        ),
      ],
      child: MaterialApp(
        title: 'iCafe_Flutter',
        debugShowCheckedModeBanner: false,
        theme: theme.light(),
        darkTheme: theme.dark(),
        home: FutureBuilder<bool>(
          future: isAuthenticated(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            // Si el snapshot no tiene datos o es false, vamos al Login
            if (!snapshot.hasData || snapshot.data == false) {
              return const LoginScreen();
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}