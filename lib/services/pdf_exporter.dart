import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/company_info.dart';
import '../models/invoice.dart';
import 'number_to_arabic_words.dart';

/// يبني فاتورة تجارية بصيغة PDF مناسبة للطباعة على A4، منقولة عن تصميم
/// نسخة سطح المكتب (InvoiceDocumentBuilder.cs) بنفس الألوان والتخطيط.
class PdfExporter {
  static const PdfColor navy = PdfColor.fromInt(0xFF193A5F);
  static const PdfColor lightBlue = PdfColor.fromInt(0xFFEBF2F9);
  static const PdfColor softGray = PdfColor.fromInt(0xFFF7F8FA);
  static const PdfColor border = PdfColor.fromInt(0xFF78828C);

  static pw.Font? _regular;
  static pw.Font? _bold;
  static bool _fontsAvailable = true;

  static Future<void> _ensureFonts() async {
    if (_regular != null && _bold != null) return;
    try {
      final regData =
          await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
      final boldData =
          await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf');
      _regular = pw.Font.ttf(regData);
      _bold = pw.Font.ttf(boldData);
      _fontsAvailable = true;
    } catch (_) {
      // لم يُضف الخط العربي بعد إلى assets/fonts (راجع README.md).
      // نستمر بالخط الافتراضي حتى لا يتعطل التطبيق، لكن النص العربي
      // لن يظهر بشكل صحيح إلى أن يُضاف الخط.
      _fontsAvailable = false;
    }
  }

  static String buildFileName(Invoice invoice) {
    final safeNumber = invoice.number.replaceAll('/', '-');
    return 'invoice_$safeNumber.pdf';
  }

  /// يبني مستند الفاتورة ويعيده جاهزًا للمعاينة أو الطباعة أو الحفظ.
  static Future<pw.Document> buildDocument(
      Invoice invoice, CompanyInfo company) async {
    await _ensureFonts();

    final theme = _fontsAvailable
        ? pw.ThemeData.withFont(base: _regular, bold: _bold)
        : pw.ThemeData.base();

    final doc = pw.Document(theme: theme);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildHeader(invoice, company),
          pw.SizedBox(height: 10),
          _buildCustomerTable(invoice),
          pw.SizedBox(height: 9),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 9),
          _buildTotalsAndPayment(invoice),
          pw.SizedBox(height: 8),
          _buildWordsBox(invoice),
          pw.SizedBox(height: 8),
          _buildSignatureBlock(),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'هذه الفاتورة محررة آليًا وتعتبر وثيقة تجارية عند استكمال التوقيع والختم.',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  /// ينشئ ملف PDF للفاتورة في مجلد مؤقت داخل التطبيق ويعيد مساره الكامل.
  static Future<File> exportInvoice(
      Invoice invoice, CompanyInfo company) async {
    final doc = await buildDocument(invoice, company);
    final bytes = await doc.save();

    final dir = await getTemporaryDirectory();
    final invoicesDir = Directory('${dir.path}/invoices');
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }
    final file = File('${invoicesDir.path}/${buildFileName(invoice)}');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ---------------- أجزاء بناء المستند ----------------

  static pw.Widget _rtlText(
    String text, {
    double fontSize = 11,
    PdfColor color = PdfColors.black,
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.right,
  }) {
    return pw.Text(
      text,
      textDirection: pw.TextDirection.rtl,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        font: bold ? _bold : _regular,
      ),
    );
  }

  static pw.Widget _buildHeader(Invoice invoice, CompanyInfo company) {
    return pw.Table(
      border: pw.TableBorder.all(color: navy, width: 1.1),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.05),
        1: pw.FlexColumnWidth(2.75),
        2: pw.FlexColumnWidth(1.35),
      },
      children: [
        pw.TableRow(children: [
          pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Container(
              width: 55,
              height: 55,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: navy, width: 2.2),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text('ن',
                  style: pw.TextStyle(
                      fontSize: 30, color: navy, font: _bold)),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Center(
                  child: _rtlText(
                    company.name.trim().isEmpty
                        ? 'اسم الشركة / الممون'
                        : company.name,
                    fontSize: 22,
                    color: navy,
                    bold: true,
                    align: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 4),
                ..._companyLines(company),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            color: lightBlue,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _rtlText('فاتورة',
                    fontSize: 18, color: navy, bold: true, align: pw.TextAlign.center),
                pw.SizedBox(height: 8),
                _metaBlock('رقم الفاتورة', invoice.number),
                pw.SizedBox(height: 5),
                _metaBlock('التاريخ', DateFormat('dd/MM/yyyy').format(invoice.date)),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  static List<pw.Widget> _companyLines(CompanyInfo c) {
    final entries = <List<String>>[
      ['النشاط', c.activity],
      ['العنوان', c.address],
      ['السجل التجاري', c.commercialRegister],
      ['الرقم الجبائي', c.taxId],
      ['رقم المادة', c.articleNumber],
    ];
    return entries
        .where((e) => e[1].trim().isNotEmpty)
        .map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 1.5),
              child: pw.RichText(
                textDirection: pw.TextDirection.rtl,
                text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: '${e[0]}: ',
                      style: pw.TextStyle(fontSize: 10.5, font: _bold)),
                  pw.TextSpan(
                      text: e[1], style: pw.TextStyle(fontSize: 10.5, font: _regular)),
                ]),
              ),
            ))
        .toList();
  }

  static pw.Widget _metaBlock(String label, String value) {
    return pw.Column(children: [
      _rtlText(label, fontSize: 10, bold: true, align: pw.TextAlign.center),
      pw.SizedBox(height: 2),
      _rtlText(value, fontSize: 10, align: pw.TextAlign.center),
    ]);
  }

  static pw.Widget _buildCustomerTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.15),
        1: pw.FlexColumnWidth(1.85),
        2: pw.FlexColumnWidth(1.15),
        3: pw.FlexColumnWidth(1.85),
      },
      children: [
        pw.TableRow(children: [
          pw.Container(
            color: navy,
            padding: const pw.EdgeInsets.all(6),
            alignment: pw.Alignment.center,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _rtlText('معلومات الزبون',
                    color: PdfColors.white, bold: true, align: pw.TextAlign.center),
              ],
            ),
          ),
          pw.Container(),
          pw.Container(),
          pw.Container(),
        ]),
        _customerRow('اسم الزبون', invoice.customerName, 'النشاط', invoice.customerActivity),
        _customerRow('العنوان', invoice.customerAddress, 'السجل التجاري',
            invoice.customerCommercialRegister),
        _customerRow('الرقم الجبائي', invoice.customerTaxId, 'طريقة الدفع',
            invoice.paymentMethod),
      ],
    );
  }

  static pw.TableRow _customerRow(
      String label1, String value1, String label2, String value2) {
    return pw.TableRow(children: [
      _labelCell(label1),
      _valueCell(value1),
      _labelCell(label2),
      _valueCell(value2),
    ]);
  }

  static pw.Widget _labelCell(String text) => pw.Container(
        color: softGray,
        padding: const pw.EdgeInsets.all(5),
        child: _rtlText(text, fontSize: 10, bold: true),
      );

  static pw.Widget _valueCell(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(5),
        child: _rtlText(text, fontSize: 10),
      );

  static pw.Widget _buildItemsTable(Invoice invoice) {
    final headers = ['رقم', 'التعيين', 'الوحدة', 'الكمية', 'سعر الوحدة (د.ج)', 'المجموع (د.ج)'];
    final widths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(0.55),
      1: const pw.FlexColumnWidth(3.05),
      2: const pw.FlexColumnWidth(0.85),
      3: const pw.FlexColumnWidth(0.85),
      4: const pw.FlexColumnWidth(1.45),
      5: const pw.FlexColumnWidth(1.55),
    };

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: navy),
        children: headers
            .map((h) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  alignment: pw.Alignment.center,
                  child: _rtlText(h,
                      color: PdfColors.white, bold: true, align: pw.TextAlign.center),
                ))
            .toList(),
      ),
    ];

    var index = 1;
    for (final line in invoice.lines) {
      rows.add(pw.TableRow(children: [
        _bodyCell(index.toString()),
        _bodyCell(line.productName, align: pw.TextAlign.right),
        _bodyCell(line.unit),
        _bodyCell(_trimZeros(line.quantity)),
        _bodyCell(line.unitPrice.toStringAsFixed(2)),
        _bodyCell(line.total.toStringAsFixed(2)),
      ]));
      index++;
    }

    while (rows.length - 1 < 7) {
      rows.add(pw.TableRow(
          children: List.generate(6, (_) => _bodyCell(''))));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.5),
      columnWidths: widths,
      children: rows,
    );
  }

  static String _trimZeros(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  static pw.Widget _bodyCell(String text, {pw.TextAlign align = pw.TextAlign.center}) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        alignment: align == pw.TextAlign.right ? pw.Alignment.centerRight : pw.Alignment.center,
        child: _rtlText(text, fontSize: 9.5, align: align),
      );

  static pw.Widget _buildTotalsAndPayment(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.8),
        1: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(9),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _rtlText('طريقة الدفع', fontSize: 11, color: navy, bold: true),
                pw.SizedBox(height: 8),
                _rtlText(invoice.paymentMethod, fontSize: 10.5),
                pw.SizedBox(height: 7),
                _rtlText('شكرًا لتعاملكم معنا', fontSize: 9, color: PdfColors.grey),
              ],
            ),
          ),
          pw.Container(
            child: pw.Table(
              children: [
                _totalRow('المجموع بدون رسوم', '${invoice.subTotal.toStringAsFixed(2)} د.ج'),
                _totalRow('الرسوم (TVA ${_trimZeros(invoice.vatRate)}%)',
                    '${invoice.vatAmount.toStringAsFixed(2)} د.ج'),
                if (invoice.fiscalStamp > 0)
                  _totalRow('الطابع الجبائي', '${invoice.fiscalStamp.toStringAsFixed(2)} د.ج'),
                _totalRow('المجموع الكلي', '${invoice.grandTotal.toStringAsFixed(2)} د.ج',
                    emphasize: true),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  static pw.TableRow _totalRow(String label, String value, {bool emphasize = false}) {
    final bg = emphasize ? lightBlue : PdfColors.white;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg, border: pw.Border.all(color: border, width: 0.4)),
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          child: _rtlText(label, fontSize: 10, bold: true),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          alignment: pw.Alignment.center,
          child: _rtlText(value, fontSize: 10, bold: true, align: pw.TextAlign.center),
        ),
      ],
    );
  }

  static pw.Widget _buildWordsBox(Invoice invoice) {
    return pw.Container(
      width: double.infinity,
      color: softGray,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: border, width: 0.7)),
      child: pw.RichText(
        textDirection: pw.TextDirection.rtl,
        text: pw.TextSpan(children: [
          pw.TextSpan(text: 'المبلغ بالحروف: ', style: pw.TextStyle(fontSize: 11, font: _bold)),
          pw.TextSpan(
              text: NumberToArabicWords.convert(invoice.grandTotal),
              style: pw.TextStyle(fontSize: 11, font: _regular)),
        ]),
      ),
    );
  }

  static pw.Widget _buildSignatureBlock() {
    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.7),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
      children: [
        pw.TableRow(children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(9),
            alignment: pw.Alignment.center,
            child: pw.Column(children: [
              _rtlText('الزبون', fontSize: 10.5, bold: true, align: pw.TextAlign.center),
              pw.SizedBox(height: 30),
              _rtlText('الإمضاء: ______________________________',
                  fontSize: 9.5, align: pw.TextAlign.center),
            ]),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(9),
            alignment: pw.Alignment.center,
            child: pw.Column(children: [
              _rtlText('الممون / الشركة', fontSize: 10.5, bold: true, align: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Container(
                width: 80,
                height: 40,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all(color: navy, width: 2)),
                child: _rtlText('ختم\nالممون',
                    fontSize: 9, bold: true, color: navy, align: pw.TextAlign.center),
              ),
            ]),
          ),
        ]),
      ],
    );
  }
}
