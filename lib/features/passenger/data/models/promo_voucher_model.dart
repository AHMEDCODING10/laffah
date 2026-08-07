class PromoVoucherModel {
  final String id;
  final String code;
  final String discountTitle;
  final String description;
  final String discountAmount;
  final String expiryDate;

  PromoVoucherModel({
    required this.id,
    required this.code,
    required this.discountTitle,
    required this.description,
    required this.discountAmount,
    required this.expiryDate,
  });

  factory PromoVoucherModel.fromJson(Map<String, dynamic> json) {
    return PromoVoucherModel(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      discountTitle: json['discountTitle'] ?? '',
      description: json['description'] ?? '',
      discountAmount: json['discount_amount'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
    );
  }
}
