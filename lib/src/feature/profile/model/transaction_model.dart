import '../../../common/extension/number_extension.dart';
import '../../../common/extension/string_extension.dart';

class TransactionRequest {
  const TransactionRequest({this.limit = 20, this.offset = 0});

  final int limit;
  final int offset;

  Map<String, Object?> toJson() => {'limit': limit, 'offset': offset};
}

class TransactionResponse {
  const TransactionResponse({required this.items, required this.limit, required this.offset, required this.total});

  factory TransactionResponse.fromJson(Map<String, Object?> json) {
    final list = json['data'] as List<Object?>? ?? [];
    return TransactionResponse(
      items: list.map((e) => Transaction.fromJson(e as Map<String, Object?>)).toList(),
      limit: json['limit'].toIntOrNull ?? 20,
      offset: json['offset'].toIntOrNull ?? 0,
      total: json['total'].toIntOrNull ?? 0,
    );
  }

  final List<Transaction> items;
  final int limit;
  final int offset;
  final int total;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, Object?> json) => Transaction(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? json['name'] as String? ?? '',
    amount: json['amount'].toIntOrNull ?? 0,
    type: json['type'] as String? ?? '',
    createdAt: json['created_at'].toDateTimeOrNull ?? DateTime.now(),
  );

  final String id;
  final String title;
  final int amount;
  final String type;
  final DateTime createdAt;
}
