<#
  publish.ps1  -  One-command publish/update for the geo-pardy repo.

  1. Refuses to publish if an organization-specific string is found in tracked files.
  2. Commits and pushes.
  3. (Optional) -Release vX.Y.Z tags the repo and creates a GitHub Release with
     geo-pardy-<version>.zip: the game, the general question CSV, sounds and web.config.

  This repo is published on its own, not by publish-all.ps1 (that script expects one widget per
  repo and reads $WidgetName; this file defines none on purpose, so publish-all skips it).

  RUN in PowerShell (regular user) from this folder:
    Normal update:    powershell -ExecutionPolicy Bypass -File .\publish.ps1 -CommitMessage "Subject`n`nBody"
    Update + release: powershell -ExecutionPolicy Bypass -File .\publish.ps1 -CommitMessage "..." -Release v1.0.0

  REDO A RELEASE (the tag must not already exist on GitHub):
    gh release delete v1.0.0 --cleanup-tag --yes
#>

param(
    [Parameter(Mandatory = $true)][string]$CommitMessage,
    [string]$Release = ""
)

$ErrorActionPreference = "Stop"

# ----- EDIT THESE PER MACHINE -----------------------------------------------
$RepoName        = "geo-pardy"
$RepoVisibility  = "public"      # only used by gh repo create on the very first run
$RepoDescription = "Quiz-show style game board for GIS Day: one HTML file, questions in a CSV, teams, Daily Doubles, tiebreakers, sound, WCAG 2.2 AA."
$RepoTopics      = @("gis", "gis-day", "quiz", "trivia", "game", "html", "accessibility", "esri")
$ReleaseFiles    = @("geo-pardy.html", "geo-pardy-questions.csv", "web.config", "ACCESSIBILITY.md", "README.md", "LICENSE", "sounds")
# ----------------------------------------------------------------------------

# Strings that identify a specific deployment. Extend the list when a new one is noticed.
$ForbiddenPattern = "gjcity|grand junction|198\.204\.|internal22|external22|external25|portal22|hosting22|internal-gis|external-gis|Lincoln Park|Einstein|Persigo|mcleer"

$RepoPath = $PSScriptRoot
if (-not $RepoPath) { $RepoPath = Split-Path -Parent $MyInvocation.MyCommand.Path }
Write-Host "==> Repo: $RepoPath"

Push-Location $RepoPath
try {
    if (-not (Test-Path ".git")) { Write-Host "==> git init"; git init | Out-Null }

    git add -A | Out-Null

    # Search the staged tree (what would be pushed), not the working folder, and leave this
    # script out of it because it carries the pattern itself.
    $prevEap = $ErrorActionPreference; $ErrorActionPreference = "Continue"
    $hits = & git grep --cached -i -n -E $ForbiddenPattern -- . ":(exclude)publish.ps1" 2>$null
    $ErrorActionPreference = $prevEap
    # The copyright holder is the City; that line is allowed everywhere. Everything else is not.
    $hits = @($hits | Where-Object { $_ -notmatch "Copyright 2026 City of Grand Junction|github.com/brianmcleer|shields.io/github/[a-z]+/brianmcleer" })
    if ($hits.Count -gt 0) {
        git reset -q
        throw "Refusing to publish, organization-specific strings found:`n" + ($hits -join "`n")
    }

    $pending = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($pending)) {
        Write-Host "==> No changes to commit."
    } else {
        Write-Host "==> Committing: $($CommitMessage.Split("`n")[0])"
        git commit -m "$CommitMessage" | Out-Null
    }

    $hasOrigin = (git remote) -contains "origin"
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $hasOrigin) {
        if (-not $gh) { Write-Host "==> No origin and gh not installed. Publish once via GitHub Desktop, then re-run."; return }
        Write-Host "==> First run: creating GitHub repo ($RepoVisibility) and pushing..."
        gh repo create $RepoName "--$RepoVisibility" --source="." --remote="origin" --push
    } else {
        $branch = (git rev-parse --abbrev-ref HEAD).Trim()
        Write-Host "==> Pulling origin/$branch (rebase)..."
        git pull --rebase origin $branch
        if ($LASTEXITCODE -ne 0) { throw "git pull --rebase failed. Resolve the conflict, then re-run." }
        Write-Host "==> Pushing..."
        git push
        if ($LASTEXITCODE -ne 0) { throw "git push failed." }
    }

    # Repo metadata and security settings, idempotent, same as the other repos.
    if ($gh) {
        $owner = (gh api user -q .login).Trim()
        $full  = "$owner/$RepoName"
        gh repo edit $full --description $RepoDescription --enable-issues --enable-wiki=false 2>$null | Out-Null
        foreach ($t in $RepoTopics) { gh repo edit $full --add-topic $t 2>$null | Out-Null }
        gh api -X PUT "repos/$full/vulnerability-alerts" 2>$null | Out-Null
        gh api -X PUT "repos/$full/automated-security-fixes" 2>$null | Out-Null
        $secJson = Join-Path $env:TEMP "geopardy-security.json"
        Set-Content -Path $secJson -Value '{"security_and_analysis":{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}}' -Encoding ascii
        gh api -X PATCH "repos/$full" --input $secJson 2>$null | Out-Null
        Remove-Item $secJson -Force -ErrorAction SilentlyContinue
        Write-Host "==> Description, topics, Dependabot alerts, secret scanning and push protection set on $full"
    }

    # ---------------------------------------------------------------- release
    if ($Release -ne "") {
        if (-not $gh) { Write-Host "==> Skipping release: gh not installed."; return }
        if ($Release -notmatch '^v\d+\.\d+\.\d+$') { throw "Release tag must look like v1.2.3. Received: $Release" }
        $existing = @(gh release list --limit 200 --json tagName -q ".[].tagName")
        if ($existing -contains $Release) { throw "Release $Release already exists. gh release delete $Release --cleanup-tag --yes, then re-run." }

        $zip   = Join-Path $env:TEMP "geo-pardy-$Release.zip"
        $stage = Join-Path $env:TEMP "geo-pardy-release-stage"
        if (Test-Path $zip)   { Remove-Item $zip -Force }
        if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
        $stageCopy = Join-Path $stage "geo-pardy"
        New-Item -ItemType Directory -Path $stageCopy | Out-Null
        foreach ($f in $ReleaseFiles) {
            $src = Join-Path $RepoPath $f
            if (-not (Test-Path $src)) { throw "Release file missing: $f" }
            Copy-Item $src -Destination $stageCopy -Recurse
        }
        Compress-Archive -Path $stageCopy -DestinationPath $zip
        Remove-Item $stage -Recurse -Force

        $notes = "Geo-Pardy $Release. Unzip, put the folder on a web server (IIS: the included web.config serves the CSV and sounds) or open geo-pardy.html from disk and use Load CSV. Edit geo-pardy-questions.csv in Excel to write your own questions."
        $branch = (git rev-parse --abbrev-ref HEAD).Trim()
        Write-Host "==> Creating release $Release ..."
        gh release create $Release $zip --title "$RepoName $Release" --notes $notes --target $branch
    }

    Write-Host "==> Finished."
}
finally {
    Pop-Location
}
