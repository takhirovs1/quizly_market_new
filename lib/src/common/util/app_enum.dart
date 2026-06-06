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
