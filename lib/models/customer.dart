import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  String name;
  String activity;
  String address;
  String phone;
  String commercialRegister;
  String taxId;

  Customer({
    String? id,
    this.name = '',
    this.activity = '',
    this.address = '',
    this.phone = '',
    this.commercialRegister = '',
    this.taxId = '',
  }) : id = id ?? const Uuid().v4();

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String?,
        name: json['name'] ?? '',
        activity: json['activity'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        commercialRegister: json['commercialRegister'] ?? '',
        taxId: json['taxId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'activity': activity,
        'address': address,
        'phone': phone,
        'commercialRegister': commercialRegister,
        'taxId': taxId,
      };
}
