# Architecture

Melete is an idea forum. People post ideas, vote and comment. A model writes a build spec and a plan for each idea, and a daily cron adds a new idea on its own. The web app is plain HTML, CSS and JavaScript with no build step. The iPhone, Mac and Apple Watch apps talk to the same API. Rows live in D1 and files in KV, behind the `jaybulb-api` Worker.

## How it runs

1. A visitor lands on `index.html`. The app itself is `app.html`.
2. The app calls `/api/*`. One Pages Function, `functions/api/[[route]].js`, sends each path to a handler in `api/`.
3. Handlers read and write rows through the `jaybulb-api` Worker, using `api/_lib/spark.js`. Email goes out through Resend.
4. The AI paths run `@cf/openai/gpt-oss-120b` on Workers AI through the `AI` binding. `callGemma` in `api/ai.js` makes the call.
5. The cron Worker in `worker/` fires at 09:00 UTC. It asks for one new idea, then asks for that idea's spec and plan.

## Top level

| Path | What it does |
|---|---|
| `index.html` | Landing page. Hero, feature list, links to the app and the App Store. |
| `app.html` | The web app. Feed with sort and filters, post detail with votes and comments, create, profile, settings, the $1 Pro unlock, App Store matches in each brief, and a trademark check for brief names. |
| `user.html` | Public profile page for one user. |
| `reset.html` | Password reset page. Reads the token from the email link. |
| `tos.html`, `support.html` | Terms of service and support. Static pages. |
| `theme.js` | Light and dark theme for every page. The choice is saved in `spark_theme`. Dark is the default. Loads in every `<head>`. |
| `onboarding.js` | First-run carousel. Loaded by `app.html` only. |
| `webmcp.js` | Registers the WebMCP tools for agents. Loaded by `app.html`. See [API.md](API.md#webmcp). |
| `sw.js` | Service worker. Network first. The cache is only the offline fallback for the shell. |
| `tokens.css` | Design tokens for the pages. A vendored copy, not an import. |
| `devices.css` | Device frame styles. Copied into `dist/`, but no page loads it. Candidate for removal. |
| `manifest.json` | PWA manifest. |
| `favicon.svg`, `favicon-32.png`, `apple-touch-icon.png`, `icon.svg`, `icon-192.svg`, `icon-512.svg`, `mark.svg` | Icons. `scripts/make-appicon.sh` builds the app icon PNGs from `icon.svg`. |
| `Melete.icon` | Icon Composer bundle for the app icon. |
| `wrangler.toml` | Pages project settings. Project name `sparkjar`, output `dist`, the `AI` binding, and public variables such as `APPLE_CLIENT_ID`. Secrets are not stored here. |
| `static/_headers` | Security headers for Pages. |
| `package.json` | npm scripts: `test`, `build`, `dev`, `deploy`. The `name` field still reads `hikko`. |
| `vitest.config.js` | Test runner config. |
| `api/` | Backend handlers. See below. |
| `functions/` | Pages Functions adapter and the single `/api/*` route. |
| `worker/` | Cron Worker. |
| `ios/` | iPhone app. |
| `macos/` | Mac app. |
| `watchos/` | Apple Watch app. Ships inside the iOS app. |
| `widgets-ios/`, `widgets-macos/` | Home Screen widgets for iPhone and Mac. |
| `kmp/` | Kotlin Multiplatform client. Not shipped. |
| `scripts/` | Build, icon, screenshot and maintenance scripts. |
| `tests/` | Vitest suite. |
| `brand/` | Brand notes, tokens and icon files. |
| `metadata/` | App Store listing copy, kept by version. |
| `screenshots/` | Screenshots for iOS and macOS. |
| `launch/` | Launch post drafts. Some still describe the old stack, so check them before posting. |
| `public/` | Not copied by the build, so Pages never serves it. |
| `dist/` | Build output from `scripts/build-static.sh`. Not committed. |
| `docs/` | This file, [API.md](API.md), and a ranked list of the ideas on the board. |
| `README.md`, `WHITEPAPER.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE`, `CHANGELOG.md`, `roadmap.md`, `MONEY.md` | Project docs. `AGENTS.md` is a symlink to `CLAUDE.md`. |
| `architecture.svg`, `progress.svg` | Diagrams for the README. |

## Backend (`api/`)

Each file is a handler. `functions/api/[[route]].js` maps the URL to it. Every route is listed in [API.md](API.md).

| File | What it does |
|---|---|
| `posts.js` | Ideas: list, one, create, delete, vote. Falls back to seed ideas when the database is empty or unreachable. Exports `parseToken`, which the AI handlers use. |
| `comments.js` | Comments: list for one idea, counts for many, create. |
| `ai.js` | Routed by `?type=`. `generate` writes one idea, `enrich` writes a spec and plan, `idea-base` clusters ideas around a topic, `notes` exports one idea as Markdown, `rfs` lists Y Combinator's current requests. `callGemma` runs the model. `judgeIdea` rejects generic drafts. `tooSimilar` rejects repeats. |
| `auth.js` | Router for `/api/auth/:action`. Hands each action to its file in `_lib/auth/`. |
| `user.js` | Public profile by username, with that user's ideas. |
| `users.js` | Public list of users. |
| `avatar.js` | Avatar upload from base64 images up to 2 MB. |
| `notifications.js` | List notifications, mark them read. |
| `stripe.js` | Pro status and the Stripe Checkout link for the $1 unlock. |
| `stripe-webhook.js` | Stripe events. A completed checkout sets `is_pro`. The signature is checked first. |
| `health.js` | Says whether mail can go out. Sends nothing. |

### `api/_lib/`

| File | What it does |
|---|---|
| `spark.js` | Client for the `jaybulb-api` Worker. Sends the service key on every call. `SPARK_API_URL` overrides the default host. |
| `store.js` | Accounts, password hashing (bcrypt), JWT sessions (7 days), and the tokens for verification and reset. |
| `ratelimit.js` | Per-IP limits for posting, commenting and password reset. |
| `mail.js` | Sends mail through Resend. |
| `mail.selfcheck.js`, `auth/apple.selfcheck.js`, `auth/verify-email.selfcheck.js` | Manual checks for mail, Sign in with Apple and verification. The test runner does not pick them up. |
| `auth/register.js` | Create an account and send the verification email. |
| `auth/login.js` | Username and password. Returns a token. |
| `auth/password-reset.js` | `?action=forgot` sends the reset link. `?action=reset` sets the new password. |
| `auth/verify-email.js` | Opened from the email link. Marks the account verified, then redirects. |
| `auth/apple.js` | Verifies a Sign in with Apple identity token from the native apps. |
| `auth/github.js` | Starts GitHub OAuth. |
| `auth/github-callback.js` | Finishes GitHub OAuth. Runs on `hikko.jaybulb.com`, which must stay up for older app builds. |
| `auth/delete-account.js` | Deletes the signed-in account. |

## Web function entry (`functions/`)

| File | What it does |
|---|---|
| `functions/_adapter.js` | Turns a Node-style `(req, res)` handler into a Pages Function response. This is why `api/` handlers look like Node handlers. |
| `functions/api/[[route]].js` | The one `/api/*` route. Maps the path to a handler, sends CORS headers, and returns `404` for unknown paths. |

## Cron (`worker/`)

| File | What it does |
|---|---|
| `worker/worker.js` | Runs at 09:00 UTC. Calls `POST /api/ai?type=generate`, then `POST /api/ai?type=enrich` for the new idea. It holds no logic of its own. A `fetch` handler runs the same job by hand, behind the same secret. |
| `worker/wrangler.jsonc` | Worker name `sparkjar-cron`. Cron `0 9 * * *`. Set `SPARK_DAEMON_SECRET` on it with `wrangler secret put`. It must match the Pages value. |

Only the new idea gets enriched. Older posts without a spec are filled in by `scripts/backfill-enrich.sh`, which is run by hand.

## iPhone (`ios/`)

Generated with `xcodegen generate` from `project.yml`. Targets iOS 17 and later.

| Path | What it does |
|---|---|
| `SparkApp.swift` | App entry point. |
| `ContentView.swift` | Root view. Holds the feed, create, profile and sign-in sheet, plus the shared card and button styles. |
| `TutorialView.swift`, `WhatsNewSheet.swift` | First-run tour and the what's new sheet. |
| `View+Glass.swift` | Glass material modifier used on floating controls. |
| `API/SparkAPI.swift` | HTTP client for the API. |
| `API/KeychainHelper.swift` | Stores the sign-in token in the Keychain. |
| `Models/` | `Post`, `Comment`, `User`, `UserProfile`, `IdeaBase`, `RFSEntry`, and `AppState`, the shared observable state. `AppState` also runs the Face ID or Touch ID check. |
| `Views/PostDetailView.swift`, `Views/CommentsView.swift`, `Views/IdeaBaseView.swift` | Post detail with votes, threaded comments, and Idea Bases. |
| `Views/AppStoreMatches.swift` | Looks up the closest App Store apps for a brief, from the iTunes Search API. |
| `SparkTests/` | Unit tests for models, API client, voting and app state. |
| `UITests/` | Screenshot capture for App Store listings, through fastlane snapshot. |
| `fastlane/` | Metadata in `metadata/en-US/` and screenshot config. |
| `scripts/` | `appstore-shots.sh` captures screenshots with simctl. `simplify.sh` creates the standard folders. |
| `Info.plist`, `PrivacyInfo.xcprivacy`, `Spark.entitlements` | App configuration and privacy manifest. |

## Mac (`macos/`)

Also generated from `project.yml`. Targets macOS 14 and later.

| Path | What it does |
|---|---|
| `SparkApp.swift` | App entry point. |
| `ContentView.swift` | Sidebar with Feed, Create and Profile. Shows the sign-in sheet when signed out. Keyboard shortcuts for a new post and refresh. |
| `Views/FeedView.swift` | Idea grid with pull to refresh. |
| `Views/PostDetailView.swift`, `Views/CommentsView.swift`, `Views/IdeaBaseView.swift` | Post detail, comments and Idea Bases. |
| `Views/AppStoreMatches.swift` | Same App Store lookup as iPhone. |
| `Views/CreateView.swift` | New idea form. |
| `Views/ProfileView.swift` | Own profile and sign out. |
| `Views/AuthSheet.swift` | Sign-in sheet. |
| `API/`, `Models/` | Same client and data shapes as iPhone. |
| `Melete.icon` | Icon Composer bundle for the Mac app. |

## Apple Watch (`watchos/`)

Ships inside the iOS app. It has no sign-in screen of its own, so it works from the account the iPhone app signs into.

| Path | What it does |
|---|---|
| `SparkWatchApp.swift`, `ContentView.swift` | Entry point and root view. |
| `Views/HotFeedView.swift`, `Views/NewFeedView.swift` | Hot and New feeds. |
| `Views/PostDetailView.swift`, `Views/PostRow.swift` | Post detail and the list row. |
| `Views/ComposeView.swift` | New idea from the wrist. |
| `Views/Colors.swift` | Palette. |
| `Models/WatchAPI.swift` | API client. Caches the last feed for offline reading. Handles votes and posts. |
| `Models/WatchModels.swift` | Watch data shapes. |

## Widgets (`widgets-ios/`, `widgets-macos/`)

Each widget target has the same three widgets: Hot posts, New posts, and Stats. Each has a `Providers/` folder that fetches and refreshes on a schedule, a `Models/` folder for the API client and data shapes, and a `Views/` folder for the layouts. `widgets-macos/Views/SharedComponents.swift` holds the pieces the Mac widgets share.

## Kotlin Multiplatform (`kmp/`)

A Compose client with a shared module (`SparkjarClient.kt`) that talks to the same API. It has an Android entry point and a desktop entry point. It is not shipped. The `native-release.yml` workflow can build it when a `native-v*` tag is pushed.

## Data

Rows live in D1 and files live in KV, behind the `jaybulb-api` Worker. The schema is in that Worker's repo, not this one. This repo only calls the Worker through `api/_lib/spark.js`.

## Tests

`npm test` runs Vitest on `tests/`. The suite covers the Pages adapter, the AI handlers, auth, comments, posts, theme behavior and the user workflow. `full-workflow.test.mjs` runs against a live API and is skipped unless `API_URL` is set. `onboarding.check.mjs` is a browser check for the onboarding carousel. Run it by hand.

## Scripts

| File | What it does |
|---|---|
| `scripts/build-static.sh` | Copies the publishable files into `dist/`. The repo root holds too much to publish as is. |
| `scripts/make-appicon.sh` | Rebuilds the app icon PNGs from `icon.svg`. Always use it, never export by hand. |
| `scripts/screenshots.mjs` | Captures hero screenshots in light and dark, with Playwright. |
| `scripts/backfill-enrich.sh` | One-off. Writes specs and plans for old posts that have none. |
| `scripts/set-resend-key.sh` | Checks a Resend key with Resend before it is stored. |
| `scripts/simplify.sh` | Creates the standard folders if they are missing. |

## Deployment and secrets

- **Web**: `npm run deploy` builds `dist/` and deploys it to the Cloudflare Pages project `sparkjar`. A push to git deploys nothing by itself.
- **Cron**: `npx wrangler deploy --config worker/wrangler.jsonc`.
- **Pages secrets**, set with `npx wrangler pages secret put <NAME> --project-name sparkjar`: `JWT_SECRET`, `SPARK_SERVICE_KEY`, `SPARK_DAEMON_SECRET`, `RESEND_API_KEY`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_ID`.
- **Optional**: `SPARK_API_URL`, if the data Worker is not at the default host.
- **Public variables**, in `wrangler.toml`: `ALLOWED_ORIGIN`, `APP_URL`, `APPLE_CLIENT_ID` (the bundle ID).
- **Worker secret**: `SPARK_DAEMON_SECRET` on the cron Worker, the same value as on Pages.
- **Old host**: `hikko.jaybulb.com` still serves the GitHub OAuth callback. Do not retire it.
