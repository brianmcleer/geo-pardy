# Contributing

Issues and pull requests are welcome. Small, well-explained changes are
easiest to review.

## Before you open a pull request

- Open `geo-pardy.html` from disk, load the shipped CSV, and play through a
  full game including a Daily Double and a tie.
- Keep it one file with no build step and no network dependencies.
- Keep it WCAG 2.2 AA: text contrast 4.5:1 (3:1 for large text), visible
  focus rings, no flashing, everything reachable from the keyboard, and any
  new motion disabled under `prefers-reduced-motion`. Update
  `ACCESSIBILITY.md` when you change a control.
- Keep organization-specific text out of the HTML. The subtitle is the one
  place a name belongs, and it is marked `EDIT ME`.
- Do not commit a question set about a specific organization. The shipped
  CSV is general GIS trivia on purpose.

## Reporting bugs

Use the bug report issue template and include the browser and version, the
CSV row involved if any, and what you expected to happen.
