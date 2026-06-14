import 'package:equatable/equatable.dart';

import '../../../common/util/app_enum.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/my_test_repository.dart';
import '../models/demo_test_model.dart';
import '../models/test_checkout_model.dart';
import '../models/test_model.dart';
import '../models/test_purchase_model.dart';
import '../models/wallet_model.dart';

part 'my_test_state.dart';

class MyTestCubit extends SequentialCubit<MyTestState> {
  MyTestCubit({required this.myTestRepository}) : super(const MyTestState());

  final IMyTestRepository myTestRepository;

  Future<void> initialize({String? search, int limit = 20}) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: StateStatus.loading, search: search ?? ''));
      final results = await Future.wait([
        myTestRepository.getMyTests(TestModelRequest(limit: limit, offset: 0, search: search)),
        myTestRepository.getTopTests(TestModelRequest(limit: limit, offset: 0, search: search)),
      ]);
      final myResult = results[0];
      final topResult = results[1];
      emit(
        state.copyWith(
          status: StateStatus.success,
          myTests: myResult.items,
          myTestsOffset: myResult.offset,
          myTestsLimit: myResult.limit,
          myTestsTotal: myResult.total,
          topTests: topResult.items,
          topTestsOffset: topResult.offset,
          topTestsLimit: topResult.limit,
          topTestsTotal: topResult.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getMyTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.myTests.length >= state.myTestsTotal || state.isMyTestsLoadingMore) return;
        emit(state.copyWith(isMyTestsLoadingMore: true));
        final nextOffset = state.myTestsOffset + state.myTestsLimit;
        final result = await myTestRepository.getMyTests(
          TestModelRequest(
            limit: state.myTestsLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
        emit(
          state.copyWith(
            isMyTestsLoadingMore: false,
            myTests: [...state.myTests, ...result.items],
            myTestsOffset: result.offset,
            myTestsLimit: result.limit,
            myTestsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: .loading, search: currentSearch));
        final result = await myTestRepository.getMyTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
        emit(
          state.copyWith(
            status: .success,
            myTests: result.items,
            myTestsOffset: result.offset,
            myTestsLimit: result.limit,
            myTestsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(
        state.copyWith(
          status: .error,
          isMyTestsLoadingMore: false,
          errorMessage: ErrorUtil.toUserFriendlyMessage(error),
        ),
      );
    },
  );

  Future<void> getTopTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.topTests.length >= state.topTestsTotal || state.isTopTestsLoadingMore) return;
        emit(state.copyWith(isTopTestsLoadingMore: true));
        final nextOffset = state.topTestsOffset + state.topTestsLimit;
        final result = await myTestRepository.getTopTests(
          TestModelRequest(
            limit: state.topTestsLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
        emit(
          state.copyWith(
            isTopTestsLoadingMore: false,
            topTests: [...state.topTests, ...result.items],
            topTestsOffset: result.offset,
            topTestsLimit: result.limit,
            topTestsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: .loading, search: currentSearch));
        final result = await myTestRepository.getTopTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
        emit(
          state.copyWith(
            status: .success,
            topTests: result.items,
            topTestsOffset: result.offset,
            topTestsLimit: result.limit,
            topTestsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(
        state.copyWith(
          status: .error,
          isTopTestsLoadingMore: false,
          errorMessage: ErrorUtil.toUserFriendlyMessage(error),
        ),
      );
    },
  );

  Future<void> getDemoTest(String testId) => handle<void>(
    (emit) async {
      emit(state.copyWith(demoTestStatus: .loading));
      final results = await Future.wait([
        myTestRepository.getTestDetail(DemoTestRequest(testId: testId)),
        myTestRepository.getDemoTest(DemoTestRequest(testId: testId)),
      ]);
      final detailResponse = results[0];
      final demoResponse = results[1];

      final combinedDetail = detailResponse.data?.copyWith(questions: demoResponse.data?.questions);

      emit(state.copyWith(demoTestStatus: .success, demoTestDetail: combinedDetail));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(demoTestStatus: .error, demoTestErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> toggleLike(String testId) => handle<void>(
    (emit) async {
      final detail = state.demoTestDetail;
      if (detail == null || detail.id != testId) return;

      final currentIsLiked = detail.isLiked ?? false;
      final updatedDetail = detail.copyWith(isLiked: !currentIsLiked);
      emit(state.copyWith(demoTestDetail: updatedDetail));

      if (currentIsLiked) {
        await myTestRepository.unlikeTest(testId);
      } else {
        await myTestRepository.likeTest(testId);
      }
    },
    errorHandler: (emit, error, stackTrace) {
      final detail = state.demoTestDetail;
      if (detail != null && detail.id == testId) {
        final currentIsLiked = detail.isLiked ?? false;
        final revertedDetail = detail.copyWith(isLiked: !currentIsLiked);
        emit(state.copyWith(demoTestDetail: revertedDetail));
      }
    },
  );

  Future<void> toggleLikeTest(TestModel test) => handle<void>(
    (emit) async {
      final testId = test.id;
      if (testId == null) return;

      final currentIsLiked = test.isLiked ?? false;

      final updatedMyTests = state.myTests.map((t) {
        if (t.id == testId) {
          return t.copyWith(
            isLiked: !currentIsLiked,
            likeCount: t.likeCount != null ? (currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
          );
        }
        return t;
      }).toList();

      final updatedTopTests = state.topTests.map((t) {
        if (t.id == testId) {
          return t.copyWith(
            isLiked: !currentIsLiked,
            likeCount: t.likeCount != null ? (currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
          );
        }
        return t;
      }).toList();

      final detail = state.demoTestDetail;
      final updatedDetail = (detail != null && detail.id == testId)
          ? detail.copyWith(isLiked: !currentIsLiked)
          : detail;

      emit(state.copyWith(myTests: updatedMyTests, topTests: updatedTopTests, demoTestDetail: updatedDetail));

      if (currentIsLiked) {
        await myTestRepository.unlikeTest(testId);
      } else {
        await myTestRepository.likeTest(testId);
      }
    },
    errorHandler: (emit, error, stackTrace) {
      final testId = test.id;
      if (testId == null) return;
      final currentIsLiked = test.isLiked ?? false;

      final updatedMyTests = state.myTests.map((t) {
        if (t.id == testId) {
          return t.copyWith(
            isLiked: currentIsLiked,
            likeCount: t.likeCount != null ? (!currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
          );
        }
        return t;
      }).toList();

      final updatedTopTests = state.topTests.map((t) {
        if (t.id == testId) {
          return t.copyWith(
            isLiked: currentIsLiked,
            likeCount: t.likeCount != null ? (!currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
          );
        }
        return t;
      }).toList();

      final detail = state.demoTestDetail;
      final updatedDetail = (detail != null && detail.id == testId) ? detail.copyWith(isLiked: currentIsLiked) : detail;

      emit(state.copyWith(myTests: updatedMyTests, topTests: updatedTopTests, demoTestDetail: updatedDetail));
    },
  );

  Future<void> getWallet() => handle<void>(
    (emit) async {
      emit(state.copyWith(walletStatus: StateStatus.loading));
      final response = await myTestRepository.getWallet(const WalletRequest());
      emit(state.copyWith(walletStatus: StateStatus.success, walletData: response.data));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(walletStatus: StateStatus.error, walletErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<TestPurchaseResponse?> purchaseTest(String testId) => handle<TestPurchaseResponse?>(
    (emit) async {
      emit(state.copyWith(purchaseStatus: StateStatus.loading));
      final request = TestPurchaseRequest(testId: testId);
      final response = await myTestRepository.purchaseTest(request);

      final detail = state.demoTestDetail;
      if (detail != null && detail.id == testId) {
        emit(
          state.copyWith(
            purchaseStatus: StateStatus.success,
            purchaseData: response.data,
            demoTestDetail: detail.copyWith(isPurchased: true),
          ),
        );
      } else {
        emit(state.copyWith(purchaseStatus: StateStatus.success, purchaseData: response.data));
      }
      return response;
    },
    errorHandler: (emit, error, stackTrace) {
      emit(
        state.copyWith(purchaseStatus: StateStatus.error, purchaseErrorMessage: ErrorUtil.toUserFriendlyMessage(error)),
      );
      return null;
    },
  );

  Future<TestCheckoutResponse?> checkoutTest({
    required String testId,
    required PaymentProvider provider,
    required String redirectUrl,
  }) => handle<TestCheckoutResponse?>(
    (emit) async {
      emit(state.copyWith(purchaseStatus: StateStatus.loading));
      final request = TestCheckoutRequest(provider: provider, redirectUrl: redirectUrl);
      final response = await myTestRepository.checkoutTest(testId, request);
      emit(state.copyWith(purchaseStatus: StateStatus.idle));
      return response;
    },
    errorHandler: (emit, error, stackTrace) {
      emit(
        state.copyWith(purchaseStatus: StateStatus.error, purchaseErrorMessage: ErrorUtil.toUserFriendlyMessage(error)),
      );
      return null;
    },
  );
}
