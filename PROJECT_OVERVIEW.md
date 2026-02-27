# AI Daily Digest Local Suite

This project packages the original `ai-daily-digest` skill with local automation and a readable web frontend.

## Included

- Core digest generator (`scripts/digest.ts`) adapted for Kimi (`kimi-k2.5`).
- Daily scheduler scripts for Windows Task Scheduler.
- Local web reader (`viewer/`) that parses Markdown into structured reading pages.
- One-click launcher for the reader.

## Automation (Windows)

- `scripts/run-digest-daily.ps1`
  - Generates daily digest into `output/digest-YYYYMMDD.md`
  - Keeps run logs at `output/digest-run.log`
- `scripts/register-digest-task.ps1`
  - Registers task `AI-Daily-Digest-9AM` (daily 09:00)

## Web Reader

- `viewer/server.ts` serves reports and API.
- `viewer/index.html` + `viewer/styles.css` provide magazine-style reading UI.
- `scripts/start-digest-viewer.ps1` starts server and opens browser.
- `打开日报阅读站.cmd` provides desktop double-click startup.
- `scripts/register-viewer-logon-task.ps1` optionally starts reader on Windows logon.

## Quick Start

1. Ensure `KIMI_API_KEY` is set in your environment.
2. Generate digest manually:

```powershell
bun scripts/digest.ts --hours 48 --top-n 15 --lang zh --output output/digest-$(Get-Date -Format yyyyMMdd).md
```

3. Launch reader:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-digest-viewer.ps1
```

4. Open:

`http://localhost:8787`
