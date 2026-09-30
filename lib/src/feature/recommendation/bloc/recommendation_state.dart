part of 'recommendation_cubit.dart';

class RecommendationState extends Equatable {
  const RecommendationState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.search = '',
    this.recommendations = const [],
    this.recommendationsLimit = 20,
    this.recommendationsOffset = 0,
    this.recommendationsTotal = 0,
    this.liked = const [],
    this.likedLimit = 20,
    this.likedOffset = 0,
    this.likedTotal = 0,
    this.allTests = const [],
    this.allTestsLimit = 20,
    this.allTestsOffset = 0,
    this.allTestsTotal = 0,
    this.isAllTestsLoadingMore = false,
  });

  final StateStatus status;
  final String? errorMessage;
  final String search;
  final List<TestModel> recommendations;
  final int recommendationsLimit;
  final int recommendationsOffset;
  final int recommendationsTotal;
  final List<TestModel> liked;
  final int likedLimit;
  final int likedOffset;
  final int likedTotal;
  final List<TestModel> allTests;
  final int allTestsLimit;
  final int allTestsOffset;
  final int allTestsTotal;
  final bool isAllTestsLoadingMore;

  RecommendationState copyWith({
    StateStatus? status,
    String? errorMessage,
    String? search,
    List<TestModel>? recommendations,
    int? recommendationsLimit,
    int? recommendationsOffset,
    int? recommendationsTotal,
    List<TestModel>? liked,
    int? likedLimit,
    int? likedOffset,
    int? likedTotal,
    List<TestModel>? allTests,
    int? allTestsLimit,
    int? allTestsOffset,
    int? allTestsTotal,
    bool? isAllTestsLoadingMore,
  }) => RecommendationState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    search: search ?? this.search,
    recommendations: recommendations ?? this.recommendations,
    recommendationsLimit: recommendationsLimit ?? this.recommendationsLimit,
    recommendationsOffset: recommendationsOffset ?? this.recommendationsOffset,
    recommendationsTotal: recommendationsTotal ?? this.recommendationsTotal,
    liked: liked ?? this.liked,
    likedLimit: likedLimit ?? this.likedLimit,
    likedOffset: likedOffset ?? this.likedOffset,
    likedTotal: likedTotal ?? this.likedTotal,
    allTests: allTests ?? this.allTests,
    allTestsLimit: allTestsLimit ?? this.allTestsLimit,
    allTestsOffset: allTestsOffset ?? this.allTestsOffset,
    allTestsTotal: allTestsTotal ?? this.allTestsTotal,
    isAllTestsLoadingMore: isAllTestsLoadingMore ?? this.isAllTestsLoadingMore,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    search,
    recommendations,
    recommendationsLimit,
    recommendationsOffset,
    recommendationsTotal,
    liked,
    likedLimit,
    likedOffset,
    likedTotal,
    allTests,
    allTestsLimit,
    allTestsOffset,
    allTestsTotal,
    isAllTestsLoadingMore,
  ];
}
