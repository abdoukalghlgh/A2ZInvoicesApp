import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import 'new_invoice_screen.dart';
import 'customers_screen.dart';
import 'suppliers_screen.dart';
import 'products_screen.dart';
import 'invoice_list_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامج مبيعات النور'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'إعدادات الشركة',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            MenuCard(
              icon: Icons.receipt_long,
              title: 'فاتورة جديدة',
              color: const Color(0xFF193A5F),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NewInvoiceScreen())),
            ),
            MenuCard(
              icon: Icons.list_alt,
              title: 'سجل الفواتير',
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const InvoiceListScreen())),
            ),
            MenuCard(
              icon: Icons.people_alt,
              title: 'الزبائن',
              color: const Color(0xFFB06A00),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const CustomersScreen())),
            ),
            MenuCard(
              icon: Icons.local_shipping,
              title: 'الممونون',
              color: const Color(0xFF6A1B9A),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SuppliersScreen())),
            ),
            MenuCard(
              icon: Icons.inventory_2,
              title: 'السلع والمخزون',
              color: const Color(0xFF00838F),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
            ),
            MenuCard(
              icon: Icons.business,
              title: 'معلومات الشركة',
              color: const Color(0xFF37474F),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
