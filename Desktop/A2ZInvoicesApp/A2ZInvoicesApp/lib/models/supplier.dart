import 'package:uuid/uuid.dart';

class Supplier {
  final String id;
  String name;
  String activity;
  String address;
  String phone;

  Supplier({
    String? id,
    this.name = '',
    this.activity = '',
    this.address = '',
    this.phone = '',
  }) : id = id ?? const Uuid().v4();

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as String?,
        name: json['name'] ?? '',
        activity: json['activity'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'activity': activity,
        'address': address,
        'phone': phone,
      };
}
