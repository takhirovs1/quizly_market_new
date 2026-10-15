# Client changelog: v5 (2026-10-15)

This lists only what changed in this release. Real example responses are in [`backend-integration-reply.md`](backend-integration-reply.md).

## Breaking changes

| Endpoint | Before | Now |
|---|---|---|
| `GET /api/ads?placement=home` | `data: [ad, …]` | `data: { items: [ad, …] }` |
| `GET /api/xp/rules` | `data: [rule, …]` | `data: { rules: [rule, …] }`. Each rule also has `xp` and `text`. |
| `GET /api/recommendations` | `title_key: "for_you"`, `price: 10000` | `title_key: "personalized" \| "popular"`. `price: "10 000 so'm"` is now a **string**; the number moved to `price_amount`. |
| `GET /api/home/activity` | `days[{date, count, today}]`, `delta_percent` could be `null` | `days[{weekday 1–7, count, is_today}]`. `date` and `today` are still sent. `delta_percent` is always a number. |
| `GET /api/referral/summary` | `per_friend_reward: 5000` | `per_friend_reward: "5 000 so'm"` is now a **string**; the number moved to `per_friend_reward_amount` (`null` on iOS). |
| `GET /api/home/friends-rating` | `me` was always an object | `me` is `null` when `friends_count` is 0 |
| `GET /api/me/tests` | `rating` was `null` until the user was rated | `rating` is always `{rank, total_participants}`; `rank` is `null` until rated |

## New fields

- **Every test card** (`/api/tests*`, `/home/continue`, `/attempts/continue`, `/me/tests`, `/recommendations`):
  - `color`: a hex colour, always the same for a given test.
  - `image_url`: always present; `null` when the test has no image.
- **Users on leaderboards, the test rating screen and the referral friends list:** `color`.
- **`GET /api/me/tests` items:** `test_id`, `answered`, `total`, `percent` and `mode` (`test` | `exam`) are now at the top level.
- **`GET /api/home/activity`:** `count` now includes flashcard sessions.
- **`GET /api/recommendations` items:** `test_id`, `organization`, `rating`, `sales_text`, `old_price` (`null` when there is no discount) and `is_favorite`.
- **`GET /api/referral/summary`:**
  - `unclaimed_count`: how many friends still have an unclaimed bonus.
  - `invite_code`: build the invite link as `…?startapp=r<invite_code>`.
  - `friends[{id, name, avatar_url, color, joined_at, reward_text, claimable, claimed}]`: one row per invited friend.
- **`POST /api/sessions` and `GET /api/sessions/{id}`:** `session_id` (the same value as `id`) and `image_url` on each question.
- **`POST /api/sessions/{id}/finish`:**
  - The body accepts `time_spent_sec`.
  - The response adds `skipped` and `time_spent_sec`.
- **`POST /api/tests/{id}/attempts/{aid}/finish`:**
  - Adds `correct`, `wrong`, `skipped` and `score_percent`.
  - `xp_total` is always present, even when the request is retried.
  - The client-side XP estimate can be removed.
- **Error bodies on the home-flow endpoints:** `{code, message, error}`.

## New endpoints

### Referral: claim one friend's bonus
`POST /api/referral/friends/{friendId}/claim` (empty body)

- **200:** `{ friend, unclaimed_count, reward_text }`.
  - Show `reward_text` as a toast.
  - Claiming the same friend again returns the same 200 and nothing is paid twice.
- **409 `BONUS_NOT_CLAIMABLE`:** the bonus is switched off, or the friend's account is gone.

### Friends

| Call | Response |
|---|---|
| `GET /api/friends?q=` | `{friends[user], total_count}` |
| `DELETE /api/friends/{userId}` | `{ok:true}`. Removes the friendship for both users. |
| `GET /api/friends/requests` | `{incoming[{request_id, created_at, user}], outgoing[…]}` |
| `POST /api/friends/requests` `{user_id}` | `{ok, request_id, relation}`. Errors: `400 CANNOT_ADD_SELF`, `404 USER_NOT_FOUND`. |
| `POST /api/friends/requests/{id}/accept` · `/reject` | `{ok:true}`. When the sender calls `reject`, it cancels their own request. Error: `404 REQUEST_NOT_FOUND`. |
| `GET /api/friends/suggestions` | `{suggestions[{relation, reason, user}]}`. `reason` is `shared_test` or `mutual_friend`. |
| `GET /api/friends/search?q=` | `{results[{relation, reason:null, user}]}`. Searches name, username or an exact user id; a query shorter than 2 characters returns no results. |
| `GET /api/friends/leaderboard` | `{me_rank, me_xp, resets_at, entries[{rank, xp, is_me, user}]}` |
| `GET /api/friends/groups` | `{coming_soon:true, active:[]}` |

The `user` object is `{id, name, username, avatar_url, color, xp, level, rank}`. `xp` counts this week only. `rank` is filled only in `GET /api/friends`.

`relation` is one of `none`, `requested`, `incoming` or `friend`, and decides the button: Add, Pending, Accept, or Friends.

## Behaviour changes

- **Referral bonus:**
  - The referrer is **no longer credited automatically** when a friend signs up; they claim each friend through the endpoint above.
  - The invited friend still gets their own bonus automatically.
- **Who counts as a friend:**
  - Friends leaderboards and `/home/friends-rating` now read the friends graph instead of the referral list.
  - Everyone you referred, and the person who referred you, are already your friends.
  - A new referral signup makes you friends automatically.
