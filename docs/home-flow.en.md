# QuizlyMarket — Home Screen & Learning Loop: Backend Spec

> Audience: backend team. Goal: understand **how every Home feature works end-to-end**, which data drives it, and which endpoints the mobile/TMA client expects.
> Client: Flutter (iOS, Android, Telegram Mini App). Accounts are merged across platforms, so **all user state must live on the server** (never client-only).

---

## 1. The big picture — the learning loop

```
Purchase test ─▶ Start session ─▶ Answer questions ─▶ Finish session
      ▲                │                 │                  │
      │                │                 ├─▶ wrong → Mistakes pool
      │                │                 └─▶ correct → XP
      │                ▼                                    ▼
 Recommendations   "Continue" card            Test rating (first attempt only)
 Referral / Ads                               Weekly activity + streak
                                              Friends / global leaderboard (weekly XP)
                                                            │
                         Mistakes practice / Random test ◀──┘ (new sessions, loop repeats)
```

Every Home section is a **view over the same core data**: purchases, sessions, answers, mistakes, XP events, friendships, referrals.

---

## 2. Home sections (top → bottom)

| # | Section | Shown when | Data source |
|---|---------|-----------|-------------|
| 1 | Continue (hero) | User has an in-progress single-test session | `sessions` |
| 2 | Actions: Random test · Mistakes · Flashcard | Always (disabled if no purchased tests) | `user_tests`, `mistakes` |
| 3 | My tests (max 3 + "All") | Always (empty state if none) | `user_tests`, `sessions`, `test_ratings` |
| 4 | Weekly activity + streak | Always | `sessions` |
| 5 | Friends rating | Always (invite state if no friends) | `xp_events`, `friendships` |
| 6 | Referral | Always | `referrals`, `referral_milestones` |
| 7 | Sponsor ad | If an active ad exists and not dismissed | `ads`, `ad_dismissals` |
| 8 | Recommended tests | Always | `tests`, `user_tests` |

**Achievements are out of scope for this release.**

### Loading strategy
The client loads each section **independently and in parallel** (one endpoint per section). If one section fails, only that section shows an error + retry; the rest render normally. Do **not** build a single all-or-nothing `/home` endpoint.

---

## 3. Core entities

### 3.1 `user_tests` (purchased tests)
| field | type | notes |
|---|---|---|
| user_id, test_id | uuid | unique pair |
| purchased_at | datetime | |
| status | enum | `not_started` · `in_progress` · `completed` |
| last_opened_at | datetime | updated whenever a session of this test starts/resumes |
| best_score_percent | int? | best finished attempt (display only) |

Status rules:
- created as `not_started` on purchase
- becomes `in_progress` when the first `test`/`exam`/`flashcard` session starts
- becomes `completed` when a `test`/`exam` session is finished (all questions answered)
- a new attempt after completion does **not** revert it to `in_progress` on the card, but it **does** produce a Continue card while that session is open

### 3.2 `sessions` (attempts)
| field | type | notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| mode | enum | `test` · `exam` · `flashcard` · `random` · `mistakes` |
| test_id | uuid? | null for `random` and `mistakes(all)` |
| status | enum | `in_progress` · `finished` · `abandoned` |
| is_first_attempt | bool | true only for the first `test`/`exam` session of this test |
| question_ids | uuid[] | fixed order, generated at start |
| current_index | int | for resume |
| correct, wrong, total | int | |
| score_percent | int? | on finish |
| duration_sec | int | active time, not wall-clock |
| started_at, finished_at, last_activity_at | datetime | |

`abandoned`: a session with no activity for **7 days** is auto-abandoned (cron). Abandoned sessions don't count anywhere.

### 3.3 `session_answers`
`session_id, question_id, source_test_id, selected_option_id, is_correct, time_spent_ms, answered_at`
`source_test_id` is required because `random` and `mistakes` sessions mix questions from many tests.

### 3.4 `mistakes` (per user, per question)
| field | notes |
|---|---|
| user_id, question_id | unique |
| test_id | source test |
| wrong_count | total times answered wrong |
| correct_streak | 0, 1, 2 |
| last_wrong_at | |
| resolved_at | set when correct_streak reaches 2 |

### 3.5 `xp_events`
`user_id, type, amount, ref_id, created_at, week_key` (e.g. `2026-W42`).
Leaderboards are `SUM(amount) GROUP BY user_id WHERE week_key = current`.

### 3.6 `friendships`
`user_id, friend_id, source (referral | profile_link), created_at` — stored **bidirectionally**.
Created automatically when an invitee registers through a referral link, or when a user accepts a profile link.

### 3.7 `referrals` / `referral_milestones`
- `referrals`: `inviter_id, invitee_id, status (pending | joined), joined_at`
- `referral_milestones`: config — `{ friends_required: 5 | 10 | 25, reward }`
- `referral_claims`: `user_id, milestone_id, claimed_at` (unique → idempotent)

### 3.8 `ads` / `ad_dismissals`
- `ads`: `id, placement ('home'), sponsor_name, logo_url, image_url, title, cta_text, cta_url, priority, starts_at, ends_at, is_active`
- `ad_dismissals`: `user_id, ad_id, dismissed_until` (now + 24h). Stored on the server so it syncs between app and TMA.

---

## 4. Feature logic

### 4.1 Continue card
- Return the **most recent** session (`last_activity_at desc`) with `status = in_progress` and `mode in (test, exam, flashcard)`.
- `random` and `mistakes` sessions are short and are **not** shown here.
- Nothing found → `204 No Content`; the client hides the card.
- Payload: test name, organization (+ verified), mode, answered/total, percent, `last_activity_at`, `session_id`.

### 4.2 Random test
1. Client sends `count` ∈ {10, 20, 30}.
2. Pool = all questions of all **purchased** tests.
3. Sampling: spread across tests (round-robin random), not uniform over questions. This stops one 500-question test from dominating.
4. If the pool is smaller than `count`, return all of it.
5. No purchased tests → `409 { code: "NO_PURCHASED_TESTS" }`.
6. Each answer carries `source_test_id` so the UI shows "Manba: …".
7. Wrong answers feed the mistakes pool; XP follows the normal rules.
8. Random sessions **do not** change `user_tests.status` and **do not** affect test rating.

### 4.3 Mistakes practice
- A question enters the pool when answered wrong in **any** session mode.
- Any later correct answer to that question (any mode) → `correct_streak + 1`.
- Wrong again → `correct_streak = 0`, `wrong_count + 1`, `resolved_at = null`.
- `correct_streak == 2` → `resolved_at = now()` and the question leaves the pool.
- Scopes:
  - `all`: unresolved mistakes across all tests, ordered by `wrong_count desc, last_wrong_at asc`, max **20** per session.
  - `test`: unresolved mistakes of one `test_id`, max 20.
- Empty pool → `409 { code: "NO_MISTAKES" }`; the client shows "Xatolar yo'q 🎉".
- The Actions badge = total unresolved mistakes.
- Mistakes sessions don't affect rating or `user_tests.status`.

### 4.4 Flashcard action
- Opens a picker of purchased tests with flashcard counts.
- Starts the existing `flashcard` mode.
- Flashcard sessions give **no** correctness XP (self-graded) and don't affect rating.

### 4.5 XP rules
| event | XP | rule |
|---|---|---|
| `correct_answer` | +10 | modes `test`, `exam`, `random`; **max once per question per calendar day** |
| `session_finished` | +50 | modes `test`, `exam`, `random`; only when all questions are answered |
| `mistake_resolved` | +5 | when `correct_streak` reaches 2 (replaces the +10 for that answer) |
| `daily_goal` | +30 | once per day when the daily goal (config `daily_goal_sessions`, default 3 finished sessions) is reached |

- Daily cap key: `(user_id, question_id, local_date)`.
- All dates use the **user's timezone** (default `Asia/Tashkent`); store it on the user for CIS expansion.
- XP is calculated **server-side only**. The client never sends XP amounts.

### 4.6 Test rating (per test, among buyers)
- Ranked by the **first finished** `test`/`exam` attempt (`is_first_attempt = true`):
  1. `score_percent desc`
  2. `duration_sec asc`
  3. `finished_at asc`
- Re-attempts never change rating (they prevent memorise-and-retry abuse).
- Store a denormalized `test_ratings(test_id, user_id, score, duration, finished_at)` row on the first finish. Rank via window function or cached.
- Response cases:
  - user ranked → include a pinned `me` row
  - user not solved yet → `me = null`, `can_join = true`
  - only the user → list of 1
- Card summary for "My tests": `rank`, `total_participants`.

### 4.7 Weekly leaderboard (global & friends)
- Period: Monday 00:00 → Sunday 23:59 in the user's timezone. Resets automatically (new `week_key`).
- `friends` scope = the user + all friendships.
- Ranking: XP desc. Ties share the same rank (`1, 2, 2, 4`); within a tie, whoever reached that XP first is listed first.
- Response includes `me` (rank, xp), `next_rank_gap` (XP to the next rank up), `is_tie`, `tie_with` (name), `resets_at`.
- No friends → `friends_count = 0`; the client shows the invite state.

### 4.8 Weekly activity & streak
- `days[7]`: count of **finished** sessions per day (Mon–Sun), with `today` flagged.
- `total_this_week`, `delta_percent` vs last week.
- Streak: consecutive local days with ≥1 finished session (any mode). Today not done yet → the streak still shows yesterday's value; it breaks only after a full missed day.

### 4.9 Referral
- Each joined friend → existing per-friend reward (unchanged business rule).
- Milestones 5 → 10 → 25. Response:
  - `joined_count`
  - `current_milestone { required, reward, claimable, claimed }`
  - `next_milestone`
- Reward is **not** auto-credited at a milestone. The user taps "Bonusni olish" → `POST claim`. This must be idempotent (unique `user_id + milestone_id`).
- After a claim the response moves to the next milestone (5/10).
- **Platform-specific display**: the client sends header `X-Platform: ios | android | tma`. For `ios`, return reward display text without money amounts (Apple guideline 3.1.1). The amount itself is a server-provided string, so it is never hardcoded on the client.

### 4.10 Sponsor ads
- Return active ads for `placement=home`, ordered by priority, excluding ones dismissed and still within `dismissed_until`.
- Empty → the client hides the section.
- Track `impression` (when the ad is visible on screen) and `click` events for sponsor reporting.

### 4.11 Recommendations
1. Subjects = subjects of the user's purchased tests.
2. Candidates = tests in those subjects, **excluding already purchased**, ranked by `sales_30d * rating`.
3. No purchases (new user) → global popular tests, `title_key = "popular"`.
- Pricing: return `price` (UZS) **and** `ios_product_id`. On iOS the client shows the StoreKit price, never the UZS one.

---

## 5. Endpoints

All responses are JSON. Lists use `?page&limit` pagination. Errors use `{ code, message }`.

### Home sections
| method | path | purpose |
|---|---|---|
| GET | `/home/continue` | 4.1 — 200 or 204 |
| GET | `/home/actions` | `{ has_purchased_tests, mistakes_count, flashcard_tests_count }` |
| GET | `/me/tests?status=&limit=3` | My tests preview + counts per status |
| GET | `/home/activity` | 4.8 |
| GET | `/home/friends-rating` | 4.7 friends summary |
| GET | `/referral/summary` | 4.9 |
| GET | `/ads?placement=home` | 4.10 |
| GET | `/recommendations?limit=10` | 4.11 |

### My tests — "All" page
| method | path | purpose |
|---|---|---|
| GET | `/me/tests?q=&status=&subject_ids=&org_ids=&sort=last_opened\|score\|name&page&limit` | full list with search & filters |
| GET | `/me/tests/filters` | available subjects / organizations **with counts** (for the filter sheet and the "Natijalarni ko'rsatish (8)" button) |

### Sessions
| method | path | purpose |
|---|---|---|
| POST | `/sessions` | `{ mode, test_id? , count?, scope? }` → session + questions |
| GET | `/sessions/{id}` | resume |
| POST | `/sessions/{id}/answers` | `{ question_id, option_id, time_spent_ms }` → `{ is_correct, correct_option_id, xp_gained, mistake_resolved }` |
| POST | `/sessions/{id}/finish` | → result: score, correct/wrong, `xp_total`, `mistakes_resolved_count`, `rating_rank?` |

### Mistakes / rating / leaderboard / referral / ads
| method | path |
|---|---|
| GET | `/me/mistakes/summary` → `{ total, by_test: [{ test_id, name, count }] }` |
| GET | `/tests/{id}/rating?page&limit` |
| GET | `/leaderboard?scope=friends\|global&period=week` |
| GET | `/xp/rules` (static, for the "XP qanday yig'iladi?" sheet) |
| POST | `/referral/milestones/{id}/claim` |
| GET | `/referral/invites` (invited list with status) |
| POST | `/ads/{id}/dismiss` · `/ads/{id}/impression` · `/ads/{id}/click` |

### Example — `GET /home/continue`
```json
{
  "session_id": "s_91",
  "test": { "id": "t_1", "name": "Example test", "organization": { "name": "QuizlyMarket", "verified": true } },
  "mode": "test",
  "answered": 34,
  "total": 100,
  "percent": 34,
  "last_activity_at": "2026-10-14T09:12:00Z"
}
```

### Example — `GET /home/friends-rating`
```json
{
  "friends_count": 6,
  "me": { "rank": 4, "xp": 860 },
  "next_rank_gap": 120,
  "is_tie": false,
  "tie_with": null,
  "top_avatars": [{ "name": "Aziz", "avatar_url": null }],
  "resets_at": "2026-10-19T19:00:00Z"
}
```

---

## 6. Mock endpoints
The client switches base URL with `--dart-define=USE_MOCK=true`. Please expose the **same paths** on a mock host, with fixtures for every UI state:

- continue: present / 204
- actions: no purchased tests
- my tests: empty / mixed statuses
- mistakes: 0 / many
- rating: me ranked / me not solved / alone / me #1
- friends: 0 friends / #1 / middle / tie
- referral: 0, 2, 5 claimable, 5 claimed → next 10
- ads: none / 1 / 3
- recommendations: personalized / popular fallback

Select the state via query `?mock_state=<name>`.

---

## 7. Edge cases checklist
- A purchased test is deleted or unpublished by its creator → keep it in My tests as read-only; exclude it from random/recommendations.
- A question is edited after it was answered wrong → keep the mistake; if deleted, drop it from the pool.
- Two devices answer the same session at once → last write wins per `question_id`; finish is idempotent.
- Timezone change mid-week → the week key uses the timezone at event time.
- The XP daily cap must also hold across app + TMA (server-side key).
