# Upload flow — backend integration & open contract gaps

> Companion to [`customer-test-upload.md`](./customer-test-upload.md) (the authoritative
> client contract) and [`math_native_keyboard_flow.md`](./math_native_keyboard_flow.md).
> This file records **what the redesigned "Yangi yuklash" flow needs from the backend**
> that the current contract does not yet cover, plus which endpoints are already wired.
> No mock data is used anywhere in the client — every screen calls a real endpoint. Where
> an endpoint does not exist yet, it is flagged **⚠️ NEEDS BACKEND** below and the client
> is written against the agreed shape so it lights up the moment the backend ships.

Base URL comes from `Config.apiBaseUrl` (`config/<flavor>.json` → `BASE_URL`), never hardcoded.
All calls go through `ApiClient` (`lib/src/common/service/api_client.dart`) and carry
`Authorization: Bearer <token>` + the `X-Platform / X-App-Version / X-Screen-Name /
X-Function-Name` headers automatically.

---

## 1. Endpoints already wired (no backend change needed)

These are implemented in `lib/src/feature/upload/data/upload_repository.dart` and work today:

| Purpose | Method + path |
|---|---|
| Pricing (per-question price, cashback %, min questions) | `GET /api/tests/pricing` |
| Manual create (draft) | `POST /api/tests` |
| Import dry-run / real (fixed template) | `POST /api/tests/import[?dry_run=true]` |
| Import template download | `GET /api/tests/import/template` |
| Publish quote | `GET /api/tests/:id/publish-quote` |
| Publish from wallet | `POST /api/payments/tests/:id/publish` |
| Publish by card | `POST /api/payments/tests/:id/publish/checkout` |
| Payment status poll | `GET /api/payments/:payment_id/status` |
| My tests (status filter) | `GET /api/tests/my?status=…` |
| Test questions (preview/edit) | `GET /api/tests/:id/questions` |
| Generic file upload (reused for images) | `POST /api/files` → `{ data: { path, url } }` |

The purchase → publish path (§7 of the prompt) is fully covered by the publish/checkout/
poll endpoints and needs nothing new.

### 1.1 ⚠️ `POST /api/tests` text fields are `i18n.Text` objects (verified 2026-09-26)

The backend now unmarshals `name`, `description`, `questions[].text` and
`questions[].options[].text` into Go's `i18n.Text` — a **plain string is rejected with
HTTP 400** (`json: cannot unmarshal string into Go struct field CreateTestRequest.name
of type i18n.Text`). The accepted shape is a locale-keyed object; verified live with a
probe that returned 201:

```json
{
  "name":        { "uz": "Test nomi" },
  "description": { "uz": "Tavsif" },
  "questions": [
    { "text": { "uz": "Savol…" }, "position": 1, "answer_format": "text",
      "options": [ { "text": { "uz": "Javob" }, "position": 1, "is_correct": true, "answer_format": "text" } ] }
  ]
}
```

- GET endpoints (`/api/tests`, `/api/tests/top`, `/api/tests/my`) still return these
  fields as **localized plain strings** resolved via `Content-Language` — read models
  are unaffected. The `POST /api/tests` *response* echoes objects, but the client only
  reads `id/code/status/price` from it.
- Client side: `ManualTestCreateRequest`/`ManualQuestionDto`/`ManualOptionDto`
  (`lib/src/feature/upload/model/manual_test_create_model.dart`) wrap every text as
  `{ "<app locale>": value }` — the key is the language the uploader typed in
  (`Localizations.localeOf`).

---

## 2. Architectural decision: file import becomes **client-side column mapping**

Prompt §2 replaces the fixed-template import with a **client-side mapping wizard** (user
uploads any xlsx/csv, maps columns themselves). This changes how a file-imported test
reaches the backend:

- The client parses the workbook locally (`excel` / `csv` packages), lets the user map
  columns to roles, resolves correct answers, and builds the **same internal question
  list as the manual builder**.
- On confirm, the file path **converges on `POST /api/tests`** (manual create) — it no
  longer calls `POST /api/tests/import`. Nothing uploads until purchase (§7).

Consequences:

- `POST /api/tests/import`, `?dry_run=true`, and the template download are **no longer on
  the user's happy path**. Keep them for backward compat / admin, but the user app will
  stop calling them. (Repository methods stay so nothing breaks.)
- **Embedded images inside the uploaded workbook are NOT extracted client-side.** The
  contract's `photo` / `a_photo…` columns only work through the backend importer. In the
  new flow, images are added per question/option via `POST /api/files` in the review step
  (§4 below). This is an intentional trade-off — real user files rarely embed images.

**No backend change is required for this decision itself** — it only stops calling an
endpoint and starts calling one that already exists. The gaps it exposes are in §3–§5.

---

## 3. ⚠️ NEEDS BACKEND — `POST /api/tests` must accept per-field extras

The manual-create body today (per `customer-test-upload.md` §3.1 and
`manual_test_create_model.dart`) is:

```jsonc
{
  "name": "…", "description": "…", "price": 10000, "is_free": false,
  "category_id": "…",
  "questions": [
    { "text": "…", "position": 1, "options": [
      { "text": "…", "position": 1, "is_correct": true }
    ] }
  ]
}
```

The redesigned flow (math keyboard TeX + images + multi-correct + N options) needs these
**additive** fields. All are optional so old clients keep working:

### 3.1 `answer_format` per question and per option  — ⚠️ NEEDS BACKEND
Each `text` can be either plain text or a **TeX/LaTeX** string (produced by the math
keyboard, §5 of the prompt). Tag which one it is so the reader renders correctly:

```jsonc
{ "text": "\\frac{a}{b}", "answer_format": "latex", "position": 1 }
// answer_format ∈ { "text" (default), "latex" }
```

- Applies to **both** `question.text` and each `option.text` independently.
- If omitted → `"text"` (backwards compatible).
- The reader/solve side must echo `answer_format` back on `GET /api/tests/:id/questions`
  so the app knows whether to render with `flutter_math_fork`.

### 3.2 `photo` / `image_url` per question and per option — ⚠️ NEEDS BACKEND
A question and each option may carry one image. The client first uploads the picked image
via `POST /api/files` (returns `{ path, url }`), then sends the returned **`path`** (or
`url`) on create:

```jsonc
{
  "text": "…", "position": 1, "photo": "/uploads/ab/cd/uuid.png",
  "options": [ { "text": "…", "position": 1, "is_correct": true, "photo": "/uploads/…" } ]
}
```

- Field name to confirm with backend: prefer **`photo`** to match the import template's
  `photo` / `a_photo` convention. If backend stores a full URL instead, accept `image_url`.
- Must be echoed back on `GET /api/tests/:id/questions` (see §6).

### 3.3 Multiple correct options — ⚠️ CONFIRM
Prompt §3 requires **multi-correct where allowed**. The body already supports it (`is_correct`
is per-option), but confirm the backend:
- accepts **more than one** `is_correct: true` in a question, and
- does not silently collapse to single-correct.
If multi-correct is not allowed server-side, the client will hide the checkbox mode.

### 3.4 Arbitrary option count (N options) — ⚠️ CONFIRM
Prompt §3 requires **N options**, not the import cap of 2–6. Confirm `POST /api/tests`
accepts `2..N` options per question (client enforces ≥2). If the backend caps at 6, tell us
the cap so the builder can enforce it inline.

---

## 4. Image upload (reused, no change)

`POST /api/files` (`multipart/form-data`, field `file`) → `{ data: { path, url } }`, already
used by support chat (`support_chat_repository.dart:44`). The upload flow reuses it for
question/option images:

1. `image_picker` → bytes.
2. `uploadRepository.uploadImage(bytes, filename)` → `POST /api/files` → `{ path, url }`.
3. Show the returned `url` as a thumbnail; keep `path` to send in the create body (§3.2).

Host for rendering is derived from `Config.apiBaseUrl` when the returned value is a
relative `/uploads/*` path — never hardcoded.

**Confirm:** any per-file size / mime limits on `POST /api/files` for images (contract §3.2
mentions 5 MB per embedded image on import — assume the same 5 MB here unless told otherwise).

---

## 5. ⚠️ NEEDS BACKEND — editing a draft's questions must accept the same extras

Question/option CRUD (`POST/PUT/DELETE /api/tests/:id/questions…`, contract §5) is the edit
surface reached from the review screen and from **Mening testlarim**. The same additive
fields from §3 (`answer_format`, `photo`) must be accepted on these endpoints too, and the
draft-only add/remove lock (contract §5, `409`) is respected by the client (edit-text and
image swaps stay allowed after publish; add/remove question or option is blocked).

---

## 6. ⚠️ NEEDS BACKEND — `GET /api/tests/:id/questions` must return the extras

For review/preview/solve to render correctly, the questions payload must include, per
question and per option:

```jsonc
{
  "id": "…", "text": "\\int x\\,dx", "answer_format": "latex", "photo": "/uploads/…",
  "options": [
    { "id": "…", "text": "…", "answer_format": "text", "photo": null, "is_correct": true }
  ]
}
```

Without `answer_format` echoed back, the app cannot tell a literal string like `a/b` from a
TeX fraction. Default missing values to `"text"` / `null`.

---

## 7. Pricing / cashback / cost math (no change)

- `GET /api/tests/pricing` → `{ per_question_price, cashback_percent, min_questions }`.
- Publish fee shown before purchase = `per_question_price × question_count`
  (authoritative value comes from `GET /api/tests/:id/publish-quote` → `publish_fee`).
- `min_questions` is **advisory** — the client warns below it, never blocks (matches contract).
- Prices are integral so'm; the client stores/sends so'm (the prompt's "tiyin" note does not
  apply — the backend contract is explicitly so'm).

---

## 8. Summary of asks to the backend team

| # | Ask | Blocking? |
|---|---|---|
| 1 | `answer_format: "text"\|"latex"` on question + option, on **create, edit, and read** | Yes — math keyboard is core |
| 2 | `photo` (path or url) on question + option, on **create, edit, and read** | Yes — images are core |
| 3 | Confirm multiple `is_correct:true` allowed per question | If no → hide multi-correct UI |
| 4 | Confirm max options per question on `POST /api/tests` (N vs 6 cap) | Client enforces the cap |
| 5 | Confirm image size/mime limits on `POST /api/files` | Nice-to-have |

Until #1 and #2 ship, TeX answers round-trip as plain strings and images are dropped on
save. The client is already coded to send/read these fields, so no client change is needed
when the backend adds them.
