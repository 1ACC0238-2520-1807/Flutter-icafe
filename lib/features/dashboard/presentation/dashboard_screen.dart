import 'package:flutter/material.dart';
import '../../auth/data/secure_storage.dart';
import '../../auth/presentation/login_screen.dart';
import '../../contacts/presentation/contacts_container.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../inventory/presentation/movements/movements_screen.dart';
import '../../finances/presentation/finances_screen.dart';
import '../data/services/dashboard_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';

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

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatingIconController;
  late Animation<double> _floatingIconAnimation;
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    
    _floatingIconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingIconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _floatingIconController, curve: Curves.elasticOut),
    );

    _floatingIconController.forward();
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

   @override
  void dispose() {
    _floatingIconController.dispose();
    super.dispose();
  }

  void _onNavigationItemTapped(int index) {
    if (_selectedIndex != index) {
      _floatingIconController.reset();
      setState(() {
        _selectedIndex = index;
      });
      _floatingIconController.forward();
    }
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

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return ContactsContainer(
          branchId: widget.branchId,
          selectedIndex: _selectedIndex,
          onNavigationChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          onBack: () {
            setState(() => _selectedIndex = 0);
          },
        );
      case 2:
        return InventoryScreen(
          portfolioId: '', 
          selectedSedeId: '',
        );
      case 3:
        return FinancesScreen(
          branchId: widget.branchId,
          onBack: () {
            setState(() => _selectedIndex = 0);
          },
        );
      case 4:
        return _buildMovementsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
     appBar: CustomAppBar(
        title: 'Inicio',
        onBackPressed: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onLogout,
          ),
        ],
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

  Widget _buildMovementsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: CustomAppBar(
        title: 'Movimiento',
        onBackPressed: () {
          setState(() => _selectedIndex = 0);
        },
      ),
      body: MovementsScreen(
        branchId: widget.branchId,
        onBack: () {
          setState(() => _selectedIndex = 0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
              color: const Color(0xFF6F4E37).withValues(alpha:0.2),
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

  Widget _buildBottomNavigationBar() {
    final items = [
      {'icon': Icons.home, 'label': 'Inicio'},
      {'icon': Icons.people, 'label': 'Contactos'},
      {'icon': Icons.restaurant, 'label': 'Alimentos'},
      {'icon': Icons.attach_money, 'label': 'Finanzas'},
      {'icon': Icons.trending_up, 'label': 'Movimiento'},
    ];

    return AnimatedBuilder(
      animation: _floatingIconController,
      builder: (context, child) {
        final animationValue = _floatingIconAnimation.value;
        final baseBottom = 5.0;
        final elevatedBottom = 35.0;
        final currentBottom =
            baseBottom + (elevatedBottom - baseBottom) * animationValue;

        return SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Barra simple sin deformación
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D4037),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(items.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onNavigationItemTapped(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Opacity(
                              opacity: isSelected ? 0 : 1,
                              child: Icon(
                                items[index]['icon'] as IconData,
                                color: Colors.white.withValues(alpha: 0.6),
                                size: 24,
                              ),
                            ),
                            if (!isSelected)
                              const SizedBox(height: 8),
                            if (!isSelected)
                              Text(
                                items[index]['label'] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Ícono elevado animado
              Positioned(
                bottom: currentBottom,
                left: (MediaQuery.of(context).size.width / 5) * _selectedIndex +
                    (MediaQuery.of(context).size.width / 10) -
                    28,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * animationValue),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D4037),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF5F3F0),
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3 * animationValue),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      (items[_selectedIndex]['icon'] as IconData),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}