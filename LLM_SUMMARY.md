# LLM Summary: BRAVE - Childcare

This file is a fast technical briefing for coding assistants.

## 1) What This Project Is

- Engine: Godot 4.4
- Domain: Childcare aerosol/exposure simulation game
- Core script: Entity/main.gd
- Global state: Entity/global_data_manager.gd (autoloaded as Global)
- Main scene configured in project.godot

The game simulates people moving through rooms and interacting with objects while room ACH controls influence viral load/exposure outcomes.

## 2) Core Runtime Flow

High-level flow in Entity/main.gd:

1. Title screen setup and chart preloading
2. Config selection by difficulty or file picker
3. load_config(file):
   - Reads JSON config
   - Resolves input/output paths
   - Resolves run number and run_id
   - Creates persons and schedules
   - Stores output file paths into Global
4. start_simulation(file):
   - Opens output streams (with fallback handling)
   - Starts save timer
5. _on_save_timer_timeout():
   - Serializes person/object/room/exposure events
   - Flushes streams
6. _end_simulation(reason):
   - Writes summary snapshot
   - Closes streams
   - Updates game-over/title history views

## 3) Important File Responsibilities

Gameplay and state:
- Entity/main.gd: Title UX, autoplay, chart data prep, config loading, output path resolution, save cycle
- Entity/global_data_manager.gd: Shared runtime variables, handles, run metadata
- Entity/person.gd: Person model and event emission
- Entity/smart_object.gd: Object model and event emission
- Entity/room.gd: Room dynamics, ACH, and viral load-related state

UI:
- Entity/main.tscn: Main scene tree including title/gameplay/game-over overlays
- Entity/ui_run_chart.gd: Run comparison chart control behavior
- Entity/game_over.gd + Entity/game_over.tscn: End-of-run UX

Analysis:
- analysis/game_results_live_dashboard.py: Plotly dashboard generator + optional server
- analysis/sim_analysis_live_dashboard.py: Per-run plot gallery generation

## 4) Data Inputs and Outputs

Inputs:
- Usually under inputs/
- Difficulty configs typically inputs/config_childcare_easy.json, inputs/config_childcare_standard.json, inputs/config_childcare_hard.json

Outputs:
- Person movement log
- Poison exchange log
- Room state log
- Exposure log (output_childcare_people_movement_exposure_id-XXXX.json)
- Stats history log (run_summary rows)

Run IDs:
- id-XXXX convention
- Derived from next run number across output directories

## 5) Path Resolution and Export Behavior (Critical)

The code intentionally supports multiple output roots:
- Config-relative/external outputs
- Executable-adjacent outputs for standalone distribution patterns
- user://outputs fallback when primary path is not writable
- res://outputs fallback for editor/project-local workflows

Important consequence:
- Chart loaders must search candidate output directories, not only one path.
- Recent fixes introduced multi-directory discovery so latest runs are still shown when writes fall back to user://outputs.

## 6) Title Chart System

Title chart payloads are cached by level and chart type:
- Exposure
- Cost
- Alerts

Data source mechanics:
- Run IDs are selected from recent runs + configured baselines
- Series loaded from output artifacts by run_id
- Missing data gets placeholder handling/status text

If a chart is empty unexpectedly, verify:
1. The expected run artifact exists (especially exposure files)
2. It is in one of the candidate output dirs
3. Run ID formatting is id-XXXX
4. JSON rows include expected event keys

## 7) Recent Hardenings to Keep in Mind

- Tolerant parsing for stats history (line-delimited and malformed trailing content)
- Safer output stream open/write behavior with null guards and fallback paths
- External config preference for standalone setups
- .gdignore-based exclusion for generated artifact directories (outputs/, analysis/plots)
- Filesystem cache purge workflow for Godot export hygiene
- Multi-directory chart artifact lookup to prevent missing latest-run lines

## 8) Dashboard Notes (Python)

Main dashboard script:
- analysis/game_results_live_dashboard.py

What it does:
- Reads output_childcare_stats.json run_summary rows
- Builds leaderboard charts and filtered table
- Optionally serves live auto-refresh views
- Integrates simulation gallery generation from analysis/plots

Dependencies:
- pandas
- plotly
- matplotlib
- numpy

## 9) Common Debug Playbook

When data appears missing:
1. Confirm the run_summary row exists in stats output
2. Confirm per-run artifact exists for the same run_id
3. Check whether artifact landed in external outputs or user://outputs fallback
4. Verify chart loader path search order and run-id regex
5. Confirm JSON event names match loader filters

When standalone export behaves differently than editor:
1. Validate absolute output paths in config
2. Inspect fallback writes to user://outputs
3. Ensure generated-data folders are ignored via .gdignore
4. Clear .godot/editor/filesystem_cache* before re-export if needed

## 10) Good First Files for Future Edits

If request is gameplay behavior:
- Entity/main.gd
- Entity/room.gd
- Entity/person.gd

If request is title charts/history:
- Entity/main.gd
- Entity/ui_run_chart.gd

If request is dashboard/leaderboard visuals:
- analysis/game_results_live_dashboard.py
- analysis/game_results_live_dashboard.md

If request is standalone/export reliability:
- Entity/main.gd
- MACOS_QUICK_START.md
- MACOS_EXPORT_GUIDE.md
- export_presets.cfg

## 11) Historical Context (Concise)

- Originated from chem-poison simulator adaptation
- Expanded to childcare-specific assets, schedules, and room controls
- Added rich title/game-over UX and tutorial/autoplay workflows
- Added analytics pipeline and live dashboarding
- Most recent work concentrated on I/O reliability, export hygiene, and chart/data path correctness
