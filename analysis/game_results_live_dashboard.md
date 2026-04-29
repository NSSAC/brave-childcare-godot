# game_results_live_dashboard.py

This script converts the game results workflow into a long-running live dashboard updater.

It monitors:
- `outputs/output_childcare_stats.json`

It regenerates:
- `analysis/game_results_dashboard.html`

It can also host a local web server with an auto-refresh page so the leaderboard view updates while players complete runs.

## What It Does

1. Reads JSON lines from `output_childcare_stats.json`
2. Filters for `event == "run_summary"`
3. Rebuilds the Plotly leaderboard dashboard HTML
4. Watches the stats file for updates using a persistent background thread
5. Re-renders automatically whenever the stats file changes
6. Optionally serves `/live` in a browser and auto-refreshes the displayed dashboard when updated

## Requirements

- Python environment with:
  - `pandas`
  - `plotly`

If needed:

```bash
pip install pandas plotly
```

## Basic Usage

From repository root:

```bash
source .venv/bin/activate
python analysis/game_results_live_dashboard.py
```

Behavior:
- Starts monitoring stats file changes
- Writes updated dashboard HTML on each change
- Keeps running until you stop with `Ctrl+C`

## Live Web Server (Auto-Refreshing Browser View)

Run:

```bash
source .venv/bin/activate
python analysis/game_results_live_dashboard.py --serve --host 127.0.0.1 --port 8050
```

Open in browser:
- Live wrapper page: `http://127.0.0.1:8050/live`
- Static dashboard file: `http://127.0.0.1:8050/game_results_dashboard.html`

How `/live` works:
- Embeds the dashboard in an iframe
- Polls a lightweight endpoint for dashboard file signature changes
- Reloads iframe automatically when the HTML file is regenerated

## Optional Arguments

- `--poll-seconds FLOAT`
  - File monitor polling interval for stats updates
  - Default: `2.0`

- `--stats-path PATH`
  - Explicit path to stats JSON
  - Default: auto-detects `outputs/output_childcare_stats.json`

- `--export-path PATH`
  - Explicit output path for generated dashboard HTML
  - Default: `analysis/game_results_dashboard.html`

- `--serve`
  - Enable built-in HTTP server

- `--host HOST`
  - HTTP server host bind address
  - Default: `127.0.0.1`

- `--port INT`
  - HTTP server port
  - Default: `8050`

- `--refresh-poll-ms INT`
  - Browser-side poll interval for `/live` auto-refresh checks
  - Default: `1200`

## Example Commands

Faster file monitoring:

```bash
python analysis/game_results_live_dashboard.py --poll-seconds 1.0
```

Custom stats path:

```bash
python analysis/game_results_live_dashboard.py --stats-path outputs/output_childcare_stats.json
```

Custom output HTML:

```bash
python analysis/game_results_live_dashboard.py --export-path analysis/game_results_dashboard.html
```

Serve on a different port:

```bash
python analysis/game_results_live_dashboard.py --serve --port 8060
```

## Stopping

Press `Ctrl+C` in the terminal running the script.

The script will:
- Stop the file monitor thread
- Stop the web server (if enabled)

## Troubleshooting

- `Could not find outputs/output_childcare_stats.json`
  - Run from repo root or pass `--stats-path`

- Imports unresolved in editor for `pandas` / `plotly`
  - Ensure VS Code interpreter points to your project `.venv`
  - Install dependencies in that same environment

- Browser does not update
  - Use `/live` instead of opening the HTML file directly
  - Confirm script terminal shows update messages after run completion

- Partial JSON writes while game is saving
  - Script already skips malformed trailing lines and retries render
