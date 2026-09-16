import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';

import '../models/invoice.dart';
import '../services/data_store.dart';
import '../services/pdf_exporter.dart';
import 'invoice_preview_screen.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الفواتير')),
      body: ValueListenableBuilder<List<Invoice>>(
        valueListenable: store.invoices,
        builder: (context, invoices, _) {
          if (invoices.isEmpty) {
            return const Center(child: Text('لا توجد فواتير محفوظة بعد.'));
          }
          final sorted = [...invoices]..sort((a, b) => b.date.compareTo(a.date));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final inv = sorted[i];
              return Card(
                child: ListTile(
                  title: Text('فاتورة رقم ${inv.number}', textAlign: TextAlign.right),
                  subtitle: Text(
                    '${inv.customerName} • ${DateFormat('dd/MM/yyyy').format(inv.date)} • ${inv.grandTotal.toStringAsFixed(2)} د.ج',
                    textAlign: TextAlign.right,
                  ),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: inv))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Color(0xFF193A5F)),
                        onPressed: () => _share(context, inv),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, inv),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _share(BuildContext context, Invoice invoice) async {
    final company = DataStore.instance.company;
    final file = await PdfExporter.exportInvoice(invoice, company);
    final companyName = company.name.trim().isEmpty ? 'مؤسسة النور' : company.name;
    final customerName = invoice.customerName.trim().isEmpty ? 'زبوننا الكريم' : invoice.customerName;
    final date = DateFormat('dd/MM/yyyy').format(invoice.date);
    final message = 'السلام عليكم $customerName،\n'
        'نرسل لكم فاتورة رقم ${invoice.number} بتاريخ $date.\n'
        'المجموع الكلي: ${invoice.grandTotal.toStringAsFixed(2)} دج.\n'
        'مع تحيات $companyName.';
    await Share.shareXFiles([XFile(file.path)], text: message, subject: 'فاتورة رقم ${invoice.number}');
  }

  void _confirmDelete(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الفاتورة رقم "${invoice.number}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DataStore.instance.removeInvoice(invoice);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
