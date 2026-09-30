part of 'upload_confirm_cubit.dart';

class UploadConfirmCubitState extends Equatable {
  const UploadConfirmCubitState({
    this.quoteStatus = StateStatus.idle,
    this.publishStatus = StateStatus.idle,
    this.priceUpdateStatus = StateStatus.idle,
    this.quote,
    this.walletResult,
    this.checkoutResult,
    this.salePrice,
    this.isInsufficientBalance = false,
    this.isPaymentFailed = false,
    this.errorMessage,
  });

  final StateStatus quoteStatus;
  final StateStatus publishStatus;

  /// Status of the sale-price edit (`PUT /api/tests/:id`).
  final StateStatus priceUpdateStatus;
  final PublishQuoteModel? quote;
  final PublishWalletResponse? walletResult;
  final PublishCheckoutResponse? checkoutResult;

  /// Current sale price ("Test narxi") the buyers pay, editable on this screen.
  final int? salePrice;
  final bool isInsufficientBalance;
  final bool isPaymentFailed;
  final String? errorMessage;

  UploadConfirmCubitState copyWith({
    StateStatus? quoteStatus,
    StateStatus? publishStatus,
    StateStatus? priceUpdateStatus,
    PublishQuoteModel? quote,
    PublishWalletResponse? walletResult,
    PublishCheckoutResponse? checkoutResult,
    int? salePrice,
    bool? isInsufficientBalance,
    bool? isPaymentFailed,
    String? errorMessage,
  }) => UploadConfirmCubitState(
    quoteStatus: quoteStatus ?? this.quoteStatus,
    publishStatus: publishStatus ?? this.publishStatus,
    priceUpdateStatus: priceUpdateStatus ?? this.priceUpdateStatus,
    quote: quote ?? this.quote,
    walletResult: walletResult ?? this.walletResult,
    checkoutResult: checkoutResult ?? this.checkoutResult,
    salePrice: salePrice ?? this.salePrice,
    isInsufficientBalance: isInsufficientBalance ?? this.isInsufficientBalance,
    isPaymentFailed: isPaymentFailed ?? this.isPaymentFailed,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    quoteStatus,
    publishStatus,
    priceUpdateStatus,
    quote,
    walletResult,
    checkoutResult,
    salePrice,
    isInsufficientBalance,
    isPaymentFailed,
    errorMessage,
  ];
}
