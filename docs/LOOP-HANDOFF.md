# Melete loop handoff (2026-10-19, evening)

## What the loop is

The loop works the roadmap toward melete v5, then v10, one small slice per tick. Each slice is built on the web first, then iOS and Mac, then checked by eye on a screenshot. A slice ends with tests green, a commit by exact path, a push, and CI checked.

Each tick, in order: `asc versions list --app 6785162492` (a rejection jumps the queue), `gh run list --limit 3` (a red run on main jumps the queue), `git status` (anything unexpected in the tree is somebody else's work until proven otherwise), then the next item below.

Rules that bite:

- Stage by exact path. Never `git add -A` in this repo, and never stash or revert files you did not touch.
- Nothing is sent to Apple, Stripe or a store reply without Joshua's yes. Apple replies are drafts.
- Web deploys are `npm run deploy`. A push deploys nothing.
- Ideas stay radically simple. Every new feature has to earn its place on a card that is only title, pitch and votes.
- Long commands (tests, xcodebuild, fastlane) run in the background, never a wait loop.

## Where things stand

- Repo: main at 427f7f3, pushed. The name is Melete everywhere except the store listing and the hosts that old builds still call. The web feed is live on melete.jaybulb.com: cards are title, pitch and votes, one New/Trending switch, opening a card shows the closest App Store apps, then comments. The landing and app colours sit on the laurel brand kit, with a lit oil lamp as the mark.
- Store: iOS 3.1 and Mac 3.1 are WAITING_FOR_REVIEW, submitted 2026-10-19 under the Thinkpond listing name.
- 3.2 on iOS and Mac is built and not submitted. It carries the simpler feed, the lamp splash, the Melete name and icon, the Mac profile as a grouped settings form, the Mac detail pane fitted to its window, no YC strip in Brainstorm, and the notification prompt waiting for the splash.
- Daily ideas: the cron writes one idea a day on gpt-oss-120b. The first run is 09:00 UTC 2026-10-20. If it posts nothing, `npx wrangler tail sparkjar-cron` says why.
- Junk posts: 42 are still in the feed. The backup is `_attic/thinkpond-junk-posts-2026-10-19.json` and the delete is `_attic/thinkpond-delete-junk.sql`. Joshua runs the SQL himself.
- Issues: 27 open GitHub issues, many done or duplicates. Issues here are closed by hand only, never mirrored from the roadmap.
- Local tests: two iOS UI tests fail on this Mac only. Its DNS still caches melete.jaybulb.com as not found.

## Next, in order

1. When 3.1 clears review and Joshua says yes, submit 3.2 with `asc workflow run ship-ios VERSION:3.2` and `ship-mac`, with the App Store name changed to Melete, then copy the version and build into `project.yml`.
2. Watch the first gpt-oss-120b daily idea at 09:00 UTC 2026-10-20 with `npx wrangler tail sparkjar-cron`. If it fails, fix the cron before the next tick.
3. Check the launch colour on a phone. The simulator shows a white frame before the laurel splash.
4. Re-run the iOS UI tests once this Mac's DNS resolves melete.jaybulb.com.
5. Close the 27 GitHub issues by hand, one at a time, checking each against the code first.
6. Delete the stale branch `origin/spark-api-migration` after tagging it, once nothing unmerged on it is wanted.
7. Work `roadmap.md` top down.

## Restart prompt

```
/loop melete to v5, then v10, and so on. Build out the roadmap. Read docs/LOOP-HANDOFF.md first, run the tick checks, and work "Next, in order" top down.
```
