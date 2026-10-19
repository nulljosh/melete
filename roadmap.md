# Thinkpond roadmap

> Priority tier 1 (2026-10-17): live blocker, work first. Order: live blockers, ship pushes, active features, portfolio, exploratory. See ~/Documents/Code/LOOP-HANDOFF.md.

Only what is still open. History lives in git and `CHANGELOG.md`. The loop runs until 4.0.

## Waiting on Apple
- [ ] iOS 3.0.1 is waiting for review (submitted 2026-10-19). It carries the new Thinkpond screenshots, the post detail fix and a description without "Sparkjar". Check with `asc versions list --app 6785162492`.

## Ship next
- [ ] Mac 3.0.1: four or more fresh screenshots (the listing has one, and it says Hikko), the same post detail fix, and the `ship-mac` workflow still exports `Hikko.pkg` and `Hikko.app`. Check what the Mac target is called now before fixing the path.
- [ ] Watch the first daily idea from gpt-oss-120b land (09:00 UTC 2026-10-20). If it posts nothing, the cron log says why: `npx wrangler tail sparkjar-cron`.
- [ ] Backfill: the feed is 20 "Shared X tracker for roommates" posts from the old model. Decide whether to unpin, hide or leave them.

- [ ] 3.1 (iOS, Mac, watch): ships the green palette and the new drop-and-ripple icon. Cut it once 3.0.1 clears review, with fresh green screenshots.
- [ ] Mac shots: the window opens at 900x650 and System Events is denied resizing it. Write the saved frame to defaults (1440x900), then capture with `screencapture -l`. Wait for the new-model ideas so the feed looks good.

## From Joshua's QA, 2026-10-19
- [ ] Onboarding becomes a hands-on demo: walk the real feed, vote, open an idea, see the AI brief, then ask to sign in or sign up at the end. Today it is slides, shows after sign-in, and the bulb is still terracotta.
- [ ] Brand kit and design system refresh around the green: BRAND.md, tokens, landing page, README.
- [ ] The floating tab bar covers the bottom of post detail and comments. Add bottom inset.
- [ ] Google sign-in (and Apple on the web): code is done, blocked on the Google OAuth client and Apple Services ID.

- [ ] Show which way you voted. The arrow looks the same before and after an upvote.
- [ ] Delete the 42 junk posts. Backed up in `_attic/thinkpond-junk-posts-2026-10-19.json`, delete is `_attic/thinkpond-delete-junk.sql` (auto mode blocks it; Joshua runs it).

## Sign-in and mail
- [ ] Sign in with Apple has never had a real round trip on a physical device. Needs a phone in hand.
- [ ] Confirm a password-reset email lands in a real inbox. `/api/health/mail` now says the Resend key is alive, but not that the mail arrives.
- [ ] GitHub and Google sign-in on iOS, plus forgot-password on iOS. Code is done on the web. Blocked on the console registrations.
- [ ] Sign in with Apple on the web. Native only today. Needs a Services ID.
- [ ] The authmail worker still lists this app as "Sparkjar" with a blue accent (`authmail/src/index.js`).

## Cleanup
- [ ] Two probe accounts in Supabase from August: `probe1786367989`, `probe1786367990b`. Needs Joshua's yes before deleting.

## Toward 4.0
- [ ] A second model pass that rejects a daily idea before it posts if it is generic.
- [ ] Trademark and prior-art lookup on an idea.
