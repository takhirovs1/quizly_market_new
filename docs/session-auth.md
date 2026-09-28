# Sessions, refresh & auth — client contract

How customer login, sessions and token refresh behave, and what clients (mobile, web,
Telegram mini app) must send and handle. Backend: `internal/modules/auth`.

- **Base URL:** `/api`
- **Envelope:** success bodies are `{"data": ...}`; errors are `{"error": "..."}`, plus a
  `"code"` on the auth errors listed in §5.
- **Access token:** HS256 JWT, default **60 min**, sent as `Authorization: Bearer <access_token>`.
- **Refresh token:** opaque 64-char hex string, default **7 days**, single-use (rotated on
  every refresh) with a 60 s grace window.
- **Sessions are multi-device:** logging in on one device never logs another out.

---

## 1. Token pair

Every login and every refresh returns the same shape:

```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs…",
    "refresh_token": "9f2c…(64 hex)…",
    "token_type": "Bearer",
    "expires_in": 3600,
    "language": "uz"
  }
}
```

| field | meaning |
|---|---|
| `access_token` | send on every protected call |
| `refresh_token` | store securely; send only to `/auth/refresh` and `/auth/logout` |
| `token_type` | always `"Bearer"` |
| `expires_in` | seconds until `access_token` expires. You can refresh ahead of time using this, but you don't have to (see §4). |
| `language` | the user's saved app language (`uz` \| `ru` \| `en`). Apply it to the UI. |

**Always replace both tokens** with the new pair. The old refresh token is dead once it's
been used (after the 60 s grace window).

---

## 2. Headers to send at login

These are read **only at login** (`/auth/google`, `/auth/apple`, `/auth/telegram`,
`/auth/mobile/verify`). Refresh and normal requests ignore them.

| Header | Required | Value |
|---|---|---|
| `X-Device-ID` | recommended | A UUID your client generates **once per install** and persists. |
| `X-Device-Name` | optional | Human-readable name, e.g. `iPhone 15 Pro`, `Chrome on macOS`. |
| `X-Platform` | optional | `ios` \| `android` \| `web` \| `telegram` |

The server keeps **one session per (user, device id)**. Logging in again on the same
device reuses that session.

If `X-Device-ID` is missing, the server derives a synthetic id (`syn_<32 hex>`) from
user + platform + user agent. That still gives one session per browser, but it changes
whenever the user agent changes (e.g. after a browser update). Send a real persisted id.

> **Do not** generate a new `X-Device-ID` on every launch. Each launch would create
> another session. Nothing gets evicted, so they pile up in the user's session list.

---

## 3. Lifetimes

| Thing | Lifetime | Slides? |
|---|---|---|
| Access token | 60 min (`JWT_TTL`) | no, you get a new one on each refresh |
| Refresh token | 7 days (`JWT_REFRESH_TTL`) | yes, each refresh issues a new 7-day token |
| Session row | 30 days | yes, pushed to now + 30 d on each successful refresh |

**What this means for the user:** a device that opens the app at least once a week
stays logged in forever. A device idle for **more than 7 days** gets `refresh_invalid`
and has to log in again. The session may still show in the list until day 30, but it
can no longer be refreshed.

An access token also stops working **immediately** if its session is revoked or logged
out, even before it expires (`session_revoked`).

---

## 4. Refresh

### `POST /api/auth/refresh` (public)

```json
// request
{ "refresh_token": "9f2c…" }
```

| Result | Status | Body |
|---|---|---|
| success | 200 | token pair (§1) |
| token unknown / already used (outside grace) / expired / session revoked | 401 | `{"error": "refresh token is invalid or expired", "code": "refresh_invalid"}` |
| body missing `refresh_token` | 400 | `{"error": "<validation message>"}` |
| user account deleted | 404 | `{"error": "user not found"}` (no `code`) |
| server error | 500 | `{"error": "..."}` |

**Rotation.** Each refresh token works once. On success, store the new pair and throw
away the old tokens.

**Concurrent refresh is safe.** If several requests refresh with the **same** token at
once (for example, five API calls all hit `token_expired` together), one call rotates
the token. The others, if they arrive within **60 seconds**, get **the same new refresh
token** and a fresh access token instead of a 401. A single-flight lock is still
recommended, because it avoids pointless calls and keeps storage writes consistent.

### Recommended client pattern

1. Send the request with the current access token.
2. On **401 `token_expired`**, refresh (one in-flight refresh shared by all callers),
   save the new pair, and **retry the original request once**.
3. If the refresh fails with **any 401 or 404**, clear tokens and go to login.
4. Never retry a request more than once. Never refresh on `session_revoked` or
   `account_blocked`.

```ts
let refreshing: Promise<void> | null = null;

async function refresh(): Promise<void> {
  refreshing ??= (async () => {
    const res = await fetch("/api/auth/refresh", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: store.refreshToken }),
    });
    if (!res.ok) { store.clear(); goToLogin(); throw new Error("refresh failed"); }
    const { data } = await res.json();
    store.save(data.access_token, data.refresh_token);
  })().finally(() => { refreshing = null; });
  return refreshing;
}

async function api(path: string, init: RequestInit = {}, retried = false): Promise<Response> {
  const res = await fetch(path, {
    ...init,
    headers: { ...init.headers, Authorization: `Bearer ${store.accessToken}` },
  });
  if (res.status === 401 || res.status === 403) {
    const body = await res.clone().json().catch(() => ({}));
    switch (body.code) {
      case "token_expired":
        if (retried) break;
        await refresh();
        return api(path, init, true);
      case "session_revoked":
      case "missing_token":
        store.clear(); goToLogin(); break;
      case "account_blocked":
        showBlockedScreen(); break;
    }
  }
  return res;
}
```

---

## 5. Error codes: how to react

Protected endpoints go through the auth middleware, which **always** returns a `code`.
Branch on `code`, never on the message text.

```json
{ "error": "session revoked, please sign in again", "code": "session_revoked" }
```

| HTTP | `code` | Meaning | Client action |
|---|---|---|---|
| 401 | `missing_token` | No `Authorization` header, or it's malformed | attach the token. If you have none, go to login. |
| 401 | `token_expired` | Access token expired (or bad signature) | **refresh** (§4), then retry once |
| 401 | `session_revoked` | Session is gone: logged out, revoked from another device, expired, or user deleted | **re-login**. Refresh would fail too. |
| 403 | `account_blocked` | Admin blocked this account | show a "blocked" screen. Do **not** refresh or retry. |
| 500 | `server_error` | Session lookup failed | transient. Retry later; don't log the user out. |
| 401 | `refresh_invalid` | (from `/auth/refresh` only) refresh token dead | **re-login** |

Only these responses carry a `code`. Other auth errors (bad Google/Apple/Telegram token,
wrong OTP, link conflicts, etc.) are plain `{"error": "..."}`. Handle those by HTTP status.

---

## 6. Logout

### `POST /api/auth/logout` (public, no bearer needed)

```json
{ "refresh_token": "9f2c…" }
```

- Deletes **this device's whole session** and all its refresh tokens. The current access
  token stops working at once (`session_revoked`).
- **204** with no body, even if the token was already invalid.
- **400** if `refresh_token` is missing or empty. Send whatever you have stored.
- Other devices are unaffected. There is **no "log out everywhere" endpoint**. To sign
  out other devices, revoke them one by one (§7).

After calling it, clear local tokens no matter what the response was.

---

## 7. Sessions (device list)

### `GET /api/auth/sessions` (bearer)

Lists the user's active (unexpired) sessions, most recently used first.

```json
{
  "data": [
    {
      "id": "3b0f7c1e-…",
      "device_id": "a1b2c3d4-…",
      "device_name": "iPhone 15 Pro",
      "platform": "ios",
      "ip_address": "91.213.x.x",
      "user_agent": "Quizly/1.4.0 (iOS 18.1)",
      "created_at": "2026-09-01T08:12:00Z",
      "last_used_at": "2026-09-27T19:40:11Z",
      "expires_at": "2026-10-27T19:40:11Z"
    }
  ]
}
```

- `device_id`, `device_name`, `platform`, `ip_address`, `user_agent` are **omitted** when
  unknown, so treat them as optional.
- `device_id` may be a synthetic `syn_…` value (§2).
- **There is no `is_current` flag.** To mark "This device", compare each `device_id`
  with the `X-Device-ID` you persist locally.
- `last_used_at` updates on login and refresh, not on every API call. Display it as
  "last active ≈".
- Empty list → `"data": []`.

### `DELETE /api/auth/sessions/:id` (bearer)

Revokes one session (logs that device out). That device's next request gets
`401 session_revoked`.

| Status | Body |
|---|---|
| 204 | (none) |
| 400 | `{"error": "invalid session id"}` (not a UUID) |
| 404 | `{"error": "session not found"}` (doesn't exist or belongs to someone else) |

You can revoke your **own current** session this way. That works like logout, so
redirect to login afterwards.

---

## 8. Login endpoints (reference)

All are public, take the §2 headers, and return the token pair (§1).

| Method | Path | Body |
|---|---|---|
| `POST` | `/auth/google` | `{ "id_token": "...", "referral_code"?: "..." }` |
| `POST` | `/auth/apple` | `{ "identity_token": "...", "referral_code"?: "..." }` |
| `POST` | `/auth/telegram` | Mini App: `{ "init_data": "..." }`. Widget: `{ "id", "first_name", "last_name", "username", "photo_url", "auth_date", "hash" }`. Both also take optional `referral_code`. |
| `POST` | `/auth/mobile/verify` | `{ "device_id": "...", "code": "..." }` (Telegram bot OTP login) |

Common failures (no `code` field): `401` bad provider token / `invalid telegram hash` /
`telegram auth data is too old (max 24h)` / `invalid or expired verification code`;
`404 user not found` (mobile verify with no account); `400` missing fields.

> Google, Apple and Telegram logins are **separate accounts** unless the user links
> them. "Logged in on another device" only applies within one account.

### Account linking (bearer)

| Method | Path | Body | Result |
|---|---|---|---|
| `POST` | `/auth/link/google` | same as login | 204 |
| `POST` | `/auth/link/apple` | same as login | 204 |
| `POST` | `/auth/link/telegram` | same as login | 204 |
| `POST` | `/auth/link/telegram/verify` | `{ "device_id", "code" }` | 204 |
| `DELETE` | `/auth/link/:provider` | (none), `provider` = `google` \| `apple` \| `telegram` | 204 |

Errors: `409` already linked to another account / can't remove the last login method;
`404` provider not linked; `400` unknown provider.

---

## Endpoint summary

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/auth/{google,apple,telegram}` | public | login → token pair |
| `POST` | `/auth/mobile/verify` | public | Telegram OTP login → token pair |
| `POST` | `/auth/refresh` | public | rotate refresh token → new pair |
| `POST` | `/auth/logout` | public | delete this device's session |
| `GET` | `/auth/sessions` | bearer | list the user's sessions |
| `DELETE` | `/auth/sessions/:id` | bearer | revoke one session |
| `POST`/`DELETE` | `/auth/link/…` | bearer | link / unlink login providers |
