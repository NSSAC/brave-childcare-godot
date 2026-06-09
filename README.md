# BRAVE - Childcare

![BRAVE Childcare Splash Screen](Art/ChildcareCenter_RoomScene_SplashScreen.png)

BRAVE - Childcare is a Godot-based simulation game where players manage room ventilation in a childcare center to reduce aerosol exposure while controlling energy/cost tradeoffs.

The project began as an adaptation of the chem-poison simulator and has evolved into a gameplay-focused decision simulator with:
- Interactive room-level ACH controls
- Multiple automation modes (Health and BRAVE)
- Live run logging and historical comparisons
- A title-screen analytics experience with comparison charts
- Python dashboards for leaderboard and post-run analysis

## Table of Contents

- Project Scope
- Core Gameplay Fundamentals
- Features Included
- Autoplay and Tutorial System
- Project Organization
- Data Model and I/O
- Running the Project
- Analytics and Dashboard Workflow
- Export and Packaging Notes (macOS)
- Development History Snapshot
- Known Design Choices and Tradeoffs
- Related Documentation

## Project Scope

Primary simulation objective:
- Maintain safer indoor air conditions across rooms by adjusting ACH (air changes per hour).

Player objective:
- Minimize cumulative exposure and alerts while avoiding unnecessary ACH cost.

Main output metrics:
- Mean cumulative exposure
- Max cumulative exposure
- Alert counts
- Total ACH cost

## Core Gameplay Fundamentals

1. Choose a difficulty level (Easy, Standard, Hard).
2. Start a run from the title screen.
3. Monitor room status and navigate rooms.
4. Adjust ACH manually, or use automation modes.
5. End run (manual or schedule-complete) and review summary/leaderboard impacts.

### Input and Control Summary

Keyboard:
- Room navigation: E (prev), R (next)
- ACH: - (down), + or = (up)
- Modes: H (Health mode), B (BRAVE mode)
- Sim speed: D (slow), S (fast)
- Pause: Space
- Camera: Arrow keys (pan), Z/X (zoom)

Controller mappings are also supported. See the controls guide for full details.

## Features Included

### Gameplay and UX

- Room-by-room ACH management with live UI feedback
- Health mode automation and BRAVE mode behaviors
- Simulation speed controls, pause, and camera control
- Tutorial overlays and autoplay cards
- Game-over summary and title-screen historical summary

### Historical Comparison and Title Charts

- Exposure, cost, and alerts comparison charts on title screen
- Level-aware baseline and recent-run comparison selection
- Tolerant stats loading from newline-delimited JSON history
- Missing-series handling with zero placeholders and status messaging

### Data Logging and Run Files

Per-run outputs include:
- Person movement/events
- Poison exchange events
- Room state events
- Person exposure events
- Run summary stats

Run IDs are normalized and attached to output file names (id-XXXX style).

### Analysis and Dashboard

- Live Plotly leaderboard dashboard from stats history
- Cost/exposure scatter and leaderboard bars
- "Healthier and Cheaper" filtered table
- Simulation gallery support from generated plots

## Autoplay and Tutorial System

This project uses a shared overlay system for both guided tutorial steps and runtime autoplay narration cards.

### What Players Experience

- Tutorial mode: a step-by-step guided walk-through when starting a normal run.
- Autoplay mode: an automated narrated run with card prompts, camera focus changes, and scripted control actions.
- Title auto-restart behavior: if a run started in autoplay, returning to title starts a 30-second autoplay countdown; any user input cancels that countdown.

### Implementation Overview

Main implementation is in Entity/main.gd:
- tutorial_steps_file_path and autoplay_cards_file_path define external JSON sources.
- _load_tutorial_steps_with_fallback() and _load_autoplay_cards_with_fallback() load external cards, normalize fields, then fallback to in-code defaults when files are missing/invalid.
- _begin_tutorial_sequence() and _end_tutorial_sequence() control tutorial lifecycle.
- _start_autoplay_mode(), _autoplay_tick(), and _stop_autoplay_mode() control autoplay lifecycle.
- _begin_title_autoplay_restart_countdown() / _cancel_title_autoplay_restart_countdown() manage title-screen autoplay restart UX.

### Content Sources You Can Update

Primary editable content files:
- inputs/tutorial_steps.json
- inputs/autoplay_cards.json

If these files are unavailable or malformed, the game uses built-in fallback arrays in Entity/main.gd (_build_tutorial_steps() and _build_autoplay_cards()).

### Tutorial Step Structure

Each tutorial entry is a Dictionary-like JSON object with common fields:
- title: slide title (supports {{WELCOME_TITLE}} token)
- body: descriptive text
- target: UI key or array of keys for highlight framing
- image: texture path (typically res://...)

Target keys map to UI controls in _tutorial_target_control().

### Autoplay Card Structure

Each autoplay card supports:
- id: unique required identifier
- title, body, target, image
- priority, weight, one_shot, cooldown_s, max_shows
- trigger: condition object (for example immediate, runtime_progress, time_window, sensor_due_window, room_viral_load, room_alert_active)
- actions: ordered script-like operations
- min_show_time_s, max_show_time_s, post_delay_s
- can_interrupt and interrupt_threshold

Core action ops implemented include:
- wait
- set_overlay_note
- select_room / focus_room / fit_map
- set_ach / add_ach
- set_health_mode / set_brave_mode
- set_pause
- set_speed / add_speed

### Safe Update Workflow

When editing Tutorial or Autoplay behavior:

1. Edit content-first in inputs/tutorial_steps.json or inputs/autoplay_cards.json.
2. Keep card ids stable once used (avoid breaking history/debug expectations).
3. Verify image paths and target keys resolve to existing assets/controls.
4. Run the game and validate:
  - tutorial next/previous/exit flow
  - autoplay card ordering and trigger behavior
  - interruption behavior under high-priority events
  - title autoplay countdown starts after autoplay runs and cancels on user input
5. Only edit in-code fallback builders if you need default behavior changed when JSON files are unavailable.

### Common Pitfalls

- Missing/invalid JSON silently falls back to in-code defaults, which can make edits appear "ignored".
- Incorrect target keys prevent highlight framing.
- Duplicate autoplay ids or aggressive cooldown/priority settings can starve other cards.
- Very low max_show_time_s can end cards before actions complete.

## Project Organization

Top-level layout:
- Entity/: Godot gameplay scripts and scenes (core logic lives here)
- Map/: Scene/map content
- Art/: Visual assets
- inputs/: Configuration, schedule, and scenario input files
- outputs/: Runtime output logs and archived run artifacts
- analysis/: Python notebooks/scripts and generated dashboards
- Sample Inputs/: Example standalone/export configuration files

High-impact gameplay files:
- Entity/main.gd: Main game loop, title flow, run lifecycle, chart prep, output/path logic
- Entity/global_data_manager.gd: Shared runtime/global state and file handles
- Entity/person.gd: Per-person behavior and event serialization
- Entity/smart_object.gd: Object interactions and event handling
- Entity/room.gd: Room state and ACH/viral load dynamics

High-impact analysis files:
- analysis/game_results_live_dashboard.py: Live dashboard generation and optional local server
- analysis/sim_analysis_live_dashboard.py: Plot gallery rendering support
- analysis/game_results_dashboard.html: Generated dashboard artifact

## Data Model and I/O

### Configuration Inputs

Typical config fields include:
- person_file, schedule_file, room_ach_file, room_description_file
- person_output_file, poison_output_file, room_output_file, exposure_output_file, stats_output_file
- run_number, save_every_s, sim_speed_scale
- Physics and transfer parameters

Level-specific configs are commonly loaded from inputs/config_childcare_<level>.json.

### Output Behavior

Output writing is resilient:
- Attempts configured primary path first
- Uses fallback under user://outputs if primary is not writable
- Keeps chart/history loading tolerant for partially written or line-delimited JSON

### Chart Data Resolution

Title chart loaders search candidate output directories (external/config-relative/user fallback) and merge available run IDs so newest runs remain discoverable even when fallback paths are used.

## Running the Project

### Godot Editor

1. Open project.godot in Godot 4.4.1
2. Run main scene.
3. Start simulation via title screen (default or selected config).

### Standalone macOS App

Use the Quick Start and Export guide for config and path setup.

At minimum:
1. Create writable output directory (for example, under Documents).
2. Use an absolute-path config for outputs in standalone builds.
3. Export from Godot and run the app.

## Analytics and Dashboard Workflow

From repository root:

1. Activate Python environment.
2. Run the live leaderboard/dashboard monitor.
3. Optionally run the local webserver wrapper.
4. Use the sim-analysis CLI to generate or refresh per-run plots and gallery HTML.

### What the Leaderboard Tool Does

analysis/game_results_live_dashboard.py:
- Watches outputs/output_childcare_stats.json for new run_summary rows
- Rebuilds analysis/game_results_dashboard.html (leaderboard + scatter + filtered table)
- Rebuilds analysis/sim_analysis_gallery.html by invoking the sim-analysis renderer
- Optionally serves auto-refresh pages for browser viewing

### Leaderboard CLI Examples

Activate environment:

```bash
source .venv/bin/activate
```

Run monitor only (no webserver):

```bash
python analysis/game_results_live_dashboard.py
```

Run leaderboard webserver with live pages:

```bash
python analysis/game_results_live_dashboard.py --serve --host 127.0.0.1 --port 8050
```

Useful URLs when server is running:
- http://127.0.0.1:8050/live
- http://127.0.0.1:8050/live_results
- http://127.0.0.1:8050/game_results_dashboard.html
- http://127.0.0.1:8050/sim_analysis_gallery.html

Faster polling for local iteration:

```bash
python analysis/game_results_live_dashboard.py --serve --poll-seconds 1.0 --refresh-poll-ms 600
```

Use explicit files/paths:

```bash
python analysis/game_results_live_dashboard.py \
  --stats-path outputs/output_childcare_stats.json \
  --export-path analysis/game_results_dashboard.html
```

### Sim Analysis Plot CLI (Add/Refresh Run Plots)

analysis/sim_analysis_live_dashboard.py can generate run-scoped plot PNGs and rebuild the gallery selector page.

Generate plots for latest run from stats and rebuild gallery:

```bash
python analysis/sim_analysis_live_dashboard.py
```

Generate plots for a specific run and set it as initial selection:

```bash
python analysis/sim_analysis_live_dashboard.py --run-id id-0848
```

Rebuild gallery HTML only (do not generate new PNG plots):

```bash
python analysis/sim_analysis_live_dashboard.py --skip-plot-generation
```

Use explicit repo/plot/export paths:

```bash
python analysis/sim_analysis_live_dashboard.py \
  --repo-root . \
  --stats-path outputs/output_childcare_stats.json \
  --plot-dir analysis/plots \
  --export-path analysis/sim_analysis_gallery.html \
  --run-id id-0848
```

Generated artifacts:
- analysis/game_results_dashboard.html
- analysis/sim_analysis_gallery.html
- analysis/plots/run_id-XXXX_01_exposure_by_individual.png (and companion plots)

## Export and Packaging Notes (macOS)

To reduce accidental bundle bloat from generated artifacts:
- Use .gdignore in generated-data directories such as outputs/ and analysis/plots/
- Clear Godot filesystem cache when needed before re-export
- Prefer external writable output paths for standalone apps

## Development History Snapshot

Project evolution (high level):

- Feb 2026: Initialized from chem-poison base and adapted to childcare setting.
- Mar-Apr 2026: Major usability, schedule, assets, and UI/controls refinement.
- Apr-May 2026: Side-panel and gameplay polish, game-over and tutorial improvements.
- May 2026: Version 3.6 to 3.7 line with autoplay content, externalized cards, dashboard/chart upgrades.
- Late May to early Jun 2026: Export reliability and data pipeline hardening:
  - Stats parsing robustness for malformed tails/NDJSON
  - External input/config preference in standalone use
  - Safer output stream handling with write fallbacks
  - outputs/ and analysis/plots indexing control via .gdignore and cache purge workflows
  - Title-chart file resolution updates to handle fallback output locations

## Known Design Choices and Tradeoffs

- Large generated artifacts may exist in outputs/ and analysis/plots; they are useful for analysis but can interfere with editor indexing and exports if not ignored.
- Runtime fallback to user://outputs improves robustness in standalone environments but requires chart loaders to consider multiple possible output roots.
- Stats files are append-style history logs; readers are intentionally tolerant of partial trailing lines.

## Related Documentation

- Tutorial.md: Narrative tutorial steps mirrored from the in-game tutorial cards
- GAMEPLAY_CONTROLS.md: Keyboard/controller mappings and leaderboard interpretation
- PANACEA_UserGuide.md: Legacy background and parameter-level context
- MACOS_QUICK_START.md: Fast standalone run steps
- MACOS_EXPORT_GUIDE.md: Detailed export, paths, and packaging hygiene
- analysis/game_results_live_dashboard.md: Live dashboard usage and options

---

If you are onboarding as a developer or coding assistant, read LLM_SUMMARY.md next.
