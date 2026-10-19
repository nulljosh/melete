# Thinkpond Technical Whitepaper

**v3.0** | October 2026

A jar of ideas.

Most ideas die because turning "someone should build X" into an actual plan
is the part nobody wants to do. Thinkpond closes that gap. Post one, vote on
others, argue in the comments. A model turns the good ones into build plans,
so an idea does not need its poster to know how to scope it. Every morning a
new idea shows up on its own, so the feed is never empty. Live at
[thinkpond.jaybulb.com](https://thinkpond.jaybulb.com), with native iOS,
macOS, and watchOS companions.

## Core Mechanic: Ideas as First-Class Objects

An idea is a post with a category, tags, votes, and comment threads, plus two
AI-generated attachments:

- **Enrichment (SPEC + PLAN)**: a model on Cloudflare Workers AI
  (`gpt-oss-120b`) writes a product spec and an implementation plan for each
  new idea, turning a one-liner into something buildable.
- **Idea Bases**: AI-generated idea clusters seeded from a topic, so an empty
  feed can bootstrap itself instead of asking the first visitor to populate it.

Ranking is Hot/New with optimistic-UI upvotes; category and tag filters
(tech, design, business, random) slice the feed. New users see curated seed
ideas, and the API falls back to seed data when D1 is empty or unreachable.

## Architecture

- **Frontend**: one `index.html`, plain HTML, CSS, and JS, no build step.
  CSS grid feed, PWA with offline support, dark/light toggle.
- **API**: Cloudflare Pages Functions. The site moved off Vercel on
  2026-08-17, which retired the old 12-function cap. Handlers stay
  consolidated.
- **Database**: Cloudflare D1 (database `spark`) behind the `jaybulb-api`
  Worker, with files in KV. The schema lives in that repo.
- **Auth**: JWT login, GitHub OAuth, ToS gate, Face ID on iOS.
- **Cron Worker**: `worker/` fires daily at 09:00 UTC and calls the generate
  and enrich endpoints. Nothing runs locally.

## Platforms

| Platform | Version | Status |
|---|---|---|
| Web (PWA) | v3.0.0 | Live on Cloudflare Pages |
| iOS | v1.0.1 | Live on the App Store. 3.0 waiting for review |
| macOS | v1.0.2 | Live on the App Store. 3.0 waiting for review |
| watchOS | v1.0 | Bundled with iOS |

## Security

- Handlers in `api/` check the caller before any storage call. Storage calls
  run server side only, with a service key.
- JWT secret rotated 2026-05-09.
- Known debt: an old `.env` lives in three historical commits (no longer
  tracked), purge via `git filter-repo` is on the roadmap.
- Transactional email is wired to Resend but not yet sending: the domain is
  unverified, so signup/reset mail is the open blocker on the hosted flows.
