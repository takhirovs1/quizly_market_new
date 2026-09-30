part of 'upload_pricing_cubit.dart';

class UploadPricingState extends Equatable {
  const UploadPricingState({
    this.status = StateStatus.idle,
    this.pricing = const UploadPricingModel(),
    this.errorMessage,
  });

  final StateStatus status;
  final UploadPricingModel pricing;
  final String? errorMessage;

  UploadPricingState copyWith({StateStatus? status, UploadPricingModel? pricing, String? errorMessage}) =>
      UploadPricingState(status: status ?? this.status, pricing: pricing ?? this.pricing, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, pricing, errorMessage];
}
