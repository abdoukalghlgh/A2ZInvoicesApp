class CompanyInfo {
  String name;
  String activity;
  String address;
  String commercialRegister;
  String taxId;
  String articleNumber;
  String phone;

  CompanyInfo({
    this.name = '',
    this.activity = '',
    this.address = '',
    this.commercialRegister = '',
    this.taxId = '',
    this.articleNumber = '',
    this.phone = '',
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        name: json['name'] ?? '',
        activity: json['activity'] ?? '',
        address: json['address'] ?? '',
        commercialRegister: json['commercialRegister'] ?? '',
        taxId: json['taxId'] ?? '',
        articleNumber: json['articleNumber'] ?? '',
        phone: json['phone'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'activity': activity,
        'address': address,
        'commercialRegister': commercialRegister,
        'taxId': taxId,
        'articleNumber': articleNumber,
        'phone': phone,
      };
}
