import 'package:uuid/uuid.dart';
import 'invoice_line.dart';

double _round2(double v) => double.parse(v.toStringAsFixed(2));

class Invoice {
  final String id;
  String number;
  DateTime date;

  String customerId;
  String customerName;
  String customerActivity;
  String customerAddress;
  String customerCommercialRegister;
  String customerTaxId;

  List<InvoiceLine> lines;

  double vatRate;
  double fiscalStamp;
  String paymentMethod;

  Invoice({
    String? id,
    this.number = '',
    DateTime? date,
    this.customerId = '',
    this.customerName = '',
    this.customerActivity = '',
    this.customerAddress = '',
    this.customerCommercialRegister = '',
    this.customerTaxId = '',
    List<InvoiceLine>? lines,
    this.vatRate = 17,
    this.fiscalStamp = 0,
    this.paymentMethod = 'نقدا',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        lines = lines ?? [];

  double get subTotal => _round2(lines.fold(0.0, (sum, l) => sum + l.total));
  double get vatAmount => _round2(subTotal * vatRate / 100);
  double get grandTotal => _round2(subTotal + vatAmount + fiscalStamp);

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String?,
        number: json['number'] ?? '',
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'] ?? '',
        customerActivity: json['customerActivity'] ?? '',
        customerAddress: json['customerAddress'] ?? '',
        customerCommercialRegister: json['customerCommercialRegister'] ?? '',
        customerTaxId: json['customerTaxId'] ?? '',
        lines: (json['lines'] as List<dynamic>? ?? [])
            .map((e) => InvoiceLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        vatRate: (json['vatRate'] as num?)?.toDouble() ?? 17,
        fiscalStamp: (json['fiscalStamp'] as num?)?.toDouble() ?? 0,
        paymentMethod: json['paymentMethod'] ?? 'نقدا',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'date': date.toIso8601String(),
        'customerId': customerId,
        'customerName': customerName,
        'customerActivity': customerActivity,
        'customerAddress': customerAddress,
        'customerCommercialRegister': customerCommercialRegister,
        'customerTaxId': customerTaxId,
        'lines': lines.map((l) => l.toJson()).toList(),
        'vatRate': vatRate,
        'fiscalStamp': fiscalStamp,
        'paymentMethod': paymentMethod,
      };
}
