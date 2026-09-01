part of 'upload_confirm_cubit.dart';

class UploadConfirmCubitState extends Equatable {
  const UploadConfirmCubitState({
    this.quoteStatus = StateStatus.idle,
    this.publishStatus = StateStatus.idle,
    this.quote,
    this.walletResult,
    this.checkoutResult,
    this.isInsufficientBalance = false,
    this.isPaymentFailed = false,
    this.errorMessage,
  });

  final StateStatus quoteStatus;
  final StateStatus publishStatus;
  final PublishQuoteModel? quote;
  final PublishWalletResponse? walletResult;
  final PublishCheckoutResponse? checkoutResult;
  final bool isInsufficientBalance;
  final bool isPaymentFailed;
  final String? errorMessage;

  UploadConfirmCubitState copyWith({
    StateStatus? quoteStatus,
    StateStatus? publishStatus,
    PublishQuoteModel? quote,
    PublishWalletResponse? walletResult,
    PublishCheckoutResponse? checkoutResult,
    bool? isInsufficientBalance,
    bool? isPaymentFailed,
    String? errorMessage,
  }) => UploadConfirmCubitState(
    quoteStatus: quoteStatus ?? this.quoteStatus,
    publishStatus: publishStatus ?? this.publishStatus,
    quote: quote ?? this.quote,
    walletResult: walletResult ?? this.walletResult,
    checkoutResult: checkoutResult ?? this.checkoutResult,
    isInsufficientBalance: isInsufficientBalance ?? this.isInsufficientBalance,
    isPaymentFailed: isPaymentFailed ?? this.isPaymentFailed,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    quoteStatus,
    publishStatus,
    quote,
    walletResult,
    checkoutResult,
    isInsufficientBalance,
    isPaymentFailed,
    errorMessage,
  ];
}
