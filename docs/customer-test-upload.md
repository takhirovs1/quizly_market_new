# Customer test upload & paid publish — client contract

Users create their own tests (from an xlsx file or by building questions manually),
pay a fee to publish, and share them by link. Backend: `internal/modules/test`
(create, visibility, pricing) + `internal/modules/payment` (publish fee, cashback).

The lifecycle in one line:

```
create (file or manual) ──► draft ──► pay publish fee ──► uploaded (unlisted, shareable)
                              ▲                               │
                              └────── Payme refund/cancel ────┘
```

- **Drafts are invisible.** Only the owner (and admins) can see or open a draft —
  it appears in *my tests*, and nowhere else. Anyone else gets `404`/`403`,
  including via the share code.
- **Published customer tests are unlisted.** They never appear in the public
  lists (`GET /api/tests`, `/top`, `/recommended`, search). Anyone who has the
  share code or id can open, preview, buy, and solve them. **Sharing = sending
  the link.** There is no separate share endpoint.
- **The publish fee is per question**, set in the admin panel:
  `fee = per_question_price × question_count`. Prices are so'm, always integral.
- **Cashback:** each time someone buys a published customer test, its owner's
  wallet is credited `cashback_percent` of the sale price (rounded down).
- **AI extract is not implemented yet** — the "AI Test yaratish" entry stays
  "Tez kunda".

All endpoints below require `Authorization: Bearer <access_token>`. Base URL: `/api`.
Responses use the standard envelope: `{"data": ...}` on success,
`{"error": "..."}` on failure.

---

## 1. Test statuses

`status` is now on every test payload:

| status | Who sees it in lists | Who can open it (detail / code / questions / solve) |
|---|---|---|
| `draft` | owner only (my tests) | owner only |
| `uploaded` | nobody (buyers see it in their own lists) | **anyone** with the id or share code |
| `market` | everyone (public marketplace) | anyone |
| `blocked` | nobody | owner and prior buyers only |

`published_at` (timestamp, nullable) is set the moment a test goes live.

---

## 2. Pricing (show before/while the user builds a test)

### `GET /api/tests/pricing`

Dynamic values from the admin panel — never hardcode them.

```json
{
  "data": {
    "per_question_price": 100,
    "cashback_percent": 20,
    "min_questions": 30
  }
}
```

- `per_question_price` — so'm charged per question at publish time
  ("Harbir savol narxi").
- `cashback_percent` — the owner's cut of every future sale
  ("Cashback: harbir sotuvdan N%").
- `min_questions` — advisory only; uploads below it get a warning, not a rejection.

---

## 3. Creating a test (both ways create a **draft**)

### 3.1 Manual — `POST /api/tests`

Body unchanged from before (name/description/questions/options with i18n text,
`price`, `is_free`, optional `category_id`, positions 1-based). What changed: the
created test is now a **draft** and the response carries `status`, `code`, and
`published_at`.

```json
// 201
{ "data": { "id": "…", "code": "AB12CD34EF", "status": "draft", "price": 10000, … } }
```

`price` here is the **sale price** the owner wants to charge buyers ("Narxi" field),
not the publish fee.

### 3.2 From file — `POST /api/tests/import[?dry_run=true]`

`multipart/form-data`:

| field | required | notes |
|---|---|---|
| `file` | yes | `.xlsx` only (the template below) |
| `name` | yes | test name ("Test nomi") |
| `description` | no | "Test tavsifi" |
| `category_id` | no | UUID; malformed value → `400` |
| `price` | no | sale price, so'm ≥ 0 |
| `is_free` | no | `true`/`false` |
| `photo` | no | cover image file |

Caps: 25 MB file, 2000 rows, 5 MB per embedded image, 2–6 options per question.

**Template:** `GET /api/tests/import/template` downloads the example workbook
(`quizly-test-shabloni.xlsx`) — same file the admin panel uses. Columns (row 1
headers, case-insensitive): `question`, `photo`, `A`…`F`, `a_photo`…`f_photo`,
`correct`, `score`.

**Dry run first.** With `?dry_run=true` the file is parsed and validated, nothing is
written, and you get every row error at once — this powers the "Fileda muamolar
mavjud" list in the UI:

```json
// 200 (dry run)
{
  "data": {
    "name": "Matematika fanidan",
    "question_count": 98,
    "errors": [
      { "row": 25, "message": "to'g'ri javob ko'rsatilmagan (correct)" },
      { "row": 28, "message": "kamida 2 ta javob varianti kerak" }
    ],
    "warnings": ["testda 20 ta savol bor, tavsiya etilgani kamida 30 ta"],
    "pricing": { "per_question_price": 100, "cashback_percent": 20, "publish_fee": 9800 }
  }
}
```

`errors: []` means the file is clean — enable the "Yuklash" button.

**Real run** (no `dry_run`): a file with any row error is rejected whole:

```json
// 400
{ "error": "2 ta qatorda xatolik", "code": "IMPORT_ERRORS" }
```

(The per-row details come from the dry run — run it first and keep the errors on
screen.)

On success the draft is created (images from the sheet are stored and served under
`/uploads/*`):

```json
// 201
{
  "data": {
    "test": { "id": "…", "code": "…", "status": "draft", … },
    "pricing": { "per_question_price": 100, "cashback_percent": 20, "publish_fee": 9800 },
    "warnings": []
  }
}
```

---

## 4. My tests

### `GET /api/tests/my`

Existing endpoint; now also accepts `?status=draft|uploaded|market|blocked` for the
tabs, and each item carries `status` + `published_at`. Other filters unchanged
(`category_id`, `search`, `sort`, `archived=true`).

An invalid `status` value → `400 {"error": "invalid status"}`.

---

## 5. Editing a draft (and what locks after publish)

Question/option CRUD (`POST/PUT/DELETE /api/tests/:id/questions…`) is now
**owner-or-admin only** — editing someone else's test returns `403`.

Once a test leaves `draft`:

| operation | after publish |
|---|---|
| add/delete question, add/delete option | **`409`** `questions can only be added or removed while the test is a draft` |
| edit question/option text (typo fixes) | allowed (owner) |
| `PUT /api/tests/:id` (name, sale price, description, …) | allowed (owner) |

The lock exists because the publish fee was charged per question.

---

## 6. Publishing (the paywall)

The user can publish at any time. Show the quote first:

### `GET /api/tests/:id/publish-quote` — owner only

```json
{
  "data": {
    "test_id": "…",
    "code": "AB12CD34EF",
    "status": "draft",
    "question_count": 98,
    "per_question_price": 100,
    "publish_fee": 9800,
    "cashback_percent": 20,
    "published_at": null
  }
}
```

`403` if the caller doesn't own the test; `404` if it doesn't exist.

### 6.1 Pay from wallet — `POST /api/payments/tests/:id/publish`

No body. Debits the wallet ("QuizlyMarket Card") and flips the test live in one
transaction.

```json
// 200
{ "data": { "test_id": "…", "status": "uploaded", "fee": 9800, "balance": 330200, "code": "AB12CD34EF" } }
```

Errors:

| HTTP | error | meaning |
|---|---|---|
| 402 | `insufficient balance` | wallet can't cover the fee → offer top-up, then retry |
| 409 | `test is already published` | already `uploaded`/`market` (also on double-tap) |
| 403 | `only the test's owner can publish it` / `test is blocked` | |
| 400 | `test has no questions` | |
| 404 | `test not found` | |

A zero fee (admin set `upload_fee` to 0) publishes without charging.

### 6.2 Pay by card — `POST /api/payments/tests/:id/publish/checkout`

Body: `{"provider": "payme" | "click", "redirect_url": "…"}` (redirect optional).
Send the usual client headers (`X-Platform`, `X-App-Version`, `X-Screen-Name`,
`X-Function-Name`) — they feed the staff payment report.

```json
// 200
{ "data": { "url": "https://checkout.paycom.uz/…", "payment_id": "…" } }
```

Open `url`, then poll `GET /api/payments/:payment_id/status` exactly like a top-up
(`status: "completed"` = the test is live; honor `retry_after`). Same validation
errors as §6.1, plus `409 publish fee is zero — publish directly, no checkout
needed` (use the wallet endpoint instead).

Edge case: if the owner adds questions between checkout and payment, the paid
amount may no longer cover the fee — the money then lands as a **wallet top-up**
instead and the test stays draft; the user republishes from the wallet. Nothing is
lost.

---

## 7. Sharing & solving a published test

The share link is built from the test's `code` (same deep-link scheme as every
other test). For the recipient everything behaves like a market test:

- `GET /api/tests/code/:code` / `GET /api/tests/:id` — metadata.
- `GET /api/tests/:id/questions` — full content if entitled (free test, buyer,
  premium), otherwise the 5-question answer-stripped preview.
- `POST /api/payments/tests/:id/purchase` (wallet) or `…/checkout` (card) — buy it.
- Attempts work as usual.

The only thing a recipient can't do is find it by browsing/search — it's unlisted.

New purchase error for every test: **`409 you cannot buy your own test`**.

---

## 8. Cashback (owner earnings)

When someone buys a published (`uploaded`) customer test, the owner's wallet is
credited `floor(sale_price × cashback_percent / 100)` so'm, immediately, in the same
transaction as the sale — both wallet and card purchases.

It shows up in `GET /api/payments/wallet/transactions` as:

```json
{ "tx_type": "cashback", "amount": 2000, "related_test_id": "…", "related_user_id": "<buyer>", … }
```

The publish fee appears there too, as `tx_type: "publish_fee"` (negative amount).

No cashback on: free tests, admin (`market`) tests, repeat/failed purchases, or the
owner's own account.
