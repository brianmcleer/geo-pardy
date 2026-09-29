# Geo-Pardy

[![License](https://img.shields.io/github/license/brianmcleer/geo-pardy)](LICENSE) [![Release](https://img.shields.io/github/v/release/brianmcleer/geo-pardy?display_name=tag)](https://github.com/brianmcleer/geo-pardy/releases) [![Issues](https://img.shields.io/github/issues/brianmcleer/geo-pardy)](https://github.com/brianmcleer/geo-pardy/issues)

A quiz-show style game board for GIS Day. One HTML file, no build step, works
offline. Six categories, five values each, any number of teams, Daily
Doubles, sudden-death tiebreakers, sound effects and an end-of-game
celebration. Questions live in a CSV you edit in Excel. WCAG 2.2 AA (see
[ACCESSIBILITY.md](ACCESSIBILITY.md)).

Geo-Pardy is an original game for GIS Day and is not affiliated with or
endorsed by the Jeopardy! brand.

## Run it

1. Put the folder on any web server. `web.config` makes IIS serve `.csv` and
   `.wav` and opens `geo-pardy.html` as the default page. Or open
   `geo-pardy.html` straight from disk and use **Load CSV**.
2. Edit the subtitle under the title: search the HTML for `EDIT ME` and put
   your organization's name there.
3. Set projector volume before the event. The win sound is big.

## Play it

- **+ Team** adds a team; names are editable. Scores adjust with the plus,
  minus and award buttons.
- Click a tile to show the clue, reveal the response, then award or deduct.
- A Daily Double tile plays its own sound and lets the team wager.
- If the game ends in a tie, the tiebreaker clues run one at a time until
  someone wins.
- Everything works from the keyboard; Escape closes any dialog.

## Write your questions

`geo-pardy-questions.csv`, one row per clue:

| column | meaning |
|---|---|
| `category` | up to six; the board shows them in the order they first appear |
| `value` | 200, 400, 600, 800, 1000 |
| `clue` | shown on the big screen |
| `answer` | shown when the host reveals it ("What is ...?") |
| `double` | `TRUE` to make that tile a Daily Double |

Rows with `category` = `TIEBREAKER` and a blank value are the sudden-death
clues.

The shipped CSV is a general GIS set (projections, spatial analysis, data
and layers, acronyms, tools of the trade). The fun version is one written
about your own organization: how many hydrants you map, your biggest park,
your most common street tree, your oldest air photo, your first drone
flight. Pull those numbers from your own ArcGIS services, verify each one,
and never put a person's name on the board.

## Requirements

A current browser (Edge or Chrome 102+, Firefox 112+). Nothing else.

## Publishing (maintainer)

`publish.ps1` checks the tree for organization-specific strings, commits,
pushes and optionally cuts a release with `geo-pardy-<version>.zip`.
PowerShell (regular user) from this folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\publish.ps1 -CommitMessage "Subject" -Release v1.0.0
```

## License

Apache License 2.0. Copyright 2026 City of Grand Junction, CO. See [LICENSE](LICENSE).
