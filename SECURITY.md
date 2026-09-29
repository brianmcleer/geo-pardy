# Security policy

## Reporting a vulnerability

Please report vulnerabilities privately through
[GitHub Security Advisories](../../security/advisories/new) on this
repository. You should hear back within a week.

## Scope

Geo-Pardy is a single static HTML page with no server, no accounts and no
network calls beyond loading its own CSV and sound files. The only
user-supplied content is the questions CSV, which is rendered as text, not
HTML.

## Things that must never be committed

This repository is public. Do not commit a question set that names people
or contains data about a specific organization. `publish.ps1` refuses to
push if organization-specific strings are found in tracked files.
