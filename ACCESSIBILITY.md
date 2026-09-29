# Geo-Pardy — Accessibility Audit & Remediation

**Component:** geo-pardy.html (GIS Day game board, with tiebreaker, sound, and end-of-game celebration)
**Standard:** WCAG 2.2 Level AA
**Date:** July 2026 (full re-audit after tiebreaker, audio, and celebration features were added)

Contrast figures below were calculated with the WCAG relative-luminance formula. Large text is ≥ 24px (or ≥ 18.66px bold); the board values, category names, and overlay headings all qualify as large text.

## Issues found and fixed in this review

| # | Issue | WCAG criterion | Fix |
|---|-------|----------------|-----|
| 1 | The celebration animates continuously (confetti, rays, shimmer, glow) with no time limit, in parallel with the winner text — no way to pause it | 2.2.2 Pause, Stop, Hide | Added a "Pause effects / Resume effects" button in the results screen that stops the confetti and freezes the CSS animations while keeping all text visible |
| 2 | Active tile edges were ~1.7:1 against the dark surround | 1.4.11 Non-text Contrast | Tile border raised to a 30% white bezel; boundary is now 3.6–5.5:1 against the surround (value labels also identify each tile) |
| 3 | The results overlay could clip its content on very short screens or with many teams (no scroll) | 1.4.10 Reflow | Results overlay now scrolls when content exceeds the viewport |
| 4 | Earlier build used full-screen white flashes on win and on each firework | 2.3.1 Three Flashes | All screen flashes removed; celebration is now continuous non-flashing motion only (fixed in the prior pass, confirmed here) |

## Verified conformant (reviewed, no change needed)

- **1.4.3 Contrast (text):** all text/value/heading pairs meet or exceed AA (see table).
- **2.3.1 Three Flashes:** no flashing. Confetti/fireworks are falling/fading particles; rays rotate once per 16s; the winner glow pulses ~0.38 Hz; the name shimmer is a slow gradient move — all far below the 3-per-second threshold and none are large bright flashes.
- **2.1.1 Keyboard / 2.1.2 No Trap:** every control is a native button or input. The clue, tiebreaker, and results dialogs trap focus via an inert background and are each dismissible with Escape.
- **2.4.3 Focus Order:** focus moves into each dialog on open and returns to a sensible place on close (next available tile, or the New game / results buttons).
- **2.4.7 / 2.4.11 Focus Visible & Appearance:** 3px white focus ring on buttons, 3px gold ring on inputs, with offset.
- **2.5.8 Target Size:** all buttons are ≥ 32×32px, including the score +/−/✕ controls.
- **1.4.1 Use of Color:** played tiles are programmatically disabled and labeled "already played"; correct/wrong use text and labels, not color alone; the winner is named in text and ranked by position, not indicated by color alone.
- **4.1.2 Name, Role, Value:** icon buttons have descriptive aria-labels ("Add $100 to Team 1", "Award $400 to Team 2", "Declare Team 1 the winner"); the Sound control exposes aria-pressed; dialogs use role="dialog", aria-modal, and aria-labelledby.
- **4.1.3 Status Messages:** a polite live region announces clues, revealed responses, score changes, the tiebreaker, effects pause/resume, sound on/off, and the final result.
- **1.3.1 / 2.4.6:** an h1 title, an h2 empty state, an ordered list for standings, and labeled region landmarks for the board and scores.
- **3.1.1 Language:** page is set to English.
- **1.4.2 Audio Control:** sounds are short, non-looping, and play only in response to user actions (nothing auto-plays on load); the Sound On/Off control turns all audio off at any time.
- **2.2.1 Timing:** no time limits on play.
- **1.4.10 Reflow:** board and overlays fit without horizontal scrolling; the header stacks and centers below 720px.

## prefers-reduced-motion

When the operating system requests reduced motion, the game turns off all of it: the confetti never launches, the rays are hidden, and every CSS transition/animation (shimmer, glow, crown bob, entrances) is disabled. Reduced-motion users get a calm, fully static results screen — which also means the continuous-motion concern (2.2.2) does not arise for them at all.

## Verified contrast ratios (AA)

| Pair | Ratio | Requirement |
|------|-------|-------------|
| Gold values on tiles (lightest → darkest) | 3.75:1 → 6.78:1 | 3:1 (large) |
| White category names on category cells | 13.3:1 | 4.5:1 |
| White clue text on the clue screen | 12.0:1 | 4.5:1 |
| Gold response text on the clue screen | 7.3:1 | 4.5:1 |
| Tiebreaker title (gold) / subtitle (light) on clue screen | 7.3:1 / 10.2:1 | 3:1 / 4.5:1 |
| Winner buttons — dark text on gold | 9.3:1 | 4.5:1 |
| Champion name (gold) on results screen | 10.7:1 | 3:1 (large) |
| Standings text (white) on results screen | 17.5:1 | 4.5:1 |
| Control text on the board background | 15.9:1 | 4.5:1 |
| Active tile border vs surround | 3.6:1 → 5.5:1 | 3:1 |
| Played-tile border vs surround | 8.0:1 | 3:1 |

## Residual notes / recommended manual testing

- The win sound is intentionally big (~4.6s crash/fanfare/cheer). It is not flashing or looping and can be silenced with the Sound toggle, but set room/projector volume before the event.
- A six-column board is small on a phone (it reflows without horizontal scroll); for handheld use consider fewer categories.
- The inert-background focus trap requires a current browser (Edge/Chrome 102+, Firefox 112+), which City-standard browsers satisfy.
- Automated math and code review only go so far. Before the event, do one keyboard-only pass and one screen-reader pass (NVDA or Narrator) on the actual hardware to confirm announcements and focus behave as expected, and confirm the "Pause effects" button visibly stops the motion.
