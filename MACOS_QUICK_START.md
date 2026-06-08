# Quick Start: macOS Standalone Export

## Pre-Export Checklist

1. **Edit your config file** (`Sample Inputs/config_macos.json`):
   - Replace `YOUR_USERNAME` with your actual macOS username
   - Find username: `whoami` in Terminal
   - Example: `YOUR_USERNAME` → `brylew`

2. **Create the output directory** (in Terminal):
   ```bash
   mkdir -p ~/Documents/BRAVE_outputs
   ```

## Export Steps (Godot Editor)

1. Project → Export
2. Select **macOS** preset
3. Click **Export Project**
4. Save to Applications folder or Downloads

## Run the App

1. Open Applications folder (or Downloads)
2. Find **BRAVE Childcare**
3. Double-click to run
4. Click **Load Configuration** button
5. Select `config_macos.json`
6. Play the simulation!

## Verify Output Files

After completing a run:
```bash
ls -la ~/Documents/BRAVE_outputs/
```

You should see:
- `output_people_id-XXXX.json`
- `output_poison_id-XXXX.json`
- `output_rooms_id-XXXX.json`
- `output_exposure_id-XXXX.json`
- `output_stats_id-XXXX.json`

## Troubleshooting

**"File cannot be opened"** → Check output path in config uses absolute path (not relative)

**"Permission denied"** → Verify output directory exists: `mkdir -p ~/Documents/BRAVE_outputs`

**"Unidentified developer" warning** → Right-click app → Open (one-time approval)

See `MACOS_EXPORT_GUIDE.md` for full details.
