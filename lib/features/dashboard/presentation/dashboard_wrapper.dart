import 'package:flutter/material.dart';
import 'package:icafe_flutter/features/finances/presentation/finances_screen.dart';
import '../../contacts/presentation/pages/contactos_screen.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../inventory/presentation/movements/movements_screen.dart';
import 'dashboard_screen.dart';

class DashboardWrapper extends StatefulWidget {
  final int branchId;
  final String sedeName;

  const DashboardWrapper({
    super.key,
    required this.branchId,
    required this.sedeName,
  });

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatingIconController;
  late Animation<double> _floatingIconAnimation;

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
  }

  @override
  void dispose() {
    _floatingIconController.dispose();
    super.dispose();
  }

  Widget _buildCurrentScreen() {
    // Usamos portfolioId fijo "1" como ejemplo, o lo derivas de tu lógica global
    const String portfolioId = "1";

    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          branchId: widget.branchId,
          sedeName: widget.sedeName,
        );
      case 1:
        return ContactosScreen(
          branchId: widget.branchId,
        );
      case 2:
        return InventoryScreen(
          portfolioId: portfolioId,
          selectedSedeId: widget.branchId.toString(),
        );
      case 3:
        return FinancesScreen(
          branchId: widget.branchId,
        );
      case 4:
        return Scaffold(
          backgroundColor: const Color(0xFFF5E6D3),
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
                title: const Text('Movimiento'),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() => _selectedIndex = 0);
                  },
                ),
              ),
            ),
          ),
          body: MovementsScreen(
            branchId: widget.branchId,
          ),
        );
      default:
        return DashboardScreen(
          branchId: widget.branchId,
          sedeName: widget.sedeName,
        );
    }
  }

  Widget _buildPlaceholderScreen(String title) {
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
            title: Text(title),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Próximamente: $title',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF6F4E37),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
                      color: Colors.black.withOpacity(0.1),
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
                                color: Colors.white.withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                            if (!isSelected) const SizedBox(height: 8),
                            if (!isSelected)
                              Text(
                                items[index]['label'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
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
                          color: Colors.black.withOpacity(0.3 * animationValue),
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