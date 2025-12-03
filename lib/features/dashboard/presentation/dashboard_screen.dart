import 'package:flutter/material.dart';
import '../../auth/data/secure_storage.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  final int branchId;
  final String sedeName;

  const DashboardScreen({
    super.key,
    required this.branchId,
    required this.sedeName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final portfolioId = await SecureStorage.readUserId();
    if (portfolioId != null) {
      return await _dashboardService.getDashboardData(
        branchId: widget.branchId,
        portfolioId: portfolioId.toString(),
      );
    }
    throw Exception('No portfolio ID found');
  }

  void _retryLoadDashboardData() {
    setState(() {
      _dashboardDataFuture = _loadDashboardData();
    });
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
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D4037),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: AppBar(
            title: const Text('Inicio'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _onLogout,
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B7355),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFF8B7355),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar datos',
                    style: TextStyle(
                      color: Color(0xFF6F4E37),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8B7355),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryLoadDashboardData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7355),
                    ),
                    child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          final dashboardData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSedeCard(dashboardData['sedeName'] as String? ?? widget.sedeName),
                const SizedBox(height: 24),
                _buildSalesStatsCard(
                  (dashboardData['totalSalesAmount'] as num?)?.toDouble() ?? 0.0,
                  (dashboardData['totalSalesCount'] as num?)?.toInt() ?? 0,
                  (dashboardData['averageSaleAmount'] as num?)?.toDouble() ?? 0.0,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Empleados',
                        value: (dashboardData['totalEmployees'] ?? 0).toString(),
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Proveedores',
                        value: (dashboardData['totalProviders'] ?? 0).toString(),
                        icon: Icons.local_shipping,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Insumos',
                        value: (dashboardData['totalSupplyItems'] ?? 0).toString(),
                        icon: Icons.shopping_basket,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Productos',
                        value: (dashboardData['totalProducts'] ?? 0).toString(),
                        icon: Icons.local_cafe,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Ventas Totales',
                        value: ((dashboardData['totalSalesAmount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2),
                        icon: Icons.monetization_on,
                        unit: 'S/.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Compras Totales',
                        value: ((dashboardData['totalPurchasesAmount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2),
                        icon: Icons.shopping_cart,
                        unit: 'S/.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSedeCard(String sedeName) {
    return Card(
      color: const Color(0xFF8B7355),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF5D5C8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store,
                color: Color(0xFF6F4E37),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sede Actual:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  sedeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStatsCard(
      double totalSalesAmount,
      int totalSalesCount,
      double averageSaleAmount,
      ) {
    return Card(
      color: const Color(0xFFF5D5C8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Resumen de Ventas',
              style: TextStyle(
                color: Color(0xFF6F4E37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Divider(
              color: const Color(0xFF6F4E37).withOpacity(0.2),
              thickness: 1,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSalesStatItem(
                  'Total Vendido',
                  'S/. ${totalSalesAmount.toStringAsFixed(2)}',
                  const Color(0xFF8B7355),
                ),
                _buildSalesStatItem(
                  'Nº Ventas',
                  totalSalesCount.toString(),
                  const Color(0xFF9E8B7E),
                ),
                _buildSalesStatItem(
                  'Promedio Venta',
                  'S/. ${averageSaleAmount.toStringAsFixed(2)}',
                  const Color(0xFF6F4E37),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6F4E37),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    String unit = '',
  }) {
    return Card(
      color: const Color(0xFF8B7355),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}