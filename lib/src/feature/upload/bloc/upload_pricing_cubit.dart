import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/upload_repository.dart';
import '../model/upload_pricing_model.dart';

part 'upload_pricing_state.dart';

class UploadPricingCubit extends Cubit<UploadPricingState> {
  UploadPricingCubit({required this.uploadRepository}) : super(const UploadPricingState());

  final IUploadRepository uploadRepository;

  Future<void> fetchPricing() async {
    emit(state.copyWith(status: StateStatus.loading));
    try {
      final pricing = await uploadRepository.getPricing();
      emit(state.copyWith(status: StateStatus.success, pricing: pricing));
    } on Object catch (e, s) {
      info('FETCH PRICING CUBIT ERROR: $e $s');
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }
}
