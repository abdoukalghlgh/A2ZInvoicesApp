import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import '../models/invoice.dart';
import '../services/data_store.dart';
import '../services/pdf_exporter.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Invoice invoice;
  const InvoicePreviewScreen({super.key, required this.invoice});

  String _message() {
    final company = DataStore.instance.company;
    final companyName = company.name.trim().isEmpty ? 'مؤسسة النور' : company.name;
    final customerName = invoice.customerName.trim().isEmpty ? 'زبوننا الكريم' : invoice.customerName;
    final date =
        '${invoice.date.day.toString().padLeft(2, '0')}/${invoice.date.month.toString().padLeft(2, '0')}/${invoice.date.year}';
    return 'السلام عليكم $customerName،\n'
        'نرسل لكم فاتورة رقم ${invoice.number} بتاريخ $date.\n'
        'المجموع الكلي: ${invoice.grandTotal.toStringAsFixed(2)} دج.\n'
        'مع تحيات $companyName.';
  }

  Future<void> _share(BuildContext context) async {
    final company = DataStore.instance.company;
    final file = await PdfExporter.exportInvoice(invoice, company);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: _message(),
      subject: 'فاتورة رقم ${invoice.number}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = DataStore.instance.company;
    return Scaffold(
      appBar: AppBar(
        title: Text('فاتورة رقم ${invoice.number}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة (واتساب / جيميل / أخرى)',
            onPressed: () => _share(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          final doc = await PdfExporter.buildDocument(invoice, company);
          return doc.save();
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: false, // نستخدم زر المشاركة المخصص أعلاه (يشمل نص ورقم الزبون)
        pdfFileName: PdfExporter.buildFileName(invoice),
      ),
    );
  }
}
