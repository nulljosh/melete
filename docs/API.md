# Melete API

Base URL: `https://melete.jaybulb.com`

One Cloudflare Pages Function, `functions/api/[[route]].js`, takes every `/api/*` request and hands it to the matching handler in `api/`. Responses are JSON. Errors look like `{ "error": "message" }` with the matching status code.

CORS allows only `https://melete.jaybulb.com`. Server-to-server calls are not affected by that.

## Authentication

Log in, then send the token as a bearer header.

```bash
TOKEN=$(curl -s -X POST https://melete.jaybulb.com/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"you","password":"..."}' | jq -r .token)

curl -H "Authorization: Bearer $TOKEN" https://melete.jaybulb.com/api/notifications
```

Routes marked **auth** return `401` without a token. Two routes are rate limited and return `429` when the limit is hit:

- `POST /api/posts`: 10 a minute per IP, for accounts that are not Pro.
- `POST /api/comments`: 10 a minute per IP.

## Ideas

### `GET /api/posts`

Public. Query: `limit`, `offset`. Returns `{ posts: [...] }`. If the database is empty or unreachable, the first page falls back to a few seed ideas, so this route does not 500.

### `GET /api/posts/:id`

Public. Returns `{ post }`, or `404` if the idea does not exist.

### `POST /api/posts`: auth

```json
{ "title": "...", "content": "...", "category": "...", "linked_repo": "https://..." }
```

`title` is at most 200 characters. `content` is at most 5000. `linked_repo` is optional, and it must be an `http(s)` URL. Other schemes are rejected, because the value is rendered into an `href`.

### `DELETE /api/posts/:id`: auth

Deletes one of your own ideas. Deleting someone else's idea returns `403`.

### `POST /api/posts/:id/vote`: auth

Body: `{ "voteType": "up" }` or `{ "voteType": "down" }`. Returns `{ post }` with the new score. Any other value returns `400`.

## Comments

- `GET /api/comments?post_id=:id` returns `{ comments }` for one idea. Public.
- `GET /api/comments?post_ids=1,2,3` returns `{ counts }` for many ideas at once. Public.
- `POST /api/comments`: auth, rate limited. Body `{ "post_id": "...", "content": "..." }`. Returns `201` with `{ comment }`.

There is no route to edit or delete a comment.

## Accounts

### `POST /api/auth/register`

Body: `username`, `email`, `password`. Creates the account and sends a verification email. Returns `201`.

### `POST /api/auth/login`

Body: `username`, `password`. Returns `{ token, username, userId }`.

### `GET /api/auth/verify-email?token=...`

Opened from the link in the verification email. It redirects to the site with `?verified=1` or `?verified=0`. It is not called by apps.

### `POST /api/auth/password-reset?action=forgot`

Body: `username` or `email`. Always answers `200` with a generic message, so it cannot be used to find out which accounts exist. Limited to 5 a minute per IP.

### `POST /api/auth/password-reset?action=reset`

Body: `token`, `password`. Sets the new password. Limited to 10 a minute per IP.

### `POST /api/auth/apple`

Body: `identityToken`, plus optional `fullName` and `email`. Verifies a Sign in with Apple token from the native apps. Returns `{ token, username, userId }`, the same shape as login. The token's audience must match the app's bundle ID.

### `GET /api/auth/github`

Redirects to GitHub to start OAuth. Returns `501` if `GITHUB_CLIENT_ID` is not set.

### `GET /api/auth/github-callback`

Where GitHub sends the user back. The callback is registered on `melete.jaybulb.com`, which still serves it. Older app builds call that host too, so keep it up.

### `POST /api/auth/delete-account`: auth

Deletes the signed-in account and its data.

### `GET /api/user?username=:name`

Public profile. Returns `{ user, posts }`, where `user` has `username`, `userId`, `joinedAt`, `postCount`, `totalUpvotes` and `avatarUrl`. Returns `404` if the user does not exist.

### `GET /api/users`

Public list of users. Returns `{ users, count }`.

### `POST /api/avatar`: auth

Body: `{ "image": "<base64>" }`. Images over 2 MB are refused with `400`. Returns `{ ok, avatarUrl }`.

### `GET /api/notifications`: auth

Returns `{ notifications }`.

### `PATCH /api/notifications`: auth

Body: `{ "id": "..." }` to mark one notification read, or `{ "markAll": true }` to mark them all. Returns `{ ok: true }`.

## AI

Every `/api/ai` call is routed by `?type=`. Unknown types return `400`.

### `POST /api/ai?type=generate`

Writes one new idea as the author `gemma`. This is the call the daily cron makes. It needs the daemon secret as a bearer token, `Authorization: Bearer $SPARK_DAEMON_SECRET`. Returns `201` with `{ post }`.

A draft that the judge calls generic, or that repeats a recent title, is not posted. The call returns `422` with the reason.

### `POST /api/ai?type=enrich`

Body: `{ "id": "..." }`. Writes the spec and the build plan for that idea. Accepts the daemon bearer token or a signed-in user's token. Returns `422` if the model's answer cannot be read.

### `GET /api/ai?type=idea-base`

Public. Returns `{ ideaBases }`, the newest 50 by default. Use `offset` to page.

### `POST /api/ai?type=idea-base`: auth

Body: `topic`, at most 200 characters. Asks the model for a cluster of ideas around one topic.

### `GET /api/ai?type=notes&id=:id`

Public. Downloads one idea as a Markdown file, with its spec and plan.

### `GET /api/ai?type=rfs`

Public. Returns `{ rfs, cachedAt }`, a list of current Y Combinator Requests for Startups. The list is cached. If the source is down, the last good copy is served. `502` only if nothing has ever been cached.

## Pro

### `GET /api/stripe?action=status`: auth

Returns `{ isPro }`.

### `POST /api/stripe?action=checkout`: auth

Returns `{ url }`, a Stripe Checkout page for the one-time Pro unlock.

### `POST /api/stripe-webhook`

Stripe calls this. The signature is checked before anything happens. A completed checkout marks the account Pro. Clients do not call it.

## Health

### `GET /api/health`

Says whether password reset and verification mail can go out. It sends nothing. Returns `{ ok, binding, resend }`, with `200` when mail can go out and `503` when it cannot. A live Resend key is the usual reason for `503`.

## WebMCP

With the app open, Melete registers tools on `document.modelContext`. Each one reuses the token already in `localStorage`. Source: `webmcp.js`.

### Read-only

| Tool | Does |
|---|---|
| `search_ideas` | List ideas. Filter by `query`, `category`, `limit`, `offset` |
| `get_idea` | One idea with its comments |
| `get_comments` | Comments on one idea |
| `get_notifications` | The signed-in user's notifications |
| `whoami` | Who is signed in, if anyone |

### Reversible writes

| Tool | Does |
|---|---|
| `vote_idea` | Upvote or downvote |
| `post_comment` | Comment on an idea |

### Requires human confirmation

| Tool | Does |
|---|---|
| `submit_idea` | Publishes a new idea publicly under the user's name |
| `delete_idea` | Permanently deletes one of the user's own ideas |
