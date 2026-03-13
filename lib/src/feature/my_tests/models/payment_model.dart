class PaymentModel {
  PaymentModel({required this.id, required this.title, required this.type, this.subtitle, this.icon});
  final int id;
  final String title;
  final String? subtitle;
  final String? icon;
  final PaymentType type;
}

enum PaymentType { card, provider }
