# Flashcard mode — backend contract

> **For the backend developer.** This document is the complete request from the
> Flutter client. It describes (1) how flashcards work today on top of the
> existing `tests` APIs, and (2) the **dedicated flashcard endpoints we are
> asking you to build**. Please implement the endpoints in
> [§3](#3-what-we-need-you-to-build-dedicated-flashcard-endpoints), then send
> back your own short spec (final URLs, auth notes, any field renames) so we can
> flip the client from the stop-gap wiring to the real endpoints.

Flashcard mode lets a user revise a test as a deck of cards instead of a graded
quiz. From a test's **mode selection screen** the user taps **Flashcard**, lands
on the **setup screen** (pick card range, order, direction), taps **Boshlash**,
studies the deck (flip to see the answer, swipe right = *known* / left = *unknown*),
and finishes on the shared **test result screen**.

```
test mode screen ──► flashcard setup ──► flashcard session ──► test result
    (Flashcard)        range / order        flip + swipe        known→correct,
                        direction                                unknown→wrong
```

**Conventions used throughout this doc**

- **Base URL:** `/api`. Every request requires `Authorization: Bearer <access_token>`.
- **Envelope:** success → `{ "data": ... }`; failure → `{ "error": "..." }` with a
  non-2xx status. The client unwraps `data` automatically (`FlashcardResponseModel.fromJson`).
- **Empty result is not an error:** an empty deck must return `200` with
  `"cards": []`, **not** `404`.

---

## 1. How it works today (stop-gap — no new backend needed to run)

The client is **not mocked**. It already builds flashcards from the existing
test endpoints that the solving flow uses, so the feature is functional right now:

| Step    | Endpoint used today                               | Via                                   |
| ------- | ------------------------------------------------- | ------------------------------------- |
| Setup   | `GET /api/tests/{id}`                              | `TestView.getTestDetail`              |
| Session | `GET /api/tests/{id}/questions?range={start-end}` | `TestViewRepository.getTestQuestions` |

Each returned `question` is mapped to a card (`FlashcardRepositoryImpl._toCard`):

- `front` ← `question.text`, front image ← `question.photo_url`
- `back` ← the **correct option(s)** text joined by newlines
  (`options[].is_correct == true`), answer image ← the first correct option's `photo_url`
- `options` / `correct_option_id` are carried through for a future multiple-choice sub-mode.

The `range` the client sends is **1-based inclusive** (e.g. `"11-50"`), converted
from the 0-based, end-exclusive `[start, end)` slice the setup slider produces.

**Why this is only a stop-gap — the gaps we need you to close:**

1. **No real answer for non-MCQ questions.** The back is reconstructed from the
   correct options. Open questions (no options) end up with an **empty answer side**.
2. **No explanations.** `tests/{id}/questions` has no `explanation` field, so the
   answer-side note is always empty.
3. **No deck title from the API.** The client passes the test name through the
   route (`testName`) instead of getting it from the deck response.
4. **Over-fetching.** We download every option + the `is_correct` flags just to
   derive one answer string — this leaks the full answer key for every card.
5. **Ordering is assumed stable.** The range slider relies on
   `tests/{id}/questions` returning questions in a consistent order across calls.
   Please confirm this holds (see [§5](#5-open-questions-please-confirm)).

---

## 2. Rich content: image & LaTeX (must keep working)

Flashcards render the **same** rich content as the solving screen. Whatever you
return for the dedicated endpoint must preserve both:

- **Images** — any `*_image_url` / `photo_url` is passed to the client's
  `QuestionImageWidget`, which resolves the value against `Config.apiBaseUrl`
  (served under `/uploads/`). You may send **any** of:
  - an absolute URL — `https://cdn.quizly.../q.png`
  - an absolute path — `/uploads/q.png`
  - a bare filename — `q.png`

  Use `null` or `""` for "no image". All four forms are handled.
- **LaTeX** — `front`, `back`, and `explanation` may contain raw TeX
  (`\frac{a}{b}`, `x^2`, `180^\circ`, `\text{...}`, mixed text + math). The client
  **auto-detects** and renders it with `LatexTextWidget` (`flutter_math_fork`).
  **No special flag is needed** — just send the raw string in the normal text
  field, exactly as the solving endpoint already does. Do **not** HTML-escape or
  pre-render it.

---

## 3. What we need you to build (dedicated flashcard endpoints)

### 3.1 Get the deck — `GET /api/flashcards/{testId}`

Returns the cards for a test, already shaped as flashcards (front/back/explanation),
so the client does not have to reconstruct answers from options.

**Query parameters** (all optional)

| Param     | Type   | Meaning                                                                             |
| --------- | ------ | ----------------------------------------------------------------------------------- |
| `start`   | int    | 0-based inclusive start of the card range. Omitted ⇒ from the beginning.            |
| `end`     | int    | 0-based **exclusive** end of the range. Omitted ⇒ to the end. `end - start` = count.|
| `count`   | int    | Alternative to `start`/`end` — just "give me N cards". (We send one scheme or the other.) |
| `shuffle` | bool   | `true` ⇒ server may shuffle. Today we shuffle client-side; honoring this is optional. |
| `source`  | string | Free-form origin hint (`custom`, `university`, …). Optional.                        |

> **Range semantics must match [§1](#1-how-it-works-today--stop-gap--no-new-backend-needed-to-run).**
> The client thinks in 0-based `[start, end)`. If your endpoint is 1-based
> inclusive instead, **say so in your reply** and we'll adjust the client — do not
> silently differ.

**Response** (parsed by `flashcard_response_model.dart`)

```json
{
  "data": {
    "test_id": "9f3c-…",
    "title": "O'zbekiston tarixi",
    "source": "custom",
    "total": 100,
    "cards": [
      {
        "id": "q_123",
        "front": "Temuriylar davlatiga kim asos solgan?",
        "back": "Amir Temur",
        "explanation": "1370-yilda Movarounnahrda hokimiyatni qo'lga kiritgan.",
        "image_url": null,
        "back_image_url": null,
        "options": [
          { "id": "o_1", "text": "Amir Temur", "image_url": null }
        ],
        "correct_option_id": "o_1"
      }
    ]
  }
}
```

**Field reference** — accepted key(s) in **bold**, aliases the client also reads
in parentheses:

| Field                                   | Required | Notes                                                                 |
| --------------------------------------- | -------- | --------------------------------------------------------------------- |
| **`test_id`** (`id`)                    | yes      | Echo back the test id. Either key is accepted.                        |
| **`title`** (`name`)                    | yes      | Deck title shown in the header & result screen.                       |
| `source`                                | no       | Free-form (`custom`, `university`, …). Defaults to `"custom"`.         |
| `total`                                 | no       | Full deck size **before** range slicing. Display only.                |
| **`cards[].id`**                        | yes      | Stable, unique per card. This is the known/unknown key — must be consistent across calls. |
| **`cards[].front`** (`text`)            | yes      | Question side. May contain **LaTeX**.                                 |
| **`cards[].back`** (`answer`)           | yes      | Answer side. May contain **LaTeX**. For open questions, send the real answer here. |
| `cards[].explanation`                   | no       | Optional note shown under the answer. May contain LaTeX.              |
| `cards[].image_url` (`photo_url`)       | no       | Front (question) image. `null`/absent ⇒ no image.                     |
| `cards[].back_image_url` (`answer_image_url`) | no | Answer image. `null`/absent ⇒ no image.                               |
| `cards[].options`                       | no       | Only for a future multiple-choice sub-mode. Omit if not needed.       |
| `cards[].options[].id` / `.text` / `.image_url` (`photo_url`) | — | Per-option fields when `options` is present.               |
| `cards[].correct_option_id`             | no       | Required **only** when `options` is present.                          |

Notes:
- `total` + `cards` lets the UI show "card 12 of 100" even when a range is loaded.
- Empty deck ⇒ `200` with `"cards": []` (client shows a "no cards" state). Never `404`.

### 3.2 Save the session result — `POST /api/flashcards/{testId}/result` *(optional)*

Right now the result is computed **client-side** and shown on the shared
test-result screen (known → correct, unknown → wrong, no "skipped"). This endpoint
is only needed if you want flashcard study sessions persisted to attempt history.

**Request body** (sent by `FlashcardResultRequestModel.toJson`)

```json
{
  "mode": "study",
  "direction": "questionFirst",
  "total": 40,
  "known_ids": ["q_123", "q_125"],
  "unknown_ids": ["q_124"],
  "duration_sec": 212
}
```

| Field          | Type     | Meaning                                                          |
| -------------- | -------- | ---------------------------------------------------------------- |
| `mode`         | string   | `"study"` or `"test"` (future MCQ sub-mode).                     |
| `direction`    | string   | `"questionFirst"` or `"answerFirst"` — which side showed first.  |
| `total`        | int      | Number of cards in the session.                                  |
| `known_ids`    | string[] | Card ids the user swiped **right** (knew).                       |
| `unknown_ids`  | string[] | Card ids the user swiped **left** (didn't know).                 |
| `duration_sec` | int      | Session length in seconds.                                       |

**Response**

```json
{ "data": { "session_id": "sess_…", "accuracy": 0.95 } }
```

`accuracy` is `0..1`. The client does **not** block navigation on this call — it
fires and forgets, so a slow or failing result endpoint never breaks the UX.

---

## 4. Client model map (for your reference)

So you can see exactly how each JSON key lands in the app:

| JSON key                        | Dart field (`flashcard_response_model.dart`) |
| ------------------------------- | -------------------------------------------- |
| `data.test_id` / `data.id`      | `FlashcardResponseModel.testId`              |
| `data.title` / `data.name`      | `FlashcardResponseModel.title`               |
| `data.source`                   | `FlashcardResponseModel.source`              |
| `data.total`                    | `FlashcardResponseModel.total`               |
| `data.cards[]`                  | `FlashcardResponseModel.cards`               |
| `cards[].id`                    | `FlashcardCardModel.id`                      |
| `cards[].front` / `.text`       | `FlashcardCardModel.front`                   |
| `cards[].back` / `.answer`      | `FlashcardCardModel.back`                    |
| `cards[].explanation`           | `FlashcardCardModel.explanation`             |
| `cards[].image_url` / `.photo_url`           | `FlashcardCardModel.imageUrl`   |
| `cards[].back_image_url` / `.answer_image_url` | `FlashcardCardModel.backImageUrl` |
| `cards[].options[]`             | `FlashcardCardModel.options`                 |
| `cards[].correct_option_id`     | `FlashcardCardModel.correctOptionId`         |

All string fields are read defensively (`?.toString()`), empty strings are
treated as `null` for images/explanation, and numeric fields accept JSON number
or numeric string.

---

## 5. Open questions (please confirm)

1. **Deck ordering** — does `GET /tests/{id}/questions` (and the new flashcard
   endpoint) return cards in a **stable order** across calls, so `start`/`end`
   address the same cards every time? The range slider depends on this.
2. **Answer for non-MCQ questions** — for open/no-option questions, will `back`
   carry the real answer? (Today it's empty because we derive it from options.)
3. **Explanations** — can you populate `explanation`, either on the new endpoint
   or by adding it to the questions payload?
4. **Range convention** — is your `start`/`end` 0-based `[start, end)` like the
   client, or 1-based inclusive like `tests/{id}/questions`? Tell us which.
5. **Result persistence** — should flashcard sessions create attempt history, or
   stay client-side only? If persisted, confirm the §3.2 contract.
6. **Auth & envelope** — confirm the endpoints use the same
   `Authorization: Bearer` + `{ "data": ... }` envelope as the rest of `/api`.

---

## 6. Handoff checklist

- [ ] `GET /api/flashcards/{testId}` implemented per [§3.1](#31-get-the-deck--get-apiflashcardstestid)
- [ ] `back` returns the real answer for **all** question types (incl. open)
- [ ] `explanation` populated where available
- [ ] Images sent as URL / path / filename; LaTeX sent raw/unescaped
- [ ] Empty deck → `200 { "cards": [] }` (not `404`)
- [ ] Stable card ordering confirmed
- [ ] (optional) `POST /api/flashcards/{testId}/result` per [§3.2](#32-save-the-session-result--post-apiflashcardstestidresult-optional)
- [ ] Reply with final URLs + answers to [§5](#5-open-questions-please-confirm)

Once you send your spec back, the client switch is a single change in
`FlashcardRepositoryImpl.getCards` (call `/api/flashcards/{testId}` directly
instead of mapping `tests/{id}/questions`) — the models above are already in place.
