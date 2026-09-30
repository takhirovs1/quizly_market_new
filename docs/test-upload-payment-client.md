# Test upload payment — client (mobile app / Telegram Mini App)

How a user pays to publish their own test, and how the app picks the test's sale price.
The full upload contract (statuses, xlsx import, editing questions) is in
`docs/customer-test-upload.md`. This doc covers only the money.

All amounts are **so'm, integers**. Every pricing value comes from the admin panel, so
**never hardcode it**. Read it from the API.

---

## 1. Two different prices

| | Who pays | Formula | Example |
|---|---|---|---|
| **Publish fee** ("Yuklash narxi") | the test's owner, once, to publish it | `per_question_price × question_count` | 100 so'm × 100 questions = **10 000** |
| **Sale price** ("Test narxi") | each buyer | owner chooses; the app pre-fills `suggested_price` | 200 so'm × 100 questions = **20 000** suggested |

Rules for the sale price:

- **Suggested:** `suggested_price = max(suggested_question_price × question_count, min_test_price)`.
- **Owner may change it** to any whole number **≥ `min_test_price`** (e.g. 5 000).
- **Customer tests can't be free.** `price: 0` and `is_free: true` are rejected.
- Each sale credits the owner `cashback_percent` of the sale price (floored).

---

## 2. Screens & endpoints

### 2.1 Before building — `GET /api/tests/pricing`

```json
{ "data": {
    "per_question_price": 100,
    "cashback_percent": 20,
    "min_questions": 30,
    "suggested_question_price": 200,
    "min_test_price": 5000
} }
```

| field | UI |
|---|---|
| `per_question_price` | "1 ta savol yuklash narxi" (publish fee per question) |
| `suggested_question_price` | "1 ta savol narxi" (suggested sale price per question) |
| `min_test_price` | minimum for the price input ("Minimal narx: 5 000 so'm") |
| `cashback_percent` | "Har bir sotuvdan N% cashback". A **float**, may be `7.5` |
| `min_questions` | advisory only; show a warning, don't block |

While the user builds a test manually, compute everything live:

```
publish_fee     = per_question_price × questions
suggested_price = max(suggested_question_price × questions, min_test_price)
```

Pre-fill the price field with `suggested_price`. If the user hasn't edited it yet, keep
it in sync as questions are added. Once they edit it, stop overwriting. Show a
"Tavsiya etilgan narx" reset button.

### 2.2 Save the test with its price

**Manual** — `POST /api/tests` (body as in `customer-test-upload.md` §3.1):

```json
{ "name": { "uz": "…" }, "price": 20000, "questions": [ … ] }
```

**From xlsx** — `POST /api/tests/import[?dry_run=true]` (multipart):

- **Leave `price` out** and the test gets the suggested price for the file's question count.
- **Send `price`** and it must be ≥ `min_test_price`.

Every import response has a `pricing` block:

```json
"pricing": {
  "per_question_price": 100, "cashback_percent": 20, "publish_fee": 9800,
  "suggested_price": 19600, "min_test_price": 5000, "price": 19600
}
```

`price` is what the test will be sold for: the value you sent, or `suggested_price`.
Show the dry-run's `suggested_price` in the price field before the real upload.

**Edit price later** — `PUT /api/tests/:id` (full replace; always send `price`).
Allowed in any status, including after publish. The same ≥ `min_test_price` rule applies.

Price error (all three endpoints):

```json
// 400
{ "error": "test narxi kamida 5000 so'm bo'lishi kerak" }
```

Show it under the price field. Validate in the UI first so users rarely see it.

### 2.3 Publish screen — `GET /api/tests/:id/publish-quote` (owner only)

```json
{ "data": {
    "test_id": "…", "code": "AB12CD34EF", "status": "draft",
    "question_count": 100,
    "per_question_price": 100,
    "publish_fee": 10000,
    "suggested_question_price": 200,
    "suggested_price": 20000,
    "min_test_price": 5000,
    "cashback_percent": 20
} }
```

Show `publish_fee` with the wallet balance next to it, and the test's current price with
`suggested_price` as a hint. Then offer both ways to pay.

Errors: `403` not owner, `404 test not found`, `400 invalid id`.

### 2.4a Pay from wallet — `POST /api/payments/tests/:id/publish`

No body. Debits the wallet and publishes in one step.

```json
{ "data": { "test_id": "…", "status": "uploaded", "fee": 10000, "balance": 330200, "code": "AB12CD34EF" } }
```

If the admin set `per_question_price` to 0, this publishes for free (`fee: 0`).

### 2.4b Pay by card — `POST /api/payments/tests/:id/publish/checkout`

```json
{ "provider": "payme", "redirect_url": "quizly://publish-done" }
```

- `provider` is `payme` or `click`.
- Send headers `X-Platform`, `X-App-Version`, `X-Screen-Name`, `X-Function-Name`.
- Returns `{ "data": { "url": "…", "payment_id": "…" } }`.

Open `url`, then poll `GET /api/payments/:payment_id/status`:

- Wait `retry_after` seconds between polls, or about 3 s when it's absent.
- `pending`: keep polling. `completed`: paid. `cancelled` / `refunded`: stop and show failure.

After `completed`, re-fetch the quote and check `status == "uploaded"`. If the question
count changed while paying and the money no longer covers the fee, it lands in the
wallet as a top-up and the test stays `draft`. Offer "publish from wallet" (2.4a).

### Publish errors (both 2.4a and 2.4b)

| HTTP | `error` | what to do |
|---|---|---|
| 400 | `test narxi kamida N so'm bo'lishi kerak` | The price is below the current minimum (the admin may have raised it). Open the price editor pre-filled with `suggested_price`, save, then publish again. |
| 402 | `insufficient balance` | offer top-up or card |
| 409 | `test is already published` | refresh; harmless on double-tap |
| 409 | `publish fee is zero — publish directly, no checkout needed` | card only; use 2.4a |
| 403 | `only the test's owner can publish it` / `test is blocked` | |
| 400 | `test has no questions` | |
| 404 | `test not found` | |

---

## 3. After publish

- Status becomes `uploaded`. The test is **unlisted** but anyone with the link/code can
  open and buy it. Sharing = sending the link.
- Adding or removing questions is locked (the fee was per question). Text fixes and
  **price changes are still allowed** (≥ `min_test_price`).
- Every sale credits the owner `floor(price × cashback_percent / 100)`.
- The owner can't buy their own test (`409`). Hide the buy button for them.

## 4. Checklist

- [ ] Read `/api/tests/pricing` on the create screen, never hardcode.
- [ ] Price field pre-filled with `suggested_price`, min = `min_test_price`, no "free" toggle.
- [ ] Always send `price` on `POST`/`PUT /api/tests`.
- [ ] Handle `test narxi kamida …` on save **and** on publish.
- [ ] Publish screen: fee + balance, wallet and card options, poll card status.
