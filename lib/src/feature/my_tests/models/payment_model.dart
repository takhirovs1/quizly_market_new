class PaymentModel {
  PaymentModel({required this.id, required this.title, required this.type, required this.icon, this.subtitle});
  final int id;
  final String title;
  final String? subtitle;
  final String icon;
  final PaymentType type;
}

enum PaymentType { card, provider }
