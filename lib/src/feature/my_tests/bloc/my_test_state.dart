part of 'my_test_cubit.dart';

class MyTestState extends Equatable {
  const MyTestState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.search = '',
    this.myTests = const [],
    this.myTestsLimit = 20,
    this.myTestsOffset = 0,
    this.myTestsTotal = 0,
    this.isMyTestsLoadingMore = false,
    this.topTests = const [],
    this.topTestsLimit = 20,
    this.topTestsOffset = 0,
    this.topTestsTotal = 0,
    this.isTopTestsLoadingMore = false,
    this.demoTestStatus = StateStatus.idle,
    this.demoTestDetail,
    this.demoTestErrorMessage,
    this.walletStatus = StateStatus.idle,
    this.walletData,
    this.walletErrorMessage,
    this.purchaseStatus = StateStatus.idle,
    this.purchaseData,
    this.purchaseErrorMessage,
    this.exampleTestDetail,
    // --- Home sections (parallel, independent per-section status) ---
    this.statuses = const <String, StateStatus>{},
    this.sectionErrors = const <String, String?>{},
    this.continueResponse,
    this.homeActions,
    this.myTestsPreview,
    this.homeActivity,
    this.friendsRating,
    this.referralSummary,
    this.adsResponse,
    this.recommendations,
    this.dismissedAdIds = const <String>{},
  });

  final StateStatus status;
  final String? errorMessage;
  final String search;
  final List<TestModel> myTests;
  final int myTestsLimit;
  final int myTestsOffset;
  final int myTestsTotal;
  final bool isMyTestsLoadingMore;
  final List<TestModel> topTests;
  final int topTestsLimit;
  final int topTestsOffset;
  final int topTestsTotal;
  final bool isTopTestsLoadingMore;
  final StateStatus demoTestStatus;
  final DemoTestDetail? demoTestDetail;
  final String? demoTestErrorMessage;
  final StateStatus walletStatus;
  final WalletData? walletData;
  final String? walletErrorMessage;
  final StateStatus purchaseStatus;
  final TestPurchaseData? purchaseData;
  final String? purchaseErrorMessage;
  final DemoTestDetail? exampleTestDetail;

  // --- Home sections ---------------------------------------------------------
  /// Per-section load status, keyed by [HomeEndpoints] ('continue', 'actions',
  /// 'myTests', 'activity', 'friends', 'referral', 'ads', 'recommendations').
  final Map<String, StateStatus> statuses;

  /// Per-section user-friendly error message (same keys as [statuses]).
  final Map<String, String?> sectionErrors;

  final HomeContinueResponse? continueResponse;
  final HomeActionsResponse? homeActions;
  final MyTestsPreviewResponse? myTestsPreview;
  final HomeActivityResponse? homeActivity;
  final FriendsRatingResponse? friendsRating;
  final ReferralSummaryResponse? referralSummary;
  final AdsResponse? adsResponse;
  final RecommendationsResponse? recommendations;

  /// Ad ids the user dismissed this session (server also persists via /dismiss).
  final Set<String> dismissedAdIds;

  /// Status for a Home section; defaults to idle when not yet requested.
  StateStatus statusOf(String key) => statuses[key] ?? StateStatus.idle;

  /// Error message for a Home section (null when none).
  String? sectionError(String key) => sectionErrors[key];

  /// The Continue hero card payload (null when 204 / no in-progress session).
  ContinueCardData? get continueCard => continueResponse?.data;

  /// Active ads with locally-dismissed ones removed.
  List<AdItem> get visibleAds =>
      (adsResponse?.items ?? const <AdItem>[]).where((ad) => !dismissedAdIds.contains(ad.id)).toList();

  /// Returns a copy with one section's [status] (and optional [error]) updated.
  MyTestState copyWithStatus(String key, StateStatus status, {String? error}) => copyWith(
    statuses: <String, StateStatus>{...statuses, key: status},
    sectionErrors: <String, String?>{...sectionErrors, key: error},
  );

  MyTestState copyWith({
    StateStatus? status,
    String? errorMessage,
    String? search,
    List<TestModel>? myTests,
    int? myTestsLimit,
    int? myTestsOffset,
    int? myTestsTotal,
    bool? isMyTestsLoadingMore,
    List<TestModel>? topTests,
    int? topTestsLimit,
    int? topTestsOffset,
    int? topTestsTotal,
    bool? isTopTestsLoadingMore,
    StateStatus? demoTestStatus,
    DemoTestDetail? demoTestDetail,
    String? demoTestErrorMessage,
    StateStatus? walletStatus,
    WalletData? walletData,
    String? walletErrorMessage,
    StateStatus? purchaseStatus,
    TestPurchaseData? purchaseData,
    String? purchaseErrorMessage,
    DemoTestDetail? exampleTestDetail,
    Map<String, StateStatus>? statuses,
    Map<String, String?>? sectionErrors,
    HomeContinueResponse? continueResponse,
    HomeActionsResponse? homeActions,
    MyTestsPreviewResponse? myTestsPreview,
    HomeActivityResponse? homeActivity,
    FriendsRatingResponse? friendsRating,
    ReferralSummaryResponse? referralSummary,
    AdsResponse? adsResponse,
    RecommendationsResponse? recommendations,
    Set<String>? dismissedAdIds,
  }) => MyTestState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    search: search ?? this.search,
    myTests: myTests ?? this.myTests,
    myTestsLimit: myTestsLimit ?? this.myTestsLimit,
    myTestsOffset: myTestsOffset ?? this.myTestsOffset,
    myTestsTotal: myTestsTotal ?? this.myTestsTotal,
    isMyTestsLoadingMore: isMyTestsLoadingMore ?? this.isMyTestsLoadingMore,
    topTests: topTests ?? this.topTests,
    topTestsLimit: topTestsLimit ?? this.topTestsLimit,
    topTestsOffset: topTestsOffset ?? this.topTestsOffset,
    topTestsTotal: topTestsTotal ?? this.topTestsTotal,
    isTopTestsLoadingMore: isTopTestsLoadingMore ?? this.isTopTestsLoadingMore,
    demoTestStatus: demoTestStatus ?? this.demoTestStatus,
    demoTestDetail: demoTestDetail ?? this.demoTestDetail,
    demoTestErrorMessage: demoTestErrorMessage ?? this.demoTestErrorMessage,
    walletStatus: walletStatus ?? this.walletStatus,
    walletData: walletData ?? this.walletData,
    walletErrorMessage: walletErrorMessage ?? this.walletErrorMessage,
    purchaseStatus: purchaseStatus ?? this.purchaseStatus,
    purchaseData: purchaseData ?? this.purchaseData,
    purchaseErrorMessage: purchaseErrorMessage ?? this.purchaseErrorMessage,
    exampleTestDetail: exampleTestDetail ?? this.exampleTestDetail,
    statuses: statuses ?? this.statuses,
    sectionErrors: sectionErrors ?? this.sectionErrors,
    continueResponse: continueResponse ?? this.continueResponse,
    homeActions: homeActions ?? this.homeActions,
    myTestsPreview: myTestsPreview ?? this.myTestsPreview,
    homeActivity: homeActivity ?? this.homeActivity,
    friendsRating: friendsRating ?? this.friendsRating,
    referralSummary: referralSummary ?? this.referralSummary,
    adsResponse: adsResponse ?? this.adsResponse,
    recommendations: recommendations ?? this.recommendations,
    dismissedAdIds: dismissedAdIds ?? this.dismissedAdIds,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    search,
    myTests,
    myTestsLimit,
    myTestsOffset,
    myTestsTotal,
    isMyTestsLoadingMore,
    topTests,
    topTestsLimit,
    topTestsOffset,
    topTestsTotal,
    isTopTestsLoadingMore,
    demoTestStatus,
    demoTestDetail,
    demoTestErrorMessage,
    walletStatus,
    walletData,
    walletErrorMessage,
    purchaseStatus,
    purchaseData,
    purchaseErrorMessage,
    exampleTestDetail,
    statuses,
    sectionErrors,
    continueResponse,
    homeActions,
    myTestsPreview,
    homeActivity,
    friendsRating,
    referralSummary,
    adsResponse,
    recommendations,
    dismissedAdIds,
  ];
}
