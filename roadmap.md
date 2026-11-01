# Melete roadmap

> Priority tier 1 (2026-10-17): live blocker, work first. Order: live blockers, ship pushes, active features, portfolio, exploratory. See ~/Documents/Code/LOOP-HANDOFF.md.

Only what is still open. History lives in git and `CHANGELOG.md`. The loop runs until 4.0.

## Waiting on Apple

## Ship next
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
- [ ] 3.2 store listing: rename the App Store name to Melete (free on iOS and Mac as of 2026-10-19), new icon build, new screenshots with the lamp and the Melete name. (blocked: Joshua picks a name, 2026-11-01) Apple now refuses "Melete" ("already being used", probed on the 3.2 draft 2026-11-01). Free: Cogitation, Afflatus, Excogitate, Lucubrate. Taken: Mneme Aoede Noesis Inkling Reverie Ponder Ruminate Cogitate Musing Mull Germinate Brood Daydream Ideation Rumination Ideate Incubate Hunch Inspiro Pensive Pensieve Notion. iOS and Mac 3.2 drafts exist; listing name restored to Thinkpond.
- [ ] (blocked 11-01: 3.1 is live, so 3.2 is next, but the launch-colour line above wants a real-phone check first; nothing uploaded yet) 3.2 on iOS and Mac: built, not submitted. Carries the simpler feed (cards are title, pitch and votes; one New/Trending switch; opening a card shows "Already on the App Store", then comments; the new-idea form is title and description), the lamp splash, the Melete name and icon, the Mac profile as a grouped settings form, the Mac detail pane fitted to its window, no YC strip in Brainstorm, and the notification prompt waiting for the splash. Submit once 3.1 clears review.


## Ingested 2026-10-26

## Ingested 2026-10-30
- [ ] GitHub releases are stale

## Landing pass, 2026-10-30

- [ ] Footer needs icons or glyphs, not text.
