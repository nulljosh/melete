# Melete roadmap

> Priority tier 1 (2026-10-17): live blocker, work first. Order: live blockers, ship pushes, active features, portfolio, exploratory. See ~/Documents/Code/LOOP-HANDOFF.md.

Only what is still open. History lives in git and `CHANGELOG.md`. The loop runs until 4.0.

## Waiting on Apple
- [ ] iOS 3.1 (202610191030) is waiting for review, submitted 2026-10-19. Mac 3.1 was missing the Sign in with Apple entitlement; fixed and resubmitted 2026-10-25, waiting for review. Check with `asc versions list --app 6785162492`.
- [ ] Privacy policy URL on the App Info still points at hikko.jaybulb.com. It still serves, but switch it to melete.jaybulb.com/privacy when an editable App Info exists (next version).

## Ship next
- [ ] Watch the first daily idea from gpt-oss-120b land (09:00 UTC 2026-10-20). If it posts nothing, the cron log says why: `npx wrangler tail sparkjar-cron`.
- [ ] Backfill: the feed still carries old-model posts ("Recycling guide for local bins"). Decide whether to hide or leave them.
- [ ] Delete the 42 junk posts. Backed up in `_attic/thinkpond-junk-posts-2026-10-19.json`, delete is `_attic/thinkpond-delete-junk.sql` (auto mode blocks it; Joshua runs it).
- [ ] Mac Brainstorm store shot: the macOS input-source badge from Create's text editor sticks to the window and lands in the capture. Shoot it from a cold launch that never opens Write.
- [ ] A fresh install still asks for notifications before anything is on screen. Not DailyIdea (checked). Find the caller on a device.

## Sign-in and mail
- [ ] Sign in with Apple has never had a real round trip on a physical device. Needs a phone in hand.
- [ ] Confirm a password-reset email lands in a real inbox. `/api/health/mail` says the Resend key is alive, not that mail arrives.
- [ ] GitHub and Google sign-in on iOS, plus forgot-password on iOS. Code is done on the web. Blocked on the Google OAuth client.
- [ ] Sign in with Apple on the web. Native only today. Needs a Services ID.

## Cleanup
- [ ] Two probe accounts from August: `probe1786367989`, `probe1786367990b`. Needs Joshua's yes before deleting.

## Toward 4.0
- [ ] Launch colour: the simulator shows a white launch frame before the laurel splash although `UILaunchScreen` names `LaunchBackground` and the asset compiles. Check on a phone before 3.2 ships.
- [ ] 3.2 store listing: rename the App Store name to Melete (free on iOS and Mac as of 2026-10-19), new icon build, new screenshots with the lamp and the Melete name.
- [ ] 3.2 on iOS and Mac: built, not submitted. Carries the simpler feed (cards are title, pitch and votes; one New/Trending switch; opening a card shows "Already on the App Store", then comments; the new-idea form is title and description), the lamp splash, the Melete name and icon, the Mac profile as a grouped settings form, the Mac detail pane fitted to its window, no YC strip in Brainstorm, and the notification prompt waiting for the splash. Submit once 3.1 clears review.

## Ingested 2026-10-26
