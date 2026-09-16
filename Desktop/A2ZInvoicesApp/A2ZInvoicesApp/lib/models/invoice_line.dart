class InvoiceLine {
  String productId;
  String productName;
  String unit;
  double quantity;
  double unitPrice;

  InvoiceLine({
    this.productId = '',
    this.productName = '',
    this.unit = '',
    this.quantity = 0,
    this.unitPrice = 0,
  });

  double get total => double.parse((quantity * unitPrice).toStringAsFixed(2));

  factory InvoiceLine.fromJson(Map<String, dynamic> json) => InvoiceLine(
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? '',
        unit: json['unit'] ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'unit': unit,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}
