# Thinkpond loop handoff (2026-10-19, afternoon)

## What the loop is

The loop works the roadmap toward thinkpond v100, one small slice per tick. The roadmap's own header still says 4.0 is the first stop, so 4.0 comes before v100. Each slice is built on the web first, then iOS and Mac, then checked by eye on a screenshot. A slice ends with tests green, a commit by exact path, a push, and CI checked.

Each tick, in order: `asc versions list --app 6785162492` (a rejection jumps the queue), `gh run list --limit 3` (a red run on main jumps the queue), `git status` (anything unexpected in the tree is somebody else's work until proven otherwise), then the next item below.

Rules that bite:

- Stage by exact path. Never `git add -A` in this repo, and never stash or revert files you did not touch.
- Nothing about the simplified feed goes to prod, to a store, or to Apple without Joshua's plain yes.
- Another agent is editing docs right now. Leave README.md, WHITEPAPER.md, SECURITY.md and the CLAUDE.md body alone, except the `## The loop` section.
- Nothing is sent to Apple, Stripe or a store reply without Joshua's yes. Apple replies are drafts.
- Web deploys follow the Release section of CLAUDE.md. Never deploy from a bare push.
- Long commands (tests, xcodebuild, fastlane) run in the foreground with a timeout, never a wait loop.

## Where things stand

- Repo: main at 0df24fc (pushed, 2026-10-19 12:16 PDT). Before it, b1f24df brought the README, whitepaper, API and architecture docs up to 3.1.
- 0df24fc is the simplified feed: cards cut to title, pitch and votes, one New/Trending switch, the trademark check removed from the web app. It was planned as preview-only and not approved for prod. It is now on origin/main. Whether it was deployed to prod is not confirmed in this handoff. Check before anything else.
- Store: iOS 3.1 (build 202610191030) and Mac 3.1 (build 202610191041) are WAITING_FOR_REVIEW, submitted 2026-10-19. Both carry the lily-pad green brand, the lily-pad brain icon, one vote per person per idea, and the tour that ends at sign-in.
- Web: thinkpond.jaybulb.com is home. Each idea brief lists the closest App Store apps (Apple's search, run from the browser) and checks its name against live US trademarks (USPTO search, no key). hikko.jaybulb.com still serves shipped apps and the GitHub sign-in callback.
- Daily ideas: the cron writes one idea a day on gpt-oss-120b. The first run is 09:00 UTC 2026-10-20. If it posts nothing, `npx wrangler tail sparkjar-cron` says why.
- Junk posts: 42 old-model or junk posts are still in the feed. The backup is `_attic/thinkpond-junk-posts-2026-10-19.json` and the delete is `_attic/thinkpond-delete-junk.sql`. Joshua runs the SQL himself.
- Issues: the repo has 27 open GitHub issues, many done or duplicates. Issues here are closed by hand only, never mirrored from the roadmap.

## Next, in order

1. Ask Joshua whether 0df24fc was meant to go out. If yes, QA it: fix the sort-row spacing, take dark-mode and opened-card screenshots, then check the deploy. If no, the revert is his call, not the loop's.
2. Mirror the simplified cards on iOS and Mac for 3.2 (title, pitch, votes, one New/Trending switch). Keep AppStoreMatches.swift and port the trademark check next to it.
3. Close the 27 GitHub issues by hand, one at a time, checking each against the code first.
4. Delete the stale branch `origin/spark-api-migration`, after confirming nothing unmerged is on it.
5. Watch the first gpt-oss-120b daily idea at 09:00 UTC 2026-10-20. If it fails, fix the cron before the next tick.
6. Joshua runs the junk-post delete SQL. Do not run it for him.

Until Joshua answers item 1, do the tick checks, keep the tree clean, and work item 2 only in files that are not already committed.

## Restart prompt

```
/loop until thinkpond v100. Build out roadmap. Read docs/LOOP-HANDOFF.md first, run the tick checks, and work "Next, in order" top down. Do not stage, commit, revert or deploy anything about the simplified feed until Joshua says go.
```

Then read this file first, run the tick checks, and work "Next, in order" top down.
