# Referrals — Admin & API Reference

Backend reference for the referral feature: how attribution and payouts work, plus
every referral-related endpoint an admin (or the admin panel frontend) can call.

- **Money:** integer **so'm** (UZS), never tiyin — e.g. `60000` = 60,000 so'm.
- **Two API surfaces:**
  - **Main API** (`/api/...`) — customer self endpoints + admin-gated `/api/referrals*`. JWT from customer OAuth; admin routes require `role = 'admin'`. Responses are wrapped in `{"data": ...}`.
  - **Admin panel API** (`/admin/v1/...`) — referral figures embedded in the dashboard, user detail, and pricing settings. Separate admin JWT; responses are **raw** (no `data` wrapper). See [`admin-api.md`](./admin-api.md).

---

## 1. How it works

### Attribution
- Every user gets a unique `users.referral_code` (short uppercase-hex, DB-generated) — returned in `GET /api/users/me`. The app builds a share link from it.
- A new user is attributed via `?start=ref_<code>` (bot `/start`), the Mini App `start_param`, or a `referral_code` field in the OAuth login body.
- `users.referred_by` is set **only on first insert** (detected via `RETURNING (xmax = 0)`). An unknown code resolves to `NULL` and never fails signup. Attribution can never be changed by a later login.

### Payout
- On successful first attribution the system pays a **fixed bonus to _both_ sides** — the referrer (for inviting) and the new user (a signup bonus).
- Each payout is one `wallet_transactions` row with `tx_type = 'referral_bonus'`:
  - referrer's row: `user_id = referrer`, `related_user_id = referred`, description `"Referral bonus"`.
  - new user's row: `user_id = referred`, `related_user_id = referrer`, description `"Referral signup bonus"`.
- **Idempotent:** a partial unique index on `wallet_transactions(user_id, related_user_id) WHERE tx_type='referral_bonus'` guarantees at most one payout per pair, so retries never double-pay.
- **Best-effort:** a failed payout never blocks login. Attribution is still recorded.

### Bonus amount source
The payout amount is the admin-configured **`referral_bonus` in `pricing_settings`** (so'm) —
the single source of truth. `payment.RewardReferral` reads it from the DB on each payout, so
changing it in the admin panel (§5) takes effect immediately, with no redeploy.

- `referral_bonus = 0` → **payouts are dormant**: attribution is still recorded, but no money moves and all `bonus_amount`/`total_earned` values read `0`.
- The `REFERRAL_BONUS` env var is now only a **fallback**, used solely if the `pricing_settings` row can't be read (e.g. an un-migrated environment). In normal operation it is ignored.

---

## 2. Customer self endpoints (`/api`)

For context — these power the user-facing referral screen. Auth: customer bearer token.

### `GET /api/users/me/referrals`
Paginated list of users the caller has referred. Query: `?limit=` (default 20), `?offset=` (default 0).

```json
{
  "data": [
    {
      "referred_user_id": "0d8c…",
      "referred_name": "Ali",
      "referred_avatar": "https://apiquizly.corelabs.uz/uploads/ab12.jpg",
      "referrer_id": "11111111-1111-1111-1111-111111111111",
      "referrer_name": "Vali",
      "bonus_amount": 5000,
      "signed_up_at": "2026-06-20T08:11:03Z"
    }
  ],
  "limit": 20,
  "offset": 0,
  "total": 12
}
```
`bonus_amount` is the so'm the referrer earned for **that** referral (`0` if payouts are dormant). `total` is the full referral count.

### `GET /api/users/me/referrals/summary`
Totals for the referral-screen header.

```json
{ "data": { "total_referrals": 12, "total_earned": 60000 } }
```
- `total_referrals` — how many users the caller successfully referred.
- `total_earned` — total so'm earned **for referring others**. Excludes the caller's own signup bonus (that's a separate `referral_bonus` row pointing the other way).

---

## 3. Admin referral endpoints (`/api`)

Auth: a customer JWT whose user has `role = 'admin'` (`auth.AdminOnly()`). `Authorization: Bearer <admin-user-token>`.

### `GET /api/referrals`
Every referral across all users, paginated (`?limit=`, `?offset=`). Same item shape and
envelope as the customer list in §2.

| Query param   | Required | Notes |
|---------------|----------|-------|
| `referrer_id` | no       | Scope to a single referrer's referrals. Omit for all users. |
| `limit`       | no       | Page size, default 20. |
| `offset`      | no       | Default 0. |

### `GET /api/referrals/summary`
Aggregate totals, same shape as §2's summary.

| Query param   | Required | Notes |
|---------------|----------|-------|
| `referrer_id` | no       | Scope to one referrer; omit for **global** totals across all users. |

```json
{ "data": { "total_referrals": 1840, "total_earned": 9200000 } }
```

---

## 4. Admin panel — embedded referral figures (`/admin/v1`)

These aren't standalone referral endpoints; the numbers ride along on existing admin-panel
responses. Raw envelope (no `data` wrapper). Money in so'm.

### `GET /admin/v1/dashboard` → `referral`
```json
"referral": {
  "total": 1840,
  "this_month": 96,
  "bonus_pool": 18400000
}
```
- `total` — users with `referred_by` set (all-time).
- `this_month` — referred users created since the start of the current month.
- `bonus_pool` — **SUM of every `referral_bonus` row across the system** (both referrer- and referred-side payouts). This is the total cost of the program, so it is roughly `2 ×` the sum of per-referrer earnings while payouts are active.

### `GET /admin/v1/users/:id` → `referral`
```json
"referral": {
  "code": "A1B2C3",
  "referred_count": 7,
  "earned": 35000
}
```
- `code` — this user's own referral code.
- `referred_count` — non-deleted users they referred.
- `earned` — **SUM of all `referral_bonus` rows credited to this user.** Note this includes the user's _own_ signup bonus if they were themselves referred, so it can exceed what they earned purely from inviting others (unlike the customer `total_earned` in §2, which excludes it).

---

## 5. Pricing setting (`/admin/v1/settings/pricing`)

`GET` / `PATCH` expose a `referral_bonus` field (integer so'm) alongside the other fees:

```json
{
  "upload_fee": 10000,
  "buy_fee_percent": 5,
  "cashback_percent": 2,
  "referral_bonus": 5000,
  "min_questions": 5,
  "auto_approve_threshold": 80,
  "max_sessions": 1
}
```

Editing `referral_bonus` here **is** the way to change the actual payout — `RewardReferral`
reads it from `pricing_settings` on every referral, so the change applies immediately (no
redeploy). Set it to `0` to pause payouts while still recording attribution.

---

## 6. Quick reference

| Need | Call |
|------|------|
| One user's referred list | `GET /api/users/me/referrals` (self) · `GET /api/referrals?referrer_id=<id>` (admin) |
| One user's totals | `GET /api/users/me/referrals/summary` (self) · `GET /api/referrals/summary?referrer_id=<id>` (admin) |
| Program-wide totals | `GET /api/referrals/summary` · `GET /admin/v1/dashboard` → `referral` |
| A user's code + count + earned | `GET /admin/v1/users/:id` → `referral` |
| Change the payout amount | `PATCH /admin/v1/settings/pricing` → `referral_bonus` (so'm) — applies immediately |
