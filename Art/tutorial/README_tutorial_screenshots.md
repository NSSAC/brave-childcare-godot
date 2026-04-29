# Tutorial Screenshot Naming Guide

Put tutorial slide screenshots in this folder using the filenames below.

## Expected filenames
- step_02_panel_overview.png
- step_03_room_cards.png
- step_04_ach_controls.png
- step_05_speed_pause.png
- step_06_health_mode.png
- step_07_end_simulation.png

Step 1 currently uses:
- ../ChildcareCenter_RoomScene_SplashScreen.png

## Supported media formats
- **PNG** – static screenshot (recommended for most steps)
- **WebM** – animated clip (looping, no audio required); use for steps where showing motion adds clarity

## Capture guidelines (PNG)
- Preferred aspect: 16:9
- Recommended size: 1920x1080 or 1600x900
- Keep UI text legible and avoid motion blur
- Capture with the relevant control clearly visible near center-right

## Capture guidelines (WebM)
- Export as VP8 or VP9 WebM, ideally ≤ 5 s and looping
- Keep file size under 2 MB for fast load
- The video auto-plays and loops when the tutorial step is shown
- Name the file to match the step (e.g. `step_02_panel_overview.webm`)
- Update the `"image"` field in `_build_tutorial_steps()` to the `.webm` path

## Fast revision workflow
1. Replace an existing PNG with the same filename.
2. Re-run the game.
3. The tutorial loads the updated image path automatically.

## If you want different names
Update the "image" fields in:
- Entity/main.gd (function _build_tutorial_steps)
