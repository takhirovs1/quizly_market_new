class WalletRequest {
  const WalletRequest();

  Map<String, Object?> toJson() => {};
}

class WalletResponse {
  const WalletResponse({this.data});

  factory WalletResponse.fromJson(Map<String, Object?> json) =>
      WalletResponse(data: json['data'] == null ? null : WalletData.fromJson(json['data'] as Map<String, Object?>));

  final WalletData? data;

  Map<String, Object?> toJson() => {'data': data?.toJson()};
}

class WalletData {
  const WalletData({this.balance});

  factory WalletData.fromJson(Map<String, Object?> json) => WalletData(balance: (json['balance'] as num?)?.toInt());

  final int? balance;

  Map<String, Object?> toJson() => {'balance': balance};
}
