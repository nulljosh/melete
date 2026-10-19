# Melete Technical Whitepaper

**v3.1** | October 2026

Drop an idea in. Watch it ripple.

Most ideas die at the same step. Somebody says "someone should build that," and nobody writes the plan. Melete does the writing. People post ideas, vote on them and argue in the comments. A model writes a build spec and a plan for each idea, and a judge pass throws out the generic ones. Every morning the feed gets one new idea on its own, so it is never empty. It runs at [melete.jaybulb.com](https://melete.jaybulb.com), with iPhone, Mac and Apple Watch apps.

## Core mechanic: write, judge, then plan

An idea is a post with a title, a body, a category, votes and comments. The model adds three things:

- **Generate.** `POST /api/ai?type=generate` calls `callGemma` in `api/ai.js`. The model is `@cf/openai/gpt-oss-120b` on Workers AI, reached through the `AI` binding. The project holds no model API key.
- **Judge.** `judgeIdea` reads each draft again at low temperature, as a cold reader. It rejects generic ideas: a tracker, a list, a dashboard, a marketplace, or a problem with no named group of people. `tooSimilar` rejects a draft that repeats a recent one. If the judge fails or returns nonsense, the draft goes through. A broken judge must not stop the daily idea.
- **Enrich.** `POST /api/ai?type=enrich` writes a spec (what the thing does) and a plan (the steps to build it). A post that has neither gets both.

The feed sorts by New or Trending. Tags and categories filter it. When the database is empty or unreachable, the first page shows a few seed ideas.

## Architecture

- **Web**: plain HTML, CSS and JavaScript with no build step. `index.html` is the landing page and `app.html` is the app. The service worker is network first.
- **API**: Cloudflare Pages Functions. One catch-all route sends each `/api/*` call to a handler in `api/`.
- **Data**: rows in D1 and files in KV, behind the `jaybulb-api` Worker. `api/_lib/spark.js` is the only client.
- **Cron**: Pages cannot hold a schedule. `worker/` is a small Worker that fires at 09:00 UTC and makes two authenticated calls: generate, then enrich the new idea.
- **Auth**: email and password, GitHub OAuth, and Sign in with Apple on the native apps. Sessions are JWTs. Mail goes out through Resend.

## App Store matches

Each brief lists up to three App Store apps that are close to the idea. The browser asks Apple's iTunes Search API for software in the US, using the idea's search terms, with a limit of three. The iPhone and Mac apps make the same call. The lookup runs on the device, so Melete's server never makes it.

## Native apps

iPhone, Mac and Watch all use the same API. The iPhone app keeps its token in the Keychain and asks for Face ID or Touch ID. The Watch app reads the feeds, votes and posts ideas, and keeps the last feed for reading offline. iPhone and Mac both have widgets for Hot, New and Stats.

## Security

- Every route checks the caller before it touches storage. Storage calls use a service key that only the server holds.
- Posting is limited to 10 a minute per IP for accounts without Pro. Comments and password reset have their own limits.
- A link on an idea must be `http` or `https`, because the value is rendered as a link.
- Stripe webhooks are checked against their signature before any account changes.

## Money

The web offers a $1 one-time Pro unlock through Stripe, for unlimited posts and a 24-hour pin. The native apps sell nothing.

## Platforms

| Platform | Version | Status |
|---|---|---|
| Web | 3.1 | Live on Cloudflare Pages |
| iPhone | 3.1 | 3.0 live on the App Store. 3.1 in review |
| Mac | 3.1 | 3.0 live on the Mac App Store. 3.1 in review |
| Apple Watch | 2.2.0 | Ships inside the iPhone app |

## License

MIT 2026 Joshua Trommel. See [LICENSE](LICENSE).
