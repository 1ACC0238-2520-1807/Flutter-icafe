import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_providers.dart';
import '../../data/network/contacts_service.dart';
import 'add_edit_provider_screen.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

class ProviderDetailScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;
  final int providerId;

  const ProviderDetailScreen({super.key, required this.portfolioId, required this.selectedSedeId, required this.providerId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProviderDetailProvider(
          Provider.of<ContactsService>(context, listen: false),
          portfolioId, providerId
      ),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderDetailProvider>(context);
    final prov = provider.provider;
    const brownMedium = Color(0xFFA52A2A);

    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (prov == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Error cargando proveedor")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Ver Proveedor"), backgroundColor: const Color(0xFF556B2F), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: brownMedium, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(child: Text(prov.nameCompany, style: const TextStyle(color: Colors.white, fontSize: 20))),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AddEditProviderScreen(portfolioId: provider.portfolioId, selectedSedeId: "1", providerId: prov.id)
                      ));
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DetailItem("RUC:", prov.ruc),
            const SizedBox(height: 16),
            _DetailItem("Gmail:", prov.email),
            const SizedBox(height: 16),
            _DetailItem("Teléfono:", prov.phoneNumber),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: brownMedium, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                          title: "¿Quiere eliminar este Proveedor?",
                          onConfirm: () async {
                            Navigator.pop(context);
                            final success = await provider.deleteProvider();
                            if (success && context.mounted) Navigator.pop(context);
                          },
                          onDismiss: () => Navigator.pop(context),
                          backgroundColor: brownMedium
                      )
                  );
                },
                child: const Text("Eliminar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label, value;
  const _DetailItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5D4037))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      )
    ]);
  }
}