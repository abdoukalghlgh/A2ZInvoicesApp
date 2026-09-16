import 'package:uuid/uuid.dart';

class Product {
  final String id;
  String name;
  String unit;
  double unitPrice;
  double quantityInStock;

  Product({
    String? id,
    this.name = '',
    this.unit = 'قطعة',
    this.unitPrice = 0,
    this.quantityInStock = 0,
  }) : id = id ?? const Uuid().v4();

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String?,
        name: json['name'] ?? '',
        unit: json['unit'] ?? 'قطعة',
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        quantityInStock: (json['quantityInStock'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'unitPrice': unitPrice,
        'quantityInStock': quantityInStock,
      };
}
