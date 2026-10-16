import '../../../common/constant/urls.dart';
import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../../tests/model/test_rating_model.dart';
import '../../tests/model/xp_rules_model.dart';
import '../models/home/ad_event_model.dart';
import '../models/home/ads_model.dart';
import '../models/home/friends_rating_model.dart';
import '../models/home/home_actions_model.dart';
import '../models/home/home_activity_model.dart';
import '../models/home/home_continue_model.dart';
import '../models/home/my_tests_filters_model.dart';
import '../models/home/my_tests_preview_model.dart';
import '../models/home/recommendations_model.dart';
import '../models/home/referral_claim_model.dart';
import '../models/home/referral_summary_model.dart';

/// Section keys for the Home screen. Each section is an independent endpoint
/// with its own status in the cubit, so one failing section never blocks the
/// others.
abstract final class HomeEndpoints {
  static const String continueCard = 'continue';
  static const String actions = 'actions';
  static const String myTests = 'myTests';
  static const String activity = 'activity';
  static const String friends = 'friends';
  static const String referral = 'referral';
  static const String ads = 'ads';
  static const String recommendations = 'recommendations';

  /// Every section key — the full set the cubit loads in parallel.
  static const Set<String> all = <String>{
    continueCard,
    actions,
    myTests,
    activity,
    friends,
    referral,
    ads,
    recommendations,
  };
}

/// Repository for the Home screen sections (docs/home-flow.en.md §5).
/// Each section is its own endpoint; the UI loads them independently.
abstract interface class IHomeRepository {
  Future<HomeContinueResponse> getContinue(HomeContinueRequest request);
  Future<HomeActionsResponse> getActions(HomeActionsRequest request);
  Future<MyTestsPreviewResponse> getMyTestsPreview(MyTestsPreviewRequest request);
  Future<HomeActivityResponse> getActivity(HomeActivityRequest request);
  Future<FriendsRatingResponse> getFriendsRating(FriendsRatingRequest request);
  Future<ReferralSummaryResponse> getReferralSummary(ReferralSummaryRequest request);
  Future<AdsResponse> getAds(AdsRequest request);
  Future<RecommendationsResponse> getRecommendations(RecommendationsRequest request);
  Future<ReferralClaimResponse> claimReferralFriend(ReferralClaimRequest request);
  Future<void> dismissAd(AdDismissRequest request);
  Future<void> trackAdImpression(AdImpressionRequest request);
  Future<void> trackAdClick(AdClickRequest request);

  /// Full "Mening testlarim" list ("Barchasi"): paginated + filtered /me/tests.
  Future<MyTestsPreviewResponse> getMyTests(MyTestsFilterSelection filter, {int page, int limit});

  /// GET /me/tests/filters — the filter sheet's subject/organization options.
  Future<MyTestsFiltersResponse> getMyTestsFilters(MyTestsFilterSelection filter);

  /// GET /tests/:id/rating — the per-test leaderboard.
  Future<TestRatingResponse> getTestRating(String testId, {int page, int limit});

  /// GET /xp/rules — the "XP qanday yig'iladi?" sheet.
  Future<XpRulesResponse> getXpRules();
}

final class HomeRepositoryImpl implements IHomeRepository {
  const HomeRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<HomeContinueResponse> getContinue(HomeContinueRequest request) async {
    try {
      final response = await apiClient.get(Urls.homeContinue);
      // 204 No Content → no in-progress session; tolerant fromJson yields empty.
      return HomeContinueResponse.fromJson(response);
    } catch (e, s) {
      info('HOME CONTINUE API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<HomeActionsResponse> getActions(HomeActionsRequest request) async {
    try {
      final response = await apiClient.get(Urls.homeActions);
      return HomeActionsResponse.fromJson(response);
    } catch (e, s) {
      info('HOME ACTIONS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<MyTestsPreviewResponse> getMyTestsPreview(MyTestsPreviewRequest request) async {
    try {
      final response = await apiClient.get(Urls.meTests, queryParameters: request.toJson());
      return MyTestsPreviewResponse.fromJson(response);
    } catch (e, s) {
      info('MY TESTS PREVIEW API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<HomeActivityResponse> getActivity(HomeActivityRequest request) async {
    try {
      final response = await apiClient.get(Urls.homeActivity);
      return HomeActivityResponse.fromJson(response);
    } catch (e, s) {
      info('HOME ACTIVITY API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<FriendsRatingResponse> getFriendsRating(FriendsRatingRequest request) async {
    try {
      final response = await apiClient.get(Urls.homeFriendsRating);
      return FriendsRatingResponse.fromJson(response);
    } catch (e, s) {
      info('FRIENDS RATING API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<ReferralSummaryResponse> getReferralSummary(ReferralSummaryRequest request) async {
    try {
      final response = await apiClient.get(Urls.referralSummary);
      return ReferralSummaryResponse.fromJson(response);
    } catch (e, s) {
      info('REFERRAL SUMMARY API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<AdsResponse> getAds(AdsRequest request) async {
    try {
      final response = await apiClient.get(Urls.ads, queryParameters: request.toJson());
      final result = AdsResponse.fromJson(response);
      info('ADS parsed: ${result.items.length} items');
      return result;
    } catch (e, s) {
      info('ADS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<RecommendationsResponse> getRecommendations(RecommendationsRequest request) async {
    try {
      final response = await apiClient.get(Urls.recommendations, queryParameters: request.toJson());
      return RecommendationsResponse.fromJson(response);
    } catch (e, s) {
      info('RECOMMENDATIONS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<ReferralClaimResponse> claimReferralFriend(ReferralClaimRequest request) async {
    try {
      final response = await apiClient.post(Urls.referralFriendClaim(request.friendId), body: request.toJson());
      return ReferralClaimResponse.fromJson(response);
    } catch (e, s) {
      info('REFERRAL CLAIM API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> dismissAd(AdDismissRequest request) async {
    try {
      await apiClient.post(Urls.adDismiss(request.adId));
    } catch (e, s) {
      info('AD DISMISS API ERROR: $e $s');
    }
  }

  @override
  Future<void> trackAdImpression(AdImpressionRequest request) async {
    try {
      await apiClient.post(Urls.adImpression(request.adId));
    } catch (e, s) {
      info('AD IMPRESSION API ERROR: $e $s');
    }
  }

  @override
  Future<void> trackAdClick(AdClickRequest request) async {
    try {
      await apiClient.post(Urls.adClick(request.adId));
    } catch (e, s) {
      info('AD CLICK API ERROR: $e $s');
    }
  }

  @override
  Future<MyTestsPreviewResponse> getMyTests(MyTestsFilterSelection filter, {int page = 1, int limit = 20}) async {
    try {
      final response = await apiClient.get(
        Urls.meTests,
        queryParameters: filter.toQuery(page: page, limit: limit),
      );
      return MyTestsPreviewResponse.fromJson(response);
    } catch (e, s) {
      info('MY TESTS LIST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<MyTestsFiltersResponse> getMyTestsFilters(MyTestsFilterSelection filter) async {
    try {
      final response = await apiClient.get(Urls.meTestsFilters, queryParameters: filter.toQuery());
      return MyTestsFiltersResponse.fromJson(response);
    } catch (e, s) {
      info('MY TESTS FILTERS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestRatingResponse> getTestRating(String testId, {int page = 1, int limit = 50}) async {
    try {
      final response = await apiClient.get(
        Urls.testRating(testId),
        queryParameters: <String, Object?>{'page': page, 'limit': limit},
      );
      return TestRatingResponse.fromJson(response);
    } catch (e, s) {
      info('TEST RATING API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<XpRulesResponse> getXpRules() async {
    try {
      final response = await apiClient.get(Urls.xpRules);
      return XpRulesResponse.fromJson(response);
    } catch (e, s) {
      info('XP RULES API ERROR: $e $s');
      rethrow;
    }
  }
}
