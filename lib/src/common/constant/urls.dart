final class Urls {
  const Urls._();

  static const String loginWithTelegram = '/api/auth/telegram';
  static const String mobileVerify = '/api/auth/mobile/verify';
  static const String getMe = '/api/users/me';
  static const String updateLanguage = '/api/users/me/language';
  static const String topUp = '/api/payments/topup';

  static const String getMyTests = '/api/tests';

  // --- Home sections (docs/home-flow.en.md §5 + client-integration-v5.md) ---
  static const String homeContinue = '/api/home/continue';
  static const String homeActions = '/api/home/actions';
  static const String meTests = '/api/me/tests';
  static const String homeActivity = '/api/home/activity';
  static const String homeFriendsRating = '/api/home/friends-rating';
  static const String referralSummary = '/api/referral/summary';
  static const String ads = '/api/ads';
  static const String recommendations = '/api/recommendations';

  static String referralFriendClaim(String id) => '/api/referral/friends/$id/claim';
  static String adDismiss(String id) => '/api/ads/$id/dismiss';
  static String adImpression(String id) => '/api/ads/$id/impression';
  static String adClick(String id) => '/api/ads/$id/click';

  // ── Friends feature (client-integration-v5.md §4) ───────────────────────────
  static const String friends = '/api/friends';
  static const String friendRequests = '/api/friends/requests';
  static const String friendsSuggestions = '/api/friends/suggestions';
  static const String friendsSearch = '/api/friends/search';
  static const String friendsLeaderboard = '/api/friends/leaderboard';
  static const String friendsGroups = '/api/friends/groups';

  static String friendRequestAccept(String id) => '/api/friends/requests/$id/accept';
  static String friendRequestReject(String id) => '/api/friends/requests/$id/reject';
  static String removeFriend(String id) => '/api/friends/$id';

  // ── Sessions: random / mistakes / resume (client-integration-v5.md §6) ──────
  static const String sessions = '/api/sessions';
  static String session(String id) => '/api/sessions/$id';
  static String sessionAnswers(String id) => '/api/sessions/$id/answers';
  static String sessionFinish(String id) => '/api/sessions/$id/finish';

  // ── Mistakes picker, My-tests filters, per-test rating, XP rules (§6) ───────
  static const String mistakesSummary = '/api/me/mistakes/summary';
  static const String meTestsFilters = '/api/me/tests/filters';
  static String testRating(String id) => '/api/tests/$id/rating';
  static const String xpRules = '/api/xp/rules';

  /// Global weekly XP leaderboard (the "Umumiy" tab).
  static const String leaderboard = '/api/leaderboard';
}
