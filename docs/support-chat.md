# Support chat — client contract

Realtime support chat between a customer and admins. Text, photos (albums), and
replies. Backend: `internal/modules/support` (customer) + `internal/modules/admin`
(admin) over a shared in-memory hub `internal/pkg/chathub`.

- **Send over REST, receive over WebSocket.** You POST a message and also get it back
  live on the socket (along with the other side's messages).
- **The database is the source of truth.** The WebSocket is best-effort live delivery;
  on connect/reconnect you fetch history over REST, so a dropped frame never loses a
  message (see §6).
- **One thread per customer.** A customer has exactly one chat; admins see one thread
  per user.
- **Prod prerequisite:** the reverse proxy must forward the WebSocket upgrade (see §7).

---

## 1. Auth

| Surface | How | Auth |
|---|---|---|
| REST (customer) | `Authorization: Bearer <access_token>` | customer JWT |
| WebSocket (customer) | `?token=<access_token>` in the URL | customer JWT |
| REST (admin) | `Authorization: Bearer <admin_token>` | admin JWT |
| WebSocket (admin) | `?token=<admin_token>&chat_id=<uuid>` | admin JWT |

The WebSocket handshake can't send an `Authorization` header from a browser, so the
token goes in the query string. It is verified exactly like the REST token (signature
+ live session + not blocked). Use your **access** token (short-lived); reconnect with a
fresh one after a refresh.

---

## 2. Customer endpoints

Base URL: `/api`.

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/support/chat` | Get (or lazily create) the caller's thread + metadata |
| `GET` | `/support/messages?limit=&before=` | Message history, chronological |
| `POST` | `/support/messages` | Send a message (text and/or photos, optional reply) |
| `GET` | `/support/ws?token=` | WebSocket: live message + presence events |

**`GET /support/chat`** → `{"data": { "id", "status", "unread_count", "last_message_at",
"last_message", "created_at" }}`. `status` is one of `new` | `waiting` | `solved`.

**`GET /support/messages`** → `{"data": { "chat_id", "messages": [Message, …] }}`,
oldest→newest. Page older by passing `before` = the `created_at` of the oldest message
you already have (RFC3339); `limit` defaults to 20 (max 100).

**`POST /support/messages`** body:
```json
{ "text": "hello", "photo_paths": ["ab12….jpg"], "reply_to_id": "<message-uuid>" }
```
- All three fields optional, but a message must have **text or at least one photo**.
- `photo_paths` are the `path` values returned by the photo upload (see §4), max **10**.
- `reply_to_id` must be a message in **this** chat.
- Returns `201 {"data": Message}` — the persisted message (also delivered on the WS).
- Errors: `400` (empty / too many photos / bad photo / bad reply), `429`
  `{"code":"rate_limited"}` (send throttle).

### The `Message` shape
```json
{
  "id": "<uuid>",
  "chat_id": "<uuid>",
  "sender": "user" | "admin" | "system",
  "text": "hello",
  "photos": [ { "path": "ab12….jpg", "url": "https://…/uploads/ab12….jpg" } ],
  "reply_to": { "id": "<uuid>", "sender": "user", "text_preview": "…", "has_photo": false },
  "created_at": "2026-07-15T10:00:00Z"
}
```
`photos` is always present (empty array if none). `reply_to` is `null` when the message
isn't a reply. Render `photos[].url`; keep `path` only if you need to reference it.

---

## 3. WebSocket

Connect: `GET /api/support/ws?token=<access_token>` (customer) — upgrade to a WebSocket.
You do **not** send anything over the socket; it is receive-only (send via REST). The
server sends JSON frames:

```jsonc
// a new message in your chat (yours or an admin's)
{ "type": "message.created", "data": { "chat_id": "<uuid>", "message": { …Message… } } }

// presence — the customer connected/disconnected (mainly for the admin UI)
{ "type": "presence", "data": { "chat_id": "<uuid>", "role": "user", "online": true } }
```

The server pings every ~54s and expects the browser/library to auto-pong (all standard
WebSocket clients do). Idle connections stay open — do not add your own short timeout.

---

## 4. Sending photos

Photos are uploaded first, then referenced by the message:

1. `POST /api/files` (multipart, field `file`) → `201 {"data": { "path": "ab12….jpg",
   "url": "https://…", … }}`. Repeat per photo (or `POST /api/files/many`, field `files`).
2. `POST /api/support/messages` with `"photo_paths": ["ab12….jpg", "cd34….png"]`
   (the `path` values, **not** the URLs), plus optional `text`.

Only image files are accepted as chat photos (`.png .jpg .jpeg .gif .webp .bmp`).

---

## 5. Admin endpoints

Base URL: `/admin/v1` (admin envelope: success body is raw, errors are
`{"error":"CODE","message":"…"}`).

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/support/chats?status=&search=` | List threads (per user) + unread + online status |
| `GET` | `/support/chats/:id/messages?limit=&before=` | One thread's history (photos + replies) |
| `POST` | `/support/chats/:id/messages` | Reply: `{ text?, photo_paths?[], reply_to_id? }` |
| `PATCH` | `/support/chats/:id` | Set `status` (`new`/`waiting`/`solved`) |
| `GET` | `/support/ws?token=&chat_id=` | WebSocket for the opened conversation |

The admin `Message` shape matches §2 (`sender:"admin"` for replies). Sending a reply
resets that chat's `unread_count` to 0; a customer message increments it and flips a
`solved` chat back to `waiting`.

---

## 6. Reliability & reconnect

- **No message is ever lost.** Every message is persisted before it is broadcast. If the
  socket drops a frame (or you were offline), it's still in the DB.
- **On connect/reconnect:** first `GET /support/messages` for the current history, then
  open the WebSocket and append incoming `message.created` events. De-dupe by message
  `id` (a message you already have from history may also arrive live during the race
  window between the two calls).
- **Auth expiry:** if the socket closes and a reconnect fails auth, refresh the access
  token (see `session-auth.md`) and reconnect with the new one.
- **Scope:** delivery is per server instance (in-memory hub). Correct for the current
  single-instance deployment.

---

## 7. Ops — reverse proxy (WebSocket upgrade)

The app serves the WebSocket at `/api/support/ws` and `/admin/v1/support/ws`. A plain
`proxy_pass` **drops** the upgrade headers, so nginx (or any proxy in front) must be
configured to pass them, e.g.:

```nginx
location /api/support/ws     { proxy_pass http://127.0.0.1:8080; include /etc/nginx/ws_upgrade.conf; }
location /admin/v1/support/ws { proxy_pass http://127.0.0.1:8080; include /etc/nginx/ws_upgrade.conf; }
# ws_upgrade.conf:
#   proxy_http_version 1.1;
#   proxy_set_header Upgrade    $http_upgrade;
#   proxy_set_header Connection "upgrade";
#   proxy_read_timeout 3600s;   # keep long-lived sockets open
```
(Or apply these directives at the site's main `location /`.) Without them the HTTP API
works but WebSocket connections fail to upgrade at the proxy.
