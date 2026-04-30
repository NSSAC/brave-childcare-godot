# BRAVE Childcare Game Dasboard

## game_results_live_dashboard.py

This script converts the game results workflow into a long-running live dashboard updater with integrated simulation analysis gallery.

It monitors:
- `outputs/output_childcare_stats.json`

It regenerates:
- `analysis/game_results_dashboard.html` (leaderboard & metrics)
- `analysis/sim_analysis_gallery.html` (simulation plots by run with dropdown selector)

It can also host a local web server with auto-refresh pages so both the leaderboard and simulation gallery update while players complete runs.

## What It Does

1. Reads JSON lines from `output_childcare_stats.json`
2. Filters for `event == "run_summary"` entries
3. Rebuilds the Plotly leaderboard dashboard HTML
4. Determines the latest run ID from the stats file
5. Regenerates simulation analysis plots for the latest run
6. Rebuilds the simulation gallery HTML with run selector dropdown (populated from all PNG files in `analysis/plots`)
7. Watches the stats file for updates using a persistent background thread
8. Re-renders both dashboards automatically whenever the stats file changes
9. Optionally serves live endpoints in a browser with auto-refresh when updated

## Requirements

- Python environment with:
  - `pandas`
  - `plotly`
  - `matplotlib`
  - `numpy`

If needed:

```bash
pip install pandas plotly matplotlib numpy
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

## Live Web Server (Auto-Refreshing Browser Views)

Run:

```bash
source .venv/bin/activate
python analysis/game_results_live_dashboard.py --serve --host 127.0.0.1 --port 8050
```

Open in browser:

### Leaderboard Endpoints:
- **Live leaderboard**: `http://127.0.0.1:8050/live` (auto-refreshing wrapper)
- **Static leaderboard**: `http://127.0.0.1:8050/game_results_dashboard.html`

### Simulation Analysis Endpoints:
- **Live results gallery**: `http://127.0.0.1:8050/live_results` (auto-refreshing wrapper with run dropdown selector)
- **Static results gallery**: `http://127.0.0.1:8050/sim_analysis_gallery.html`

How the live endpoints work:
- Embed the dashboard/gallery in an iframe
- Poll a lightweight endpoint for file signature changes
- Reload iframe automatically when the HTML file is regenerated
- `/live_results` displays simulation plots for the latest run with a dropdown to browse all previously analyzed runs

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

## Simulation Analysis Gallery

The integrated simulation analysis gallery automatically:
- Detects the latest run ID from `output_childcare_stats.json`
- Regenerates 5 analysis plots for that run in `analysis/plots/`:
  1. **Exposure by Individual** — cumulative viral exposure grouped by role
  2. **Exposure Over Time** — exposure trajectories by role with role-mean overlays
  3. **Exposure Differences** — first differences in exposure by role
  4. **Exposure Rate** — exposure accumulation rate (units/hour) by role over time
  5. **Room Trends** — viral load and ACH (air changes per hour) timelines by room
- Collects all PNG files from `analysis/plots/` to populate the run dropdown
- Labels each run in the dropdown with: `run_id - player_name - timestamp` (from stats metadata)
- Allows browsing historical runs via the dropdown selector on `/live_results`

Note: Plot generation uses matplotlib and requires the raw simulation output files in `outputs/`.

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
