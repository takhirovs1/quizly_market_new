import 'package:equatable/equatable.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/models/test_model.dart';
import '../data/recommendation_repository.dart';

part 'recommendation_state.dart';

class RecommendationCubit extends SequentialCubit<RecommendationState> {
  RecommendationCubit({required this.recommendationRepository}) : super(const RecommendationState());

  final IRecommendationRepository recommendationRepository;

  Future<void> initialize({String? search, int limit = 20}) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading, search: search ?? ''));
      final results = await Future.wait([
        recommendationRepository.getRecommendationTests(TestModelRequest(limit: 5, offset: 0, search: search)),
        recommendationRepository.getLikedTests(TestModelRequest(limit: 5, offset: 0, search: search)),
        recommendationRepository.getAllTests(TestModelRequest(limit: limit, offset: 0, search: search)),
      ]);
      final recResult = results[0];
      final likedResult = results[1];
      final allResult = results[2];
      emit(
        state.copyWith(
          status: .success,
          recommendations: recResult.items,
          recommendationsOffset: recResult.offset,
          recommendationsLimit: recResult.limit,
          recommendationsTotal: recResult.total,
          liked: likedResult.items,
          likedOffset: likedResult.offset,
          likedLimit: likedResult.limit,
          likedTotal: likedResult.total,
          allTests: allResult.items,
          allTestsOffset: allResult.offset,
          allTestsLimit: allResult.limit,
          allTestsTotal: allResult.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getRecommendationTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.recommendations.length >= state.recommendationsTotal) return;
        final nextOffset = state.recommendationsOffset + state.recommendationsLimit;
        final result = await recommendationRepository.getRecommendationTests(
          TestModelRequest(
            limit: state.recommendationsLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
        emit(
          state.copyWith(
            recommendations: [...state.recommendations, ...result.items],
            recommendationsOffset: result.offset,
            recommendationsLimit: result.limit,
            recommendationsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: .loading, search: currentSearch));
        final result = await recommendationRepository.getRecommendationTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
        emit(
          state.copyWith(
            status: .success,
            recommendations: result.items,
            recommendationsOffset: result.offset,
            recommendationsLimit: result.limit,
            recommendationsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getLikedTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.liked.length >= state.likedTotal) return;
        final nextOffset = state.likedOffset + state.likedLimit;
        final result = await recommendationRepository.getLikedTests(
          TestModelRequest(
            limit: state.likedLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
        emit(
          state.copyWith(
            liked: [...state.liked, ...result.items],
            likedOffset: result.offset,
            likedLimit: result.limit,
            likedTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: StateStatus.loading, search: currentSearch));
        final result = await recommendationRepository.getLikedTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
        emit(
          state.copyWith(
            status: StateStatus.success,
            liked: result.items,
            likedOffset: result.offset,
            likedLimit: result.limit,
            likedTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getAllTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.allTests.length >= state.allTestsTotal || state.isAllTestsLoadingMore) return;
        emit(state.copyWith(isAllTestsLoadingMore: true));
        final nextOffset = state.allTestsOffset + state.allTestsLimit;
        final result = await recommendationRepository.getAllTests(
          TestModelRequest(
            limit: state.allTestsLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
        emit(
          state.copyWith(
            isAllTestsLoadingMore: false,
            allTests: [...state.allTests, ...result.items],
            allTestsOffset: result.offset,
            allTestsLimit: result.limit,
            allTestsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: StateStatus.loading, search: currentSearch));
        final result = await recommendationRepository.getAllTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
        emit(
          state.copyWith(
            status: StateStatus.success,
            allTests: result.items,
            allTestsOffset: result.offset,
            allTestsLimit: result.limit,
            allTestsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          isAllTestsLoadingMore: false,
          errorMessage: ErrorUtil.toUserFriendlyMessage(error),
        ),
      );
    },
  );

  Future<void> toggleLikeTest(TestModel test) => handle<void>(
    (emit) async {
      final testId = test.id;
      if (testId == null) return;

      final currentIsLiked = test.isLiked ?? false;

      final updatedRecs = state.recommendations.map((t) {
        if (t.id == testId) {
          return TestModel(
            id: t.id,
            categoryId: t.categoryId,
            createdBy: t.createdBy,
            name: t.name,
            description: t.description,
            price: t.price,
            isPurchased: t.isPurchased,
            isLiked: !currentIsLiked,
            questionCount: t.questionCount,
            likeCount: t.likeCount != null ? (currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
            categoryName: t.categoryName,
            createdAt: t.createdAt,
          );
        }
        return t;
      }).toList();

      final List<TestModel> updatedLiked;
      if (currentIsLiked) {
        updatedLiked = state.liked.where((t) => t.id != testId).toList();
      } else {
        final exists = state.liked.any((t) => t.id == testId);
        if (exists) {
          updatedLiked = state.liked.map((t) {
            if (t.id == testId) {
              return TestModel(
                id: t.id,
                categoryId: t.categoryId,
                createdBy: t.createdBy,
                name: t.name,
                description: t.description,
                price: t.price,
                isPurchased: t.isPurchased,
                isLiked: true,
                questionCount: t.questionCount,
                likeCount: t.likeCount != null ? t.likeCount! + 1 : 1,
                categoryName: t.categoryName,
                createdAt: t.createdAt,
              );
            }
            return t;
          }).toList();
        } else {
          final original = state.recommendations.firstWhere(
            (t) => t.id == testId,
            orElse: () => state.allTests.firstWhere((t) => t.id == testId, orElse: () => test),
          );
          final newLiked = TestModel(
            id: original.id,
            categoryId: original.categoryId,
            createdBy: original.createdBy,
            name: original.name,
            description: original.description,
            price: original.price,
            isPurchased: original.isPurchased,
            isLiked: true,
            questionCount: original.questionCount,
            likeCount: original.likeCount != null ? original.likeCount! + 1 : 1,
            categoryName: original.categoryName,
            createdAt: original.createdAt,
          );
          updatedLiked = [newLiked, ...state.liked];
        }
      }

      final updatedAll = state.allTests.map((t) {
        if (t.id == testId) {
          return TestModel(
            id: t.id,
            categoryId: t.categoryId,
            createdBy: t.createdBy,
            name: t.name,
            description: t.description,
            price: t.price,
            isPurchased: t.isPurchased,
            isLiked: !currentIsLiked,
            questionCount: t.questionCount,
            likeCount: t.likeCount != null ? (currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
            categoryName: t.categoryName,
            createdAt: t.createdAt,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(recommendations: updatedRecs, liked: updatedLiked, allTests: updatedAll));

      if (currentIsLiked) {
        await recommendationRepository.unlikeTest(testId);
      } else {
        await recommendationRepository.likeTest(testId);
      }
    },
    errorHandler: (emit, error, stackTrace) {
      final testId = test.id;
      if (testId == null) return;
      final currentIsLiked = test.isLiked ?? false;

      final updatedRecs = state.recommendations.map((t) {
        if (t.id == testId) {
          return TestModel(
            id: t.id,
            categoryId: t.categoryId,
            createdBy: t.createdBy,
            name: t.name,
            description: t.description,
            price: t.price,
            isPurchased: t.isPurchased,
            isLiked: currentIsLiked,
            questionCount: t.questionCount,
            likeCount: t.likeCount != null ? (!currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
            categoryName: t.categoryName,
            createdAt: t.createdAt,
          );
        }
        return t;
      }).toList();

      final List<TestModel> updatedLiked;
      if (currentIsLiked) {
        final exists = state.liked.any((t) => t.id == testId);
        if (exists) {
          updatedLiked = state.liked.map((t) {
            if (t.id == testId) {
              return TestModel(
                id: t.id,
                categoryId: t.categoryId,
                createdBy: t.createdBy,
                name: t.name,
                description: t.description,
                price: t.price,
                isPurchased: t.isPurchased,
                isLiked: true,
                questionCount: t.questionCount,
                likeCount: test.likeCount,
                categoryName: t.categoryName,
                createdAt: t.createdAt,
              );
            }
            return t;
          }).toList();
        } else {
          final reverted = TestModel(
            id: test.id,
            categoryId: test.categoryId,
            createdBy: test.createdBy,
            name: test.name,
            description: test.description,
            price: test.price,
            isPurchased: test.isPurchased,
            isLiked: true,
            questionCount: test.questionCount,
            likeCount: test.likeCount,
            categoryName: test.categoryName,
            createdAt: test.createdAt,
          );
          updatedLiked = [reverted, ...state.liked];
        }
      } else {
        updatedLiked = state.liked.where((t) => t.id != testId).toList();
      }

      final updatedAll = state.allTests.map((t) {
        if (t.id == testId) {
          return TestModel(
            id: t.id,
            categoryId: t.categoryId,
            createdBy: t.createdBy,
            name: t.name,
            description: t.description,
            price: t.price,
            isPurchased: t.isPurchased,
            isLiked: currentIsLiked,
            questionCount: t.questionCount,
            likeCount: t.likeCount != null ? (!currentIsLiked ? t.likeCount! - 1 : t.likeCount! + 1) : null,
            categoryName: t.categoryName,
            createdAt: t.createdAt,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(recommendations: updatedRecs, liked: updatedLiked, allTests: updatedAll));
    },
  );
}
