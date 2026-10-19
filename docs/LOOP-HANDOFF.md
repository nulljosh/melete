# Thinkpond loop handoff (2026-10-19, evening)

## What the loop is

The loop works the roadmap toward thinkpond v5, then v10, one small slice per tick. Each slice is built on the web first, then iOS and Mac, then checked by eye on a screenshot. A slice ends with tests green, a commit by exact path, a push, and CI checked.

Each tick, in order: `asc versions list --app 6785162492` (a rejection jumps the queue), `gh run list --limit 3` (a red run on main jumps the queue), `git status` (anything unexpected in the tree is somebody else's work until proven otherwise), then the next item below.

Rules that bite:

- Stage by exact path. Never `git add -A` in this repo, and never stash or revert files you did not touch.
- Nothing is sent to Apple, Stripe or a store reply without Joshua's yes. Apple replies are drafts.
- Web deploys are `npm run deploy`. A push deploys nothing.
- Ideas stay radically simple. Every new feature has to earn its place on a card that is only title, pitch and votes.
- Long commands (tests, xcodebuild, fastlane) run in the background, never a wait loop.

## Where things stand

- Repo: main at 00fce44, pushed. Web feed is simplified and live on thinkpond.jaybulb.com: cards are title, pitch and votes, one New/Trending switch, opening a card shows the closest App Store apps, then comments. The app page colours are back on the brand kit.
- Store: iOS 3.1 and Mac 3.1 are WAITING_FOR_REVIEW, submitted 2026-10-19.
- 3.2 on iOS and Mac carries the same simpler feed. Both build and the tests pass. It is committed but not submitted.
- Daily ideas: the cron writes one idea a day on gpt-oss-120b. The first run is 09:00 UTC 2026-10-20. If it posts nothing, `npx wrangler tail sparkjar-cron` says why.
- Junk posts: 42 are still in the feed. The backup is `_attic/thinkpond-junk-posts-2026-10-19.json` and the delete is `_attic/thinkpond-delete-junk.sql`. Joshua runs the SQL himself.
- Issues: 27 open GitHub issues, many done or duplicates. Issues here are closed by hand only, never mirrored from the roadmap.

## Next, in order

1. When 3.1 clears review, submit 3.2 with `asc workflow run ship-ios VERSION:3.2` and `ship-mac`, then copy the version and build into `project.yml`. Needs Joshua's yes.
2. Watch the first gpt-oss-120b daily idea at 09:00 UTC 2026-10-20. If it fails, fix the cron before the next tick.
3. Close the 27 GitHub issues by hand, one at a time, checking each against the code first.
4. Delete the stale branch `origin/spark-api-migration` after tagging it, once nothing unmerged on it is wanted.
5. Work `roadmap.md` top down.

## Restart prompt

```
/loop thinkpond to v5, then v10, and so on. Build out the roadmap. Read docs/LOOP-HANDOFF.md first, run the tick checks, and work "Next, in order" top down.
```
