# Flashcard mode — backend reply

Reply to the client's "Flashcard mode — backend contract". Both endpoints are
live as described below. You can switch `FlashcardRepositoryImpl.getCards` over.

Base `/api`, `Authorization: Bearer <access_token>` on both, standard envelope
(`{ "data": ... }` / `{ "error": "..." }`). Language follows the usual
`Accept-Language` / `?lang=` handling.

## 1. `GET /api/flashcards/{testId}`

| Param     | Meaning |
| --------- | ------- |
| `start`   | **0-based inclusive** start. Omitted = 0. |
| `end`     | **0-based exclusive** end. Omitted = to the end. `end == start` gives an empty deck. |
| `count`   | First N cards (same as `start=0&end=N`). Don't send it together with `start`/`end` (400). |
| `shuffle` | `true` = server shuffles the card order. Anything else = deck order. |
| `source`  | Echoed back as `source`; defaults to `"custom"`. |

The range is the same `[start, end)` your slider produces, so **no conversion
is needed**. `start` past the end of the deck gives `200` with `"cards": []`.
Negative or non-numeric values, or `end < start`, give `400`.

```json
{
  "data": {
    "test_id": "9f3c…",
    "title": "O'zbekiston tarixi",
    "source": "custom",
    "total": 100,
    "cards": [
      {
        "id": "5b0e…",
        "front": "Temuriylar davlatiga kim asos solgan?",
        "back": "Amir Temur",
        "explanation": "1370-yilda Movarounnahrda hokimiyatni qo'lga kiritgan.",
        "image_url": null,
        "back_image_url": null,
        "options": [
          { "id": "a1…", "text": "Amir Temur", "image_url": null },
          { "id": "a2…", "text": "Bobur", "image_url": "/uploads/…png" }
        ],
        "correct_option_id": "a1…"
      }
    ]
  }
}
```

- `id` is the question UUID. It stays the same across calls, so you can use it as the known/unknown key.
- `back`: every correct option's text, one per line (`\n`) when there are several. All questions are multiple-choice today, so `back` is never empty when the test has a correct answer marked.
- `back_image_url`: the photo of the first correct option that has one. `null` otherwise.
- `explanation` comes from the new `questions.explanation` field. It's `null` when the author didn't write one.
- `options[]` has no `is_correct` flags. `correct_option_id` is the first correct option. Both are omitted when a question has no options.
- `total` is the full deck size before the range is applied.
- Text is sent raw, and LaTeX is never escaped. Images can be an absolute URL, an `/uploads/…` path or a bare filename, as before.
- Errors: `403` when the test isn't available to the user, and also when the user **hasn't bought a paid test** (`"test not purchased"`). The preview has no answers, so there's nothing to make cards from. `404` when the test doesn't exist.

## 2. `POST /api/flashcards/{testId}/result` (customers)

The body is exactly as in your §3.2. Card ids must be UUIDs, which means the card `id` values above.

- `mode`: `study` or `test`. Defaults to `study`.
- `direction`: `questionFirst` or `answerFirst`. Defaults to `questionFirst`.
- An id sent in both lists counts once, as known. The two lists can hold at most 5000 ids together.

Response is `201`:

```json
{ "data": { "session_id": "c7d2…", "accuracy": 0.75 } }
```

`accuracy` = known / (known + unknown), and `0` when both lists are empty. Sessions
are stored for history only. They **don't** create test attempts and don't change
points, streaks, the daily goal or the leaderboard.

## 3. Answers to your §5

1. **Ordering:** stable. The deck and `GET /tests/{id}/questions` both order by question position, then id.
2. **Non-MCQ answers:** there are no open questions in the data model. Every question has options, and `back` is built from the correct one(s).
3. **Explanations:** yes. There's a new `explanation` field, filled in where the author wrote one. Authors can set it on manual create/edit, in the xlsx template (new optional `explanation` column), in JSON import and in the admin panel. It's also returned on `GET /tests/{id}/questions` for entitled viewers, but never in the preview.
4. **Range convention:** the new endpoint uses 0-based `[start, end)`, same as the client. `tests/{id}/questions?range=` stays 1-based inclusive.
5. **Result persistence:** stored, but kept separate from attempts (see §2).
6. **Auth & envelope:** same as the rest of `/api`.
