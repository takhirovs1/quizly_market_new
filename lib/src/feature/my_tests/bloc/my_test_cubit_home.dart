part of 'my_test_cubit.dart';

/// Home-screen section loaders, split out of [MyTestCubit] so the purchase/demo
/// logic stays readable. Each section is an independent endpoint with its own
/// status key ([HomeEndpoints]); they load in parallel and fail independently.
mixin MyTestCubitHome on SequentialCubit<MyTestState> {
  /// Repository for the Home sections — provided by [MyTestCubit].
  IHomeRepository get homeRepository;

  /// Repository for test actions (like/unlike) — provided by [MyTestCubit].
  IMyTestRepository get myTestRepository;

  /// Loads every Home section in parallel. One failing section only flips its
  /// own status to error — the others still render (Figma A5 partial-error).
  Future<void> loadHome() => handle<void>((emit) async {
    emit(
      state.copyWith(
        statuses: <String, StateStatus>{for (final key in HomeEndpoints.all) key: StateStatus.loading},
        sectionErrors: const <String, String?>{},
      ),
    );
    await Future.wait<void>(<Future<void>>[
      _loadSection(
        emit,
        HomeEndpoints.continueCard,
        () => homeRepository.getContinue(const HomeContinueRequest()),
        (s, r) => s.copyWith(continueResponse: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.actions,
        () => homeRepository.getActions(const HomeActionsRequest()),
        (s, r) => s.copyWith(homeActions: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.myTests,
        () => homeRepository.getMyTestsPreview(const MyTestsPreviewRequest(limit: 3)),
        (s, r) => s.copyWith(myTestsPreview: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.activity,
        () => homeRepository.getActivity(const HomeActivityRequest()),
        (s, r) => s.copyWith(homeActivity: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.friends,
        () => homeRepository.getFriendsRating(const FriendsRatingRequest()),
        (s, r) => s.copyWith(friendsRating: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.referral,
        () => homeRepository.getReferralSummary(const ReferralSummaryRequest()),
        (s, r) => s.copyWith(referralSummary: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.ads,
        () => homeRepository.getAds(const AdsRequest()),
        (s, r) => s.copyWith(adsResponse: r),
      ),
      _loadSection(
        emit,
        HomeEndpoints.recommendations,
        () => homeRepository.getRecommendations(const RecommendationsRequest()),
        (s, r) => s.copyWith(recommendations: r),
      ),
    ]);
  });

  /// Fetch one section, emitting loading→success/error on its own key without
  /// touching the other sections' statuses or data.
  Future<void> _loadSection<T>(
    void Function(MyTestState state) emit,
    String key,
    Future<T> Function() fetch,
    MyTestState Function(MyTestState state, T data) apply,
  ) async {
    try {
      final data = await fetch();
      emit(apply(state, data).copyWithStatus(key, StateStatus.success));
    } on Object catch (error) {
      emit(state.copyWithStatus(key, StateStatus.error, error: ErrorUtil.toUserFriendlyMessage(error)));
    }
  }

  /// Retry a single failed section (the "Qayta urinish" button).
  Future<void> retrySection(String key) {
    switch (key) {
      case HomeEndpoints.continueCard:
        return _reloadSection(
          key,
          () => homeRepository.getContinue(const HomeContinueRequest()),
          (s, r) => s.copyWith(continueResponse: r),
        );
      case HomeEndpoints.actions:
        return _reloadSection(
          key,
          () => homeRepository.getActions(const HomeActionsRequest()),
          (s, r) => s.copyWith(homeActions: r),
        );
      case HomeEndpoints.myTests:
        return _reloadSection(
          key,
          () => homeRepository.getMyTestsPreview(const MyTestsPreviewRequest(limit: 3)),
          (s, r) => s.copyWith(myTestsPreview: r),
        );
      case HomeEndpoints.activity:
        return _reloadSection(
          key,
          () => homeRepository.getActivity(const HomeActivityRequest()),
          (s, r) => s.copyWith(homeActivity: r),
        );
      case HomeEndpoints.friends:
        return _reloadSection(
          key,
          () => homeRepository.getFriendsRating(const FriendsRatingRequest()),
          (s, r) => s.copyWith(friendsRating: r),
        );
      case HomeEndpoints.referral:
        return _reloadSection(
          key,
          () => homeRepository.getReferralSummary(const ReferralSummaryRequest()),
          (s, r) => s.copyWith(referralSummary: r),
        );
      case HomeEndpoints.ads:
        return _reloadSection(
          key,
          () => homeRepository.getAds(const AdsRequest()),
          (s, r) => s.copyWith(adsResponse: r),
        );
      case HomeEndpoints.recommendations:
        return _reloadSection(
          key,
          () => homeRepository.getRecommendations(const RecommendationsRequest()),
          (s, r) => s.copyWith(recommendations: r),
        );
    }
    return Future<void>.value();
  }

  Future<void> _reloadSection<T>(
    String key,
    Future<T> Function() fetch,
    MyTestState Function(MyTestState state, T data) apply,
  ) => handle<void>(
    (emit) async {
      emit(state.copyWithStatus(key, StateStatus.loading));
      final data = await fetch();
      emit(apply(state, data).copyWithStatus(key, StateStatus.success));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWithStatus(key, StateStatus.error, error: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  /// Claim one referred friend's bonus (idempotent on the server). Marks that
  /// friend `claimed` locally and returns the server reward text for a toast.
  /// Stays in `success` (optimistic) so the card never flashes a full-section
  /// spinner for a single-row action.
  Future<String?> claimReferralFriend(String friendId) => handle<String?>(
    (emit) async {
      final summary = state.referralSummary;
      if (summary == null) return null;
      final response = await homeRepository.claimReferralFriend(ReferralClaimRequest(friendId: friendId));
      final updated = summary.friends.map((f) => f.id == friendId ? f.copyWith(claimed: true) : f).toList();
      final unclaimed = updated.where((f) => f.claimable && !f.claimed).length;
      emit(
        state
            .copyWith(
              referralSummary: summary.copyWith(friends: updated, unclaimedCount: unclaimed),
            )
            .copyWithStatus(HomeEndpoints.referral, StateStatus.success),
      );
      return response.rewardText;
    },
    errorHandler: (emit, error, stackTrace) {
      emit(
        state.copyWithStatus(HomeEndpoints.referral, StateStatus.error, error: ErrorUtil.toUserFriendlyMessage(error)),
      );
      return null;
    },
  );

  /// Hide an ad locally (optimistic) and tell the server (persists for 24h).
  Future<void> dismissAd(String adId) => handle<void>((emit) async {
    emit(state.copyWith(dismissedAdIds: <String>{...state.dismissedAdIds, adId}));
    await homeRepository.dismissAd(AdDismissRequest(adId: adId));
  });

  /// Fire-and-forget sponsor telemetry.
  Future<void> trackAdImpression(String adId) => homeRepository.trackAdImpression(AdImpressionRequest(adId: adId));

  Future<void> trackAdClick(String adId) => homeRepository.trackAdClick(AdClickRequest(adId: adId));

  /// Optimistic favorite toggle on a recommendation card.
  /// Calls POST/DELETE /api/tests/:id/like; reverts on error.
  Future<void> toggleRecommendationFavorite(String testId) => handle<void>(
    (emit) async {
      final current = state.recommendations;
      if (current == null) return;
      final item = current.items.firstWhere((i) => i.testId == testId, orElse: () => throw StateError('not found'));
      final wasFavorite = item.isFavorite;
      final updated = current.items.map((i) => i.testId == testId ? i.copyWith(isFavorite: !wasFavorite) : i).toList();
      emit(state.copyWith(recommendations: current.copyWith(items: updated)));
      if (wasFavorite) {
        await myTestRepository.unlikeTest(testId);
      } else {
        await myTestRepository.likeTest(testId);
      }
    },
    errorHandler: (emit, error, stackTrace) {
      final current = state.recommendations;
      if (current == null) return;
      final reverted = current.items.map((i) {
        if (i.testId != testId) return i;
        return i.copyWith(isFavorite: !i.isFavorite);
      }).toList();
      emit(state.copyWith(recommendations: current.copyWith(items: reverted)));
    },
  );
}
