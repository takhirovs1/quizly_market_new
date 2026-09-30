enum PaymentProvider {
  payme('payme'),
  click('click'),
  wallet('wallet');

  const PaymentProvider(this.value);

  final String value;

  static PaymentProvider fromValue(String? value, {PaymentProvider fallback = PaymentProvider.payme}) =>
      switch (value?.toLowerCase()) {
        'payme' => payme,
        'click' => click,
        'wallet' => wallet,
        _ => fallback,
      };
}

enum TestMode {
  custom('custom'),
  university('university');

  const TestMode(this.value);

  final String value;

  static TestMode fromValue(String? value, {TestMode fallback = TestMode.custom}) => switch (value?.toLowerCase()) {
    'custom' => custom,
    'university' => university,
    _ => fallback,
  };
}

enum TransactionDisplayType { payme, click, referral, premium, other }
