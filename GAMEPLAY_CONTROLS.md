# BRAVE Childcare Gameplay Controls

This guide summarizes gameplay controls and scoring using the in-game tutorial flow and current input mappings.

## 1. Gameplay Goal

Your objective is to manage each room's air cleaning rate (ACH) to reduce viral exposure while controlling cost.

Core loop during a run:
1. Monitor room viral load and alerts.
2. Switch between rooms.
3. Raise or lower room ACH.
4. Optionally use automation modes.
5. Balance health outcomes against fan/ACH cost.

## 2. Keyboard Controls

### Room and ACH Management
- E: Previous room
- R: Next room
- - (minus): Decrease selected room ACH
- = or +: Increase selected room ACH
- H: Toggle Health Mode (automatic ACH control)
- B: Toggle BRAVE Mode

### Simulation Speed and Pause
- Space: Pause/Resume simulation
- S: Speed up simulation
- D: Slow down simulation

### Camera and Navigation
- Arrow keys: Pan camera
- Z: Zoom in
- X: Zoom out

### Tutorial Navigation
- Right Arrow or Enter: Next tutorial slide
- Left Arrow: Previous tutorial slide
- Esc: Exit tutorial

## 3. Joypad Controls

Note: Button names vary by controller brand (Xbox, PlayStation, Switch). The table below is function-first, then hardware mapping.

### Room and ACH Management
- D-pad Right (or equivalent mapped button): Next room
- D-pad Left (or equivalent mapped button): Previous room
- Face Button Left (mapped as button 0): Decrease selected room ACH
- Face Button Bottom/Right (mapped as button 1): Increase selected room ACH
- Shoulder Left (button 4): Toggle Health Mode
- BRAVE Mode: No default joypad mapping currently (keyboard B)

### Simulation Speed and Pause
- Shoulder Right / top-right pair (mapped buttons 9 and 10): Slow down / speed up
- Start/Options equivalent (button 6): Pause/Resume

### Camera and View
- Left stick: Pan camera
- Trigger axis 4: Zoom in
- Trigger axis 5: Zoom out

### Tutorial Navigation
- Face Button Bottom/Right (button 1): Next
- Face Button Left (button 0): Previous
- Start/Options or shoulder-exit combo (button 6 / mapped exit action): Exit tutorial

## 4. Joypad Diagram Prompt (Image Generator Ready)

Use the following prompt text directly in an image generator to create a controller help graphic.

Prompt:
"Create a clean instructional gamepad control diagram for a simulation game called BRAVE Childcare. Use a neutral modern infographic style on a light background. Show one centered gamepad with labeled callouts. Include these labeled actions: Left Stick = Pan Camera; Left Trigger = Zoom In; Right Trigger = Zoom Out; D-pad Left = Previous Room; D-pad Right = Next Room; Face Button Left = ACH Down; Face Button Bottom/Right = ACH Up; Left Shoulder = Toggle Health Mode; Right Shoulder Pair = Sim Speed Down/Up; Start/Options = Pause/Resume; Face Button Bottom/Right = Tutorial Next; Face Button Left = Tutorial Previous. Add a small footer note: 'BRAVE Mode toggle is keyboard B by default.' Use high contrast labels, thin connector lines, and a clear hierarchy suitable for a user manual."

## 5. Keyboard Diagram Prompt (Image Generator Ready)

Prompt:
"Create a clean top-down keyboard shortcut infographic for BRAVE Childcare. Highlight only the gameplay keys with colored keycaps and labels. Include: E = Previous Room, R = Next Room, - = ACH Down, +/= = ACH Up, H = Toggle Health Mode, B = Toggle BRAVE Mode, Space = Pause/Resume, S = Speed Up, D = Slow Down, Arrow Keys = Pan Camera, Z = Zoom In, X = Zoom Out, Enter/Right Arrow = Tutorial Next, Left Arrow = Tutorial Previous, Esc = Tutorial Exit. Style: minimal modern UI, white or very light gray background, readable sans-serif typography, clear legend, manual-ready composition."

## 6. How Evaluation and Leaderboards Work

Leaderboard evaluation is based on run summary metrics written at the end of each run.

Primary leaderboards (lower is better):
1. Total Cost leaderboard
2. Mean Cumulative Exposure leaderboard
3. Alert Trigger Count leaderboard

Scatter view:
- X-axis: Total Cost
- Y-axis: Mean Cumulative Exposure
- Each point: one run

Healthier-and-Cheaper qualification region:
- Cost < 40.0
- Exposure < 80000.0

Qualified runs are also shown in a comparison table with:
- Player name
- Total cost
- Cumulative exposure
- Alert count
- Cost / cumulative exposure ratio

## 7. Practical Strategy

1. Start by stabilizing highest-risk rooms first.
2. Use room switching frequently; avoid over-focusing on one room.
3. Increase ACH early when viral load trends are rising.
4. Reduce ACH carefully to manage cost once trends flatten.
5. Use Health Mode to automate baseline control when manual load is high.
6. Review end-of-run leaderboards to improve cost vs exposure tradeoffs next run.
