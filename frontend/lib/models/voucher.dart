class Voucher {
  final int id;
  final String name;
  final String? code;
  final String type;
  final double value;
  final double minPurchase;
  final String? expiredDate;

  Voucher({
    required this.id,
    required this.name,
    this.code,
    required this.type,
    required this.value,
    required this.minPurchase,
    this.expiredDate,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      type: json['type'],
      value: double.parse(json['value'].toString()),
      minPurchase: double.parse(json['min_purchase'].toString()),
      expiredDate: json['expired_date'],
    );
  }
}
