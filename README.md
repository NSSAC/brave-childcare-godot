# BRAVE - Childcare

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

1. Open project.godot in Godot 4.4.
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
2. Run analysis/game_results_live_dashboard.py.
3. Optionally use --serve to host live-refresh pages.

The dashboard monitors stats output, rebuilds leaderboard HTML, and can regenerate/serve simulation result galleries.

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

- GAMEPLAY_CONTROLS.md: Keyboard/controller mappings and leaderboard interpretation
- PANACEA_UserGuide.md: Legacy background and parameter-level context
- MACOS_QUICK_START.md: Fast standalone run steps
- MACOS_EXPORT_GUIDE.md: Detailed export, paths, and packaging hygiene
- analysis/game_results_live_dashboard.md: Live dashboard usage and options

---

If you are onboarding as a developer or coding assistant, read LLM_SUMMARY.md next.
