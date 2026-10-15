# Backend integration — everything the client still mocks

**Goal:** remove **every** mock from the client and run on the real backend only.
This file is the full list of what the backend must ship for that. Each JSON
shape below matches the keys the client's `fromJson` already reads, so if the
backend returns exactly this, the client works without code changes.

**What we need back from the backend team:** one `.md` with, per endpoint in §3–§6:
the final path, a **real** example response (copy-paste from a real account), and
any field renames. We then wire each endpoint and delete its mock (§8).

- Logic + rules source of truth: [`docs/home-flow.en.md`](docs/home-flow.en.md)
- Referral payout rules: [`referrals.md`](referrals.md)
- Base URL: `https://apiquizly.corelabs.uz`. Every path below already includes `/api`.
- Every response may be wrapped in `{ "data": … }` or returned bare — the client accepts both.

---

## 1. Status at a glance

Legend: ✅ live, no mock · ⚠️ live but missing fields · ❌ missing (client serves a mock) · 🆕 new, needed for upcoming flows (no client code yet)

### Home screen (`lib/src/feature/my_tests/`, mock key in `HomeEndpoints`)
| # | Endpoint | Method | Status | Used by | Mock key |
|---|---|---|---|---|---|
| 3.1 | `/api/home/continue` | GET | ❌ | Continue hero | `continue` |
| 3.2 | `/api/home/actions` | GET | ❌ | Actions row (Random · Mistakes · Flashcard) | `actions` |
| 3.3 | `/api/me/tests?status=&limit=3` | GET | ❌ | "Mening testlarim" preview + status chips | `myTests` |
| 3.4 | `/api/home/activity` | GET | ❌ | "Haftalik faollik" | `activity` |
| 3.5 | `/api/home/friends-rating` | GET | ❌ | "Do'stlar reytingi" card | `friends` |
| 3.6 | `/api/referral/summary` | GET | ❌ | Referral card | `referral` |
| 3.7 | `/api/referral/friends/{id}/claim` | POST | ❌ | Referral "Olish" | `referral` |
| 3.8 | `/api/ads?placement=home` | GET | ❌ | Sponsor carousel | `ads` |
| 3.9 | `/api/ads/{id}/dismiss` · `/impression` · `/click` | POST | ❌ | Sponsor carousel telemetry | `ads` |
| 3.10 | `/api/recommendations?limit=10` | GET | ❌ | "Sizga mos testlar" | `recommendations` |

### Friends (`lib/src/feature/friends/`, mock key in `FriendsEndpoints`)
| # | Endpoint | Method | Status | Mock key |
|---|---|---|---|---|
| 4.2 | `/api/friends?q=` | GET | ❌ | `friendsList` |
| 4.2 | `/api/friends/{id}` | DELETE | ❌ | `friendsList` |
| 4.3 | `/api/friends/requests` | GET · POST | ❌ | `friendRequests` (GET) / `friendsDiscovery` (POST) |
| 4.3 | `/api/friends/requests/{id}/accept` · `/reject` | POST | ❌ | `friendRequests` |
| 4.4 | `/api/friends/suggestions` · `/api/friends/search?q=` | GET | ❌ | `friendsDiscovery` |
| 4.5 | `/api/friends/leaderboard` | GET | ❌ | `friendsLeaderboard` |
| 4.6 | `/api/friends/groups` | GET | ❌ (stub) | `friendsGroups` |

### Existing endpoints that need changes
| # | Endpoint | Method | Status | Why |
|---|---|---|---|---|
| 5.1 | `/api/tests/{id}/attempts/{attemptId}/finish` | POST | ⚠️ | must return **XP** for the result screen |
| 5.2 | `/api/flashcards/{testId}/result` | POST | ✅ | no change (flashcards give no XP) |
| 5.3 | `/api/tests?purchased=true` and every test-bearing response | GET | ⚠️ | add `color` (+ `image_url`) — §7 Thumbnails |
| 5.4 | `/api/users/me/referrals/summary` | GET | ⚠️ | superseded by §3.6 — keep or merge, tell us which |

### New, for flows being built now (no mock yet — client code waits on these)
| # | Endpoint | Method | Used by |
|---|---|---|---|
| 6.1 | `/api/sessions` | POST | Random test, Mistakes practice |
| 6.2 | `/api/sessions/{id}` | GET | Resume (Continue hero) |
| 6.3 | `/api/sessions/{id}/answers` | POST | Per-answer check + XP |
| 6.4 | `/api/sessions/{id}/finish` | POST | Result screen (score, XP) |
| 6.5 | `/api/me/mistakes/summary` | GET | Mistakes picker |
| 6.6 | `/api/me/tests/filters` | GET | "Barchasi" filter sheet |
| 6.7 | `/api/tests/{id}/rating` | GET | Per-test rating ("Reytingda #12") |
| 6.8 | `/api/xp/rules` | GET | "XP qanday yig'iladi?" sheet |

Already live and **not** mocked (no action): `/api/tests` · `/api/tests/top` ·
`/api/tests/{id}` · `/{id}/demo` · `/{id}/like` · `/{id}/attempts` · `/api/flashcards/{testId}` ·
`/api/payments/*` · auth · `/api/users/me`.

---

## 2. Shared conventions

- **Headers the client sends:** `Authorization: Bearer`, `X-Platform: ios | android | tma`,
  `X-Platform-Type`, `Api-Version: 1.0`, `X-Device-ID`, `X-App-Version`,
  `X-Screen-Name`, `X-Function-Name`. `X-Platform: ios` → reward/money texts must
  omit the amount (Apple 3.1.1).
- **Timezone:** all day/week math in the user's timezone (default `Asia/Tashkent`),
  stored on the user. Week = Mon 00:00 → Sun 23:59.
- **Pagination:** `?page&limit`; responses echo `limit`, `offset`, `total`.
- **Errors:** `{ "code": "SNAKE_CASE", "message": "…" }`. `204` = intentionally empty.
  `409` codes the client handles: `NO_PURCHASED_TESTS`, `NO_MISTAKES`, `BONUS_NOT_CLAIMABLE`.
- **Money/text:** every money or reward string is **server-formatted**
  (`"10 000 UZS"`, `"+1 000 UZS"`). The client never formats money.
- **XP:** calculated **server-side only** (docs §4.5). The client never sends XP.

---

## 3. Home screen

### 3.1 `GET /api/home/continue` — docs §4.1
Most recent `in_progress` session, mode `test | exam | flashcard`, `last_activity_at desc`.
```json
{
  "session_id": "s_91",
  "test": {
    "id": "t_1", "name": "Matematika: DTM 2026",
    "organization": { "name": "Alfragnus", "verified": true },
    "image_url": "", "color": "#2E6BFF"
  },
  "mode": "test", "answered": 34, "total": 100, "percent": 34,
  "last_activity_at": "2026-10-14T09:12:00Z"
}
```
- **204 No Content** → client hides the hero.
- `random` / `mistakes` sessions are **never** returned here.

### 3.2 `GET /api/home/actions` — docs §4.2–4.4
```json
{ "has_purchased_tests": true, "mistakes_count": 24, "flashcard_tests_count": 5 }
```
- `has_purchased_tests: false` disables the row (the free example test is handled client-side).
- `mistakes_count` = unresolved mistakes; drives the red badge.

### 3.3 `GET /api/me/tests?status=&limit=3` — "Mening testlarim"
`status` ∈ `not_started | in_progress | completed` (omit = all). `limit=3` for the
Home preview; the full list ("Barchasi") uses the same endpoint with `page/limit`.
```json
{
  "counts": { "all": 14, "not_started": 5, "in_progress": 2, "completed": 7 },
  "items": [
    {
      "test_id": "t_1", "name": "Matematika: DTM 2026",
      "organization": { "name": "Alfragnus", "verified": true },
      "image_url": "", "color": "#2E6BFF",
      "status": "in_progress", "answered": 34, "total": 100, "percent": 34,
      "mode": "test", "last_opened_at": "2026-10-14T09:12:00Z",
      "best_score_percent": null,
      "rating": { "rank": null, "total_participants": 340 }
    }
  ]
}
```
| Field | Drives |
|---|---|
| `status` | status pill + CTA ("Boshlash" / "Davom etish" / "Qayta ishlash") |
| `answered`, `total`, `percent` | progress bar, "34 / 100 savol", "34%" |
| `mode` | which mode to resume |
| `last_opened_at` | default sort |
| `best_score_percent` | "Natija 86%" pill on completed cards |
| `rating.rank`, `rating.total_participants` | "Reytingda #12 · 340 o'quvchi" |
| `counts` | status chips ("Barchasi 14", …) |

Status rules (docs §3.1): `in_progress` after the first `test/exam/flashcard`
session starts; `completed` after a `test/exam` session is finished with all
questions answered. `random`/`mistakes` sessions never change the status.

### 3.4 `GET /api/home/activity` — docs §4.8
```json
{
  "days": [
    { "weekday": 1, "count": 2, "is_today": false },
    { "weekday": 2, "count": 0, "is_today": false },
    { "weekday": 3, "count": 3, "is_today": true },
    { "weekday": 4, "count": 0, "is_today": false },
    { "weekday": 5, "count": 0, "is_today": false },
    { "weekday": 6, "count": 0, "is_today": false },
    { "weekday": 7, "count": 0, "is_today": false }
  ],
  "total_this_week": 5, "delta_percent": 20, "streak": 7
}
```
- Exactly 7 entries, `weekday` 1 = Mon … 7 = Sun, exactly one `is_today: true`.
- `count` = **finished** sessions that day (any mode).
- `delta_percent` = this week vs last week (may be negative).
- `streak` = consecutive days with ≥1 finished session; today not done yet keeps yesterday's value.

### 3.5 `GET /api/home/friends-rating` — docs §4.7
```json
{
  "friends_count": 6,
  "me": { "rank": 4, "xp": 860 },
  "next_rank_gap": 120,
  "is_tie": false, "tie_with": null,
  "top_avatars": [ { "name": "Aziz", "avatar_url": null } ],
  "resets_at": "2026-10-19T19:00:00Z"
}
```
- `friends_count: 0` → client shows the invite state; `me` may be `null`.
- Weekly XP window; ties share a rank.

### 3.6 `GET /api/referral/summary` — docs §4.9
Every referred friend is a **separately claimable** bonus.
```json
{
  "joined_count": 3,
  "unclaimed_count": 2,
  "per_friend_reward": "1 000 UZS",
  "invite_code": "A1B2C3",
  "friends": [
    { "id": "rf1", "name": "Jasur Karimov", "avatar_url": "", "color": "#34C759",
      "joined_at": "2026-10-13T10:00:00Z", "reward_text": "+1 000 UZS",
      "claimable": true, "claimed": false }
  ]
}
```
- `invite_code` builds the deep link `…?startapp=r<code>`.
- `unclaimed_count` = friends with `claimable && !claimed`.
- Bonuses are **not** auto-credited; each is claimed via §3.7.

### 3.7 `POST /api/referral/friends/{id}/claim`
Idempotent (unique `user_id + friend_id`). Empty body.
```json
{
  "friend": { "id": "rf1", "name": "Jasur Karimov", "reward_text": "+1 000 UZS", "claimable": true, "claimed": true },
  "unclaimed_count": 1,
  "reward_text": "Bonus hisobingizga qo'shildi"
}
```
- `409 BONUS_NOT_CLAIMABLE` when the friend is not claimable yet.
- Re-claim → same `200` body, not an error.
- `reward_text` is shown as a toast.

### 3.8 `GET /api/ads?placement=home` — docs §4.10
```json
{
  "items": [
    { "id": "ad1", "sponsor_name": "Bilim Markazi", "logo_url": "", "image_url": "",
      "title": "IELTS 7.0+ kursi — birinchi dars bepul", "cta_text": "Batafsil",
      "cta_url": "https://…", "priority": 1 }
  ]
}
```
Sorted by `priority`; exclude ads the user dismissed that are still within
`dismissed_until`. Empty `items` → section hidden.

### 3.9 `POST /api/ads/{id}/dismiss` · `/impression` · `/click`
Empty body, **204**. `dismiss` stores `dismissed_until = now + 24h` server-side so
app and TMA stay in sync. Errors are ignored by the client (fire-and-forget).

### 3.10 `GET /api/recommendations?limit=10` — docs §4.11
```json
{
  "title_key": "personalized",
  "items": [
    { "test_id": "r1", "name": "Akademik ko'nikmalar",
      "organization": { "name": "Alfragnus", "verified": true },
      "image_url": "", "color": "#7B5CFF",
      "rating": 4.8, "rating_count": 126, "question_count": 100,
      "sales_text": "1.2k sotilgan",
      "price": "10 000 UZS", "old_price": "12 500 UZS", "discount_percent": 20,
      "ios_product_id": "uz.quizly.test.r1", "is_favorite": true }
  ]
}
```
- `title_key`: `personalized` (based on purchased tests' subjects) or `popular`
  (new user fallback → title "Ommabop testlar").
- On iOS the client shows the StoreKit price for `ios_product_id`, never `price`.
- `is_favorite` toggles via the existing `POST/DELETE /api/tests/{id}/like`.

---

## 4. Friends

### 4.1 Shared `user` object (every friends response)
```json
{ "id": "u_aziz", "name": "Aziz Rahimov", "username": "aziz", "avatar_url": "",
  "color": "#34C759", "xp": 1240, "level": 7, "rank": 1 }
```
Only `id` and `name` are required; the rest may be `null`.

### 4.2 `GET /api/friends?q=` · `DELETE /api/friends/{id}`
```json
{ "friends": [ { "id": "u_aziz", "name": "Aziz Rahimov", "color": "#34C759", "xp": 1240 } ], "total_count": 4 }
```
`q` filters by name. `DELETE` → `{ "ok": true }` (idempotent; removes both directions).

### 4.3 Friend requests
`GET /api/friends/requests` — pending, both directions:
```json
{
  "incoming": [ { "request_id": "req_1", "created_at": "2026-10-14T08:00:00Z",
    "user": { "id": "u_sardor", "name": "Sardor Alimov", "color": "#FF3B30" } } ],
  "outgoing": [ { "request_id": "req_3", "created_at": "2026-10-12T11:00:00Z",
    "user": { "id": "u_kamola", "name": "Kamola Rashidova", "color": "#34C759" } } ]
}
```
- `POST /api/friends/requests` body `{ "user_id": "u_jasur" }` → `{ "ok": true, "request_id": "req_9" }`.
- `POST /api/friends/requests/{id}/accept` · `/reject` → `{ "ok": true }`. Accept makes both users friends.

### 4.4 `GET /api/friends/suggestions` · `GET /api/friends/search?q=`
```json
{ "suggestions": [ { "relation": "none", "reason": "shared_test",
    "user": { "id": "u_jasur", "name": "Jasur Nazarov", "color": "#FF9500" } } ] }
```
- `search` returns the same item shape under `"results"` (matches name, username or ID).
- `relation` ∈ `none | requested | incoming | friend` (drives the add / pending / accept button).
- `reason` explains a suggestion, e.g. `shared_test` (people who bought the same test).

### 4.5 `GET /api/friends/leaderboard` — weekly XP
```json
{
  "me_rank": 3, "resets_at": "2026-10-19T19:00:00Z",
  "entries": [ { "rank": 1, "xp": 1240, "is_me": false,
    "user": { "id": "u_aziz", "name": "Aziz Rahimov", "color": "#34C759" } } ]
}
```
Ties share a rank; exactly one entry has `is_me: true`.

### 4.6 `GET /api/friends/groups` — "Birga yechish" (stub)
```json
{ "coming_soon": true, "active": [] }
```
Group live-solve is a **websocket** feature and a separate task; please share the
socket protocol in its own doc before we build it. `active[]` items, when used:
`{ "id", "test_name", "host_name", "participants": [user], "status" }`.

---

## 5. Changes to existing endpoints

### 5.1 `POST /api/tests/{id}/attempts/{attemptId}/finish` — add XP ⚠️
Request (unchanged):
```json
{ "answers": [ { "question_id": "q1", "option_id": "o2" } ], "time_spent_sec": 412, "skip_count": 3 }
```
Today the response body is ignored. The shared result screen now shows
**"+N XP"**, so please return:
```json
{ "xp_total": 120, "correct": 7, "wrong": 0, "skipped": 3, "score_percent": 70 }
```
- The client reads `xp_total` (also accepts `xp_gained` or `xp`).
- Until this ships the client shows an **estimate** (+10 per correct, +50 if all
  answered). The estimate ignores the daily cap, so it can be higher than the real
  value — please ship `xp_total` so the number is always correct.
- Unanswered and timed-out questions are counted as **skipped** (`skip_count`),
  not wrong — same on client and server.

### 5.2 `POST /api/flashcards/{testId}/result` ✅
No change. Flashcards give **no** XP (docs §4.4); the result screen hides XP for them.

### 5.3 Thumbnails on every test-bearing response ⚠️
`/api/tests`, `/api/home/continue`, `/api/me/tests`, `/api/recommendations` (and
user objects in friends/referral) must return:
- `color` — hex, **always present**, **deterministic per id** (hash of the id), so
  the same test has the same tile on every screen and in app + TMA.
- `image_url` — optional. Present → image (with `color` behind it). Empty/`null` →
  solid `color` tile with the initial.

### 5.4 `/api/users/me/referrals/summary`
Returns `{ "total_referrals", "total_earned" }` only. The Home card uses §3.6
instead. Tell us whether to keep both or merge into one.

---

## 6. New endpoints for upcoming flows

These unblock **Random test**, **Mistakes practice**, resume and per-test rating.
There is no mock for them — the client is waiting on the contract.

### 6.1 `POST /api/sessions` — start a session
```json
{ "mode": "random", "count": 20 }
{ "mode": "mistakes", "scope": "all" }
{ "mode": "mistakes", "scope": "test", "test_id": "t_1" }
```
`mode` ∈ `test | exam | flashcard | random | mistakes`. Response:
```json
{
  "session_id": "s_120", "mode": "random", "total": 20,
  "questions": [
    { "id": "q1", "text": "…", "image_url": null,
      "source_test": { "id": "t_1", "name": "Matematika: DTM 2026" },
      "options": [ { "id": "o1", "text": "…" }, { "id": "o2", "text": "…" } ] }
  ]
}
```
- **Random** (docs §4.2): `count` ∈ {10, 20, 30}; pool = all purchased tests;
  round-robin across tests; fewer available → return all. No purchased tests →
  `409 NO_PURCHASED_TESTS`. `source_test` powers "Manba: …".
- **Mistakes** (docs §4.3): max 20, ordered `wrong_count desc, last_wrong_at asc`.
  Empty pool → `409 NO_MISTAKES`.
- Random/mistakes sessions don't change `user_tests.status` or rating.

### 6.2 `GET /api/sessions/{id}` — resume
Same body as §6.1 plus `"current_index": 7` and the already-given answers
`"answers": [ { "question_id", "option_id", "is_correct" } ]`.

### 6.3 `POST /api/sessions/{id}/answers`
```json
{ "question_id": "q1", "option_id": "o2", "time_spent_ms": 5400 }
```
→
```json
{ "is_correct": false, "correct_option_id": "o1", "xp_gained": 0, "mistake_resolved": false }
```
Last write wins per `question_id`.

### 6.4 `POST /api/sessions/{id}/finish`
Body: `{ "time_spent_sec": 412 }`. Idempotent. →
```json
{
  "session_id": "s_120", "mode": "random",
  "correct": 14, "wrong": 4, "skipped": 2, "total": 20, "score_percent": 70,
  "time_spent_sec": 412, "xp_total": 190,
  "mistakes_resolved_count": 1, "rating_rank": null
}
```
The client maps this straight into the shared result screen (`TestResultScreen`).

### 6.5 `GET /api/me/mistakes/summary`
```json
{ "total": 24, "by_test": [ { "test_id": "t_1", "name": "Matematika: DTM 2026", "count": 9 } ] }
```

### 6.6 `GET /api/me/tests/filters`
```json
{
  "subjects": [ { "id": "sub_1", "name": "Matematika", "count": 5 } ],
  "organizations": [ { "id": "org_1", "name": "Alfragnus", "count": 8 } ]
}
```
Counts power the "Natijalarni ko'rsatish (8)" button. `/api/me/tests` should then
accept `subject_ids`, `org_ids`, `q`, `sort=last_opened|score|name`.

### 6.7 `GET /api/tests/{id}/rating?page&limit`
```json
{
  "me": { "rank": 12, "score_percent": 86, "duration_sec": 840 },
  "total_participants": 340,
  "entries": [ { "rank": 1, "score_percent": 100, "duration_sec": 610,
    "user": { "id": "u_aziz", "name": "Aziz Rahimov", "color": "#34C759" } } ]
}
```
Ranked by the user's **first** finished `test/exam` attempt (docs §4.6).

### 6.8 `GET /api/xp/rules`
Static list for the "XP qanday yig'iladi?" sheet:
```json
{ "rules": [ { "type": "correct_answer", "xp": 10, "text": "Har bir to'g'ri javob" } ] }
```

---

## 7. Edge cases to agree on

- Deleted / unpublished test → stays in "Mening testlarim" as read-only; excluded from random and recommendations.
- Two devices on one session → last write wins per question; `finish` is idempotent.
- XP daily cap holds across app + TMA (server-side key `user_id + question_id + local_date`).
- Session with no activity for 7 days → `abandoned`, counted nowhere.

---

## 8. Client plan: remove all mocks

When the backend `.md` arrives we do this, endpoint by endpoint:

1. Compare the real response with this file; fix any renamed keys in the
   matching Response model (`lib/src/feature/my_tests/models/home/`,
   `lib/src/feature/friends/models/`).
2. Smoke-test each section on a real account (content, empty, error states).
3. When **all** of §3 and §4 are live, delete the mock layer entirely:
   - `lib/src/feature/my_tests/data/mock/home_mock_data_source.dart` (incl. `HomeMockScenario`)
   - `lib/src/feature/friends/data/mock/friends_mock_data_source.dart`
   - `mockDataSource` / `mockedEndpoints` / `_isMocked` in `home_repository.dart` and `friends_repository.dart`
   - the `USE_MOCK` wiring in [`initialize_dependencies.dart`](lib/src/common/dependency/initialization/initialize_dependencies.dart)
   - the debug "Mock scenario" sheet (triple-tap on the Home title) in `my_tests_screen_state.dart`
   - the "mocked" notes in [`urls.dart`](lib/src/common/constant/urls.dart)
4. Remove the client-side XP estimate in `TestResultArguments.earnedXp` once §5.1 returns `xp_total`.
5. Wire §6 (random, mistakes, resume, rating) straight to the real API — no new mocks.

Until step 3, `fvm flutter run --dart-define=USE_MOCK=true` still serves the mocks;
without the flag the real paths are called and a missing endpoint shows that
section's inline error (never a crash).
