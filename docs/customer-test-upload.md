# Customer test upload & paid publish — client contract

Users create their own tests (from an xlsx file or by building questions manually), pay
a per-question fee to publish, and share them by link. Backend: `internal/modules/test`
(create, import, visibility, pricing) + `internal/modules/payment` (publish fee, cashback).

```
create (file or manual) ──► draft ──► pay publish fee ──► uploaded (unlisted, shareable)
                                                              │
                                              admin may later flip it to market (listed)
```

- **Drafts are private.** Only the owner (and admins) can open a draft.
- **Published customer tests (`uploaded`) are unlisted.** They never show in the public
  marketplace (`/top`, `/recommended`, or other users' browsing and search). Anyone with
  the id or share `code` can open, preview, buy and solve them. **Sharing = sending the
  link.** There is no separate share endpoint.
- **Publish fee = `per_question_price × question_count`**, where the price is set in the
  admin panel. All money is in so'm (integers).
- **Cashback:** every sale of the owner's published test credits the owner
  `cashback_percent` of the sale price.
- **AI extract is not implemented.** Keep "AI Test yaratish" as "Tez kunda".

**Base URL:** `/api`. Everything needs `Authorization: Bearer <access_token>` except
`GET /api/universities`.
**Envelope:** `{"data": ...}` on success, `{"error": "..."}` on failure (some errors
also carry `"code"`). Lists add `limit`, `offset`, `total`.

---

## 1. Test statuses & visibility

Every test payload has `status`:

| status | Appears in lists for… | Can open it (detail / code / questions / solve) |
|---|---|---|
| `draft` | owner only (`/tests/my`, and the owner's own `/tests` list) | owner only; everyone else gets `403` |
| `uploaded` | owner and buyers only | **anyone** with the id or code |
| `market` | everyone | anyone |
| `blocked` | owner and buyers | owner and prior buyers only |

- An **archived** test (any status) can only be opened by its owner and buyers.
- A non-owner opening a draft gets `403` with the message
  `you can only modify your own tests`. The wording is misleading, so show a generic
  "test not available" message. Buying a draft returns `404 test not found`.
- `published_at` is set when the test goes live. **It is omitted** (not `null`) while
  the test is a draft.

---

## 2. Before building: pricing & universities

### `GET /api/tests/pricing`

Values come from the admin panel. Never hardcode them.

```json
{ "data": { "per_question_price": 100, "cashback_percent": 20, "min_questions": 30 } }
```

| field | type | UI |
|---|---|---|
| `per_question_price` | int (so'm) | "Harbir savol narxi" |
| `cashback_percent` | **float** (may be fractional, e.g. `7.5`) | "Cashback: harbir sotuvdan N%" |
| `min_questions` | int | advisory only. Fewer questions gives a warning, not a rejection. |

### `GET /api/universities` (public, no auth)

For the university picker (optional on every test).

```json
{ "data": [ { "id": "…uuid…", "code": "TATU", "name": "Toshkent axborot texnologiyalari universiteti" } ] }
```

`name` is localized to the request language. `?lang=all` returns
`{ id, code, name: {uz, ru, en}, sort_order }` instead.

---

## 3. Creating a test (both ways create a **draft**)

### 3.1 Manual — `POST /api/tests`

Translatable fields (`name`, `description`, question/option `text`) are i18n objects:
`{"uz": "...", "ru": "...", "en": "..."}`. Send at least one language.

```json
{
  "name": { "uz": "Matematika 1-semestr" },
  "description": { "uz": "Yakuniy nazorat savollari" },
  "category_id": "…uuid… | null",
  "university_id": "…uuid… | null",
  "photo_url": "a3f9c1….png",
  "price": 10000,
  "is_free": false,
  "time_limit_minutes": 60,
  "academic_year": "2025-2026",
  "semester": 1,
  "questions": [
    {
      "text": { "uz": "2 + 2 = ?" },
      "photo_url": "",
      "position": 1,
      "score": 1,
      "options": [
        { "text": { "uz": "3" }, "is_correct": false, "position": 1 },
        { "text": { "uz": "4" }, "is_correct": true,  "position": 2 }
      ]
    }
  ]
}
```

- Required: `name`, and `text` on each question and option. Everything else is optional.
- `price` is the **sale price** buyers pay ("Narxi"), not the publish fee. `0` or
  `is_free: true` makes the test free.
- `score` defaults to `1` when omitted.
- The server does **not** validate option count or the correct answer on this endpoint.
  Enforce it in the UI: 2–6 options, at least one `is_correct`.
- Upload images first via the file upload endpoint, then send the returned filename in
  `photo_url`.

**201** returns the created test **raw**: i18n objects are not localized, and the
nested `questions` are included. `status` is `"draft"`. `question_count` in this
response is `0`. Use `GET /api/tests/:id/publish-quote` for the real count.

Errors: `400` validation / `university not found`; `500` otherwise.

### 3.2 From file — `POST /api/tests/import[?dry_run=true]`

**Template:** `GET /api/tests/import/template` downloads `quizly-test-shabloni.xlsx`.
This is raw file bytes, not JSON. Offer it as "Shablonni yuklab olish".

`multipart/form-data`:

| field | required | notes |
|---|---|---|
| `file` | yes | `.xlsx` only, ≤ 25 MB |
| `name` | yes | "Test nomi" (stored as the default language) |
| `description` | no | "Test tavsifi" |
| `price` | no | sale price, so'm, integer ≥ 0 |
| `is_free` | no | `true` / `false` (anything unparseable is treated as `false`) |
| `category_id` | no | UUID |
| `university_id` | no | UUID of an active university |
| `photo` | no | cover image file |

**Sheet format** (first sheet only; row 1 = headers, case-insensitive):

| column | meaning |
|---|---|
| `question` | question text (**required**) |
| `photo` | question image: embed a picture in the cell or put an http(s) URL |
| `A` … `F` | answer options (at least 2) |
| `a_photo` … `f_photo` | option images (same rules as `photo`) |
| `correct` | correct letter(s), e.g. `B` or `A,C` (**required**) |
| `score` | positive number, default `1` |

Limits: 2000 rows, 5 MB per image (png/jpg/jpeg/gif/webp/bmp). Blank rows are skipped.

#### Step 1 — dry run (always do this first)

`?dry_run=true` parses and validates without writing anything. It returns every row
error at once, which powers the "Fileda muamolar mavjud" list.

```json
// 200
{
  "data": {
    "name": "Matematika fanidan",
    "question_count": 98,
    "errors": [
      { "row": 25, "message": "to'g'ri javob ko'rsatilmagan" },
      { "row": 28, "message": "kamida 2 ta javob varianti kerak, 1 ta berilgan" }
    ],
    "warnings": ["testda 20 ta savol bor, tavsiya etilgani kamida 30 ta"],
    "pricing": { "per_question_price": 100, "cashback_percent": 20, "publish_fee": 9800 }
  }
}
```

- `errors` is always an array. **`errors: []` = file is clean**, so enable "Yuklash".
- `warnings` is **omitted** when there are none.
- `question_count` / `publish_fee` include rows that have errors.
- `row` is the spreadsheet row number, so you can show "25-qator: …".

Row error messages you'll see (show them as-is; they're Uzbek):

- `savol matni bo'sh`
- `kamida 2 ta javob varianti kerak, N ta berilgan`
- `to'g'ri javob ko'rsatilmagan`
- `noto'g'ri javob harfi "X" (faqat A-F)`
- `X javobi belgilangan, lekin X ustuni bo'sh`
- `ball musbat son bo'lishi kerak, "v" berilgan`
- image problems (too big, wrong type, bad cell content)

**File-level problems come back as `400 {"error": "..."}` even in dry run**, not in
`errors[]`. Show them as a single message:

| `error` | cause |
|---|---|
| `nom talab qilinadi` | `name` missing |
| `noto'g'ri narx` | bad `price` |
| `noto'g'ri category_id` / `noto'g'ri university_id` | malformed UUID |
| `university not found` | unknown/inactive university |
| `fayl (file) yuklanmadi` | no `file` part |
| `fayl juda katta (eng ko'pi 25 MB)` | over 25 MB |
| `qo'llab-quvvatlanmaydigan fayl turi (.xlsx)` | not xlsx |
| `"question" ustuni topilmadi` / `"correct" ustuni topilmadi` | header row wrong; point to template |
| `juda ko'p qator (N), eng ko'pi 2000` | too many rows |
| `faylda savol topilmadi` / `faylda varaq topilmadi` | empty file |
| `faylni o'qib bo'lmadi: …` | corrupted file |

#### Step 2 — real run (same request, no `dry_run`)

A file with **any** row error is rejected whole:

```json
// 400
{ "error": "2 ta qatorda xatolik", "code": "IMPORT_ERRORS" }
```

(Details come from the dry run. Keep its errors on screen.)

Success creates the draft:

```json
// 201
{
  "data": {
    "test": { "id": "…", "code": "AB12CD34EF", "status": "draft", "name": { "uz": "…" }, … },
    "pricing": { "per_question_price": 100, "cashback_percent": 20, "publish_fee": 9800 }
  }
}
```

`test` is the raw test (i18n objects). Its `question_count` is `0`; use
`pricing.publish_fee` or the quote. `warnings` may also be present.

---

## 4. My tests — `GET /api/tests/my`

Query params (all optional):

| param | values |
|---|---|
| `status` | `draft` \| `uploaded` \| `market` \| `blocked` (for tabs). Anything else gives `400 invalid status`. |
| `category_id`, `university_id` | UUID filters |
| `search` | text |
| `archived` | `true` = archived only |
| `sort` | `id` \| `created_at` \| `price` (default `id`) |
| `limit`, `offset` | paging |

Items are localized (`name` is a string) and carry `status`, `code`, `question_count`,
`university_id` (always present, may be `null`), `university_name` (always present,
may be `""`), and `published_at` (omitted until published).

---

## 5. Editing

### Test metadata — `PUT /api/tests/:id` (owner)

Body is the create body **without** `questions`. **It is a full replace:**

- `name` is required.
- Omitting `photo_url` **clears the cover**. Omitting `category_id` **clears the category**.
  Always send the current values back.
- `time_limit_minutes`, `academic_year`, `semester`, `university_id`: omit or `null`
  keeps the current value.

Allowed in any status (price/name changes after publish are fine). **204** no body.
Errors: `400`, `403 you can only modify your own tests`, `404 test not found`.

### Questions & options (owner or admin)

| Method | Path | Body | Result |
|---|---|---|---|
| `POST` | `/tests/:id/questions` | `{ text, photo_url, position, score, options[] }` | 201 question |
| `PUT` | `/tests/:id/questions/:qid` | `{ text, photo_url, position, score }` | 204 |
| `DELETE` | `/tests/:id/questions/:qid` | — | 204 |
| `POST` | `/tests/:id/questions/:qid/options` | `{ text, photo_url, is_correct, position }` | 201 option |
| `PUT` | `/tests/:id/questions/:qid/options/:oid` | same | 204 |
| `DELETE` | `/tests/:id/questions/:qid/options/:oid` | — | 204 |

**Lock after publish.** Once the test leaves `draft`, adding or deleting a question or
option returns:

```json
// 409
{ "error": "questions can only be added or removed while the test is a draft" }
```

Editing text, images, score, position and `is_correct` stays allowed (typo fixes). The
lock exists because the fee was charged per question. Hide the add/delete buttons for
non-draft tests.

Other errors: `403` not owner; `400 invalid test id | invalid question id | invalid option id`.
A missing test/question/option currently returns **500** (`test not found` etc.).

### Delete — `DELETE /api/tests/:id` (owner)

Soft delete, **204**. Works in any status. A deleted published test disappears for
buyers too, so confirm with the user.

---

## 6. Publishing (the paywall)

### Step 1 — quote: `GET /api/tests/:id/publish-quote` (owner only)

```json
{
  "data": {
    "test_id": "…",
    "code": "AB12CD34EF",
    "status": "draft",
    "question_count": 98,
    "per_question_price": 100,
    "publish_fee": 9800,
    "cashback_percent": 20
  }
}
```

`published_at` appears only once the test is live. Errors: `403` not owner,
`404 test not found`, `400 invalid id`.

Show the fee, and the wallet balance next to it, then offer both payment options.

### Step 2a — pay from wallet: `POST /api/payments/tests/:id/publish`

No body. Debits the wallet and makes the test live in one transaction.

```json
// 200
{ "data": { "test_id": "…", "status": "uploaded", "fee": 9800, "balance": 330200, "code": "AB12CD34EF" } }
```

| HTTP | `error` | client action |
|---|---|---|
| 402 | `insufficient balance` | offer top-up or card (2b) |
| 409 | `test is already published` | refresh the test. Also returned on a double-tap, which is harmless. |
| 403 | `only the test's owner can publish it` / `test is blocked` | |
| 400 | `test has no questions` / `invalid test id` | |
| 404 | `test not found` | |

If the admin set the price to 0, this publishes for free (`fee: 0`).

### Step 2b — pay by card: `POST /api/payments/tests/:id/publish/checkout`

```json
{ "provider": "payme", "redirect_url": "quizly://publish-done" }
```

- `provider`: `payme` | `click` (required). `redirect_url` is optional.
- Send the usual client headers `X-Platform`, `X-App-Version`, `X-Screen-Name`,
  `X-Function-Name` (used for the staff payment report).

```json
// 200
{ "data": { "url": "https://checkout.paycom.uz/…", "payment_id": "…" } }
```

Extra errors: `409 publish fee is zero — publish directly, no checkout needed` (use 2a);
`400` bad/missing `provider`. The 403/400/404/409 errors from 2a also apply.

Open `url`, then poll **`GET /api/payments/:payment_id/status`**:

```json
{ "data": { "payment_id": "…", "status": "pending", "amount": 9800, "provider": "payme", "retry_after": 3 } }
```

- `status`: `pending` → keep polling (wait `retry_after` seconds when present, else ~3 s);
  `completed` → paid; `cancelled` / `refunded` → stop and show failure.
- **After `completed`, re-fetch the quote (or the test) and check `status == "uploaded"`.**
  If the owner changed the question count so the paid amount no longer covers the fee,
  the money is credited to the wallet as a **top-up** instead and the test stays `draft`.
  Then offer "publish from wallet" (2a). Nothing is lost.

---

## 7. Sharing & solving a published test

Share link = the test's `code`, using the same deep-link scheme as any test. For the
recipient everything works like a normal market test:

- `GET /api/tests/code/:code` or `GET /api/tests/:id` returns metadata.
- `GET /api/tests/:id/questions` returns full content if entitled (free, bought, or premium).
  Otherwise it returns the answer-stripped preview (`is_demo: true`).
- `POST /api/payments/tests/:id/purchase` (wallet) or `…/checkout` (card) buys it.
- Attempts work as usual.

Buying your **own** test gives `409 you cannot buy your own test`, so hide the buy
button for the owner.

**Images:** `photo_url` values are either a bare filename (`a3f9c1….png`), served at
`/uploads/<filename>`, or a full `http(s)` URL. Prefix only when it isn't already a URL.

---

## 8. Cashback (owner earnings)

When someone buys the owner's published (`uploaded`) test, the owner's wallet is credited
`floor(sale_price × cashback_percent / 100)` so'm immediately, for both wallet and card
purchases.

`GET /api/payments/wallet/transactions` shows it as:

```json
{ "tx_type": "cashback", "amount": 2000, "related_test_id": "…", "related_user_id": "<buyer>", "test_name": "…", … }
```

Related ledger types you may render:

| `tx_type` | meaning |
|---|---|
| `publish_fee` | fee paid to publish (negative amount) |
| `cashback` | earning from a sale |
| `cashback_reversal` | earning clawed back after a refund (negative) |

No cashback on free tests, admin (`market`) tests, or the owner's own account. Earned
cashback can be withdrawn via payouts once it is older than 14 days (separate doc).

---

## Endpoint summary

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/tests/pricing` | per-question price, cashback %, min questions |
| `GET` | `/universities` | university picker (public) |
| `GET` | `/tests/import/template` | download xlsx template |
| `POST` | `/tests/import?dry_run=true` | validate file, list errors, quote fee |
| `POST` | `/tests/import` | create draft from file |
| `POST` | `/tests` | create draft manually |
| `GET` | `/tests/my?status=` | my tests (tabs) |
| `PUT` / `DELETE` | `/tests/:id` | edit / delete |
| `POST/PUT/DELETE` | `/tests/:id/questions…` | question & option CRUD |
| `GET` | `/tests/:id/publish-quote` | fee quote |
| `POST` | `/payments/tests/:id/publish` | publish from wallet |
| `POST` | `/payments/tests/:id/publish/checkout` | publish by card |
| `GET` | `/payments/:id/status` | poll card payment |
| `GET` | `/tests/code/:code` | open shared test |
