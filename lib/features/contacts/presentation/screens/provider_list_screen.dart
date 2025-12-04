import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_providers.dart';
import '../../data/network/contacts_service.dart';
import 'add_edit_provider_screen.dart';
import 'provider_detail_screen.dart';

class ProviderListScreen extends StatelessWidget {
  final String portfolioId;
  final String selectedSedeId;

  const ProviderListScreen({super.key, required this.portfolioId, required this.selectedSedeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProviderListProvider(Provider.of<ContactsService>(context, listen: false), portfolioId),
      child: const _ListContent(),
    );
  }
}

class _ListContent extends StatelessWidget {
  const _ListContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderListProvider>(context);
    const oliveGreen = Color(0xFF556B2F);
    const brownMedium = Color(0xFFA52A2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(title: const Text("Proveedores"), backgroundColor: oliveGreen, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Agregar Proveedor", style: TextStyle(color: Colors.white, fontSize: 18)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddEditProviderScreen(portfolioId: provider.portfolioId, selectedSedeId: "1")
                  )).then((_) => provider.loadProviders());
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: brownMedium, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Expanded(child: Text("NOMBRE", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(child: Text("TELÉFONO", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: oliveGreen))
                  : provider.providers.isEmpty
                  ? const Center(child: Text("No hay proveedores registrados."))
                  : ListView.separated(
                itemCount: provider.providers.length,
                separatorBuilder: (_,__) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final prov = provider.providers[i];
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(child: _Cell(prov.nameCompany)),
                            const SizedBox(width: 8),
                            Expanded(child: _Cell(prov.phoneNumber)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ProviderDetailScreen(portfolioId: provider.portfolioId, selectedSedeId: "1", providerId: prov.id)
                          )).then((_) => provider.loadProviders());
                        },
                        child: const Text("Ver más", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  const _Cell(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
    );
  }
}