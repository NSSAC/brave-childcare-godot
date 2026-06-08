# macOS Export & Run Guide

This guide explains how to export and run the BRAVE Childcare simulation as a standalone macOS app with proper file output support.

## Problem: File Permissions on macOS

When you export and run the game as a standalone `.app`, macOS sandboxes the application, restricting where it can write files. The game tries to write simulation outputs (JSON files), but relative paths like `outputs/` may not be writable.

## Solution: Use Absolute Paths in Config

The game reads output paths from a JSON config file. You have two options:

### Option 1: Use an Absolute Path in Your Config (Recommended)

An example config file is included: **Sample Inputs/config_macos.json**

To use it:

1. Open `Sample Inputs/config_macos.json` in a text editor
2. Replace `YOUR_USERNAME` with your actual macOS username (find it via `whoami` in Terminal):
   ```bash
   whoami
   ```
   Example: if whoami returns `brylew`, replace `YOUR_USERNAME` with `brylew`

3. Save the file

Alternatively, create or edit your own config JSON (e.g., `config.json`):

```json
{
  "person_file": "path/to/persons_childcare_pop.json",
  "schedule_file": "path/to/schedule_file.json",
  
  "person_output_file": "/Users/YOUR_USERNAME/Documents/BRAVE_outputs/output_people.json",
  "poison_output_file": "/Users/YOUR_USERNAME/Documents/BRAVE_outputs/output_poison.json",
  "room_output_file": "/Users/YOUR_USERNAME/Documents/BRAVE_outputs/output_rooms.json",
  "exposure_output_file": "/Users/YOUR_USERNAME/Documents/BRAVE_outputs/output_exposure.json",
  "stats_output_file": "/Users/YOUR_USERNAME/Documents/BRAVE_outputs/output_stats.json",
  
  "run_number": 0,
  "sim_speed_scale": 1.0,
  "save_every_s": 5.0,
  
  "room_ach_file": "path/to/room_ach_config.csv",
  "room_description_file": "path/to/room_descriptions.csv",
  "prob_poison_xfer": 0.001,
  "person_to_obj_coeff": 0.01,
  "obj_to_person_coeff": 0.01,
  "max_person_gain": 100.0,
  "initial_poison": 100.0
}
```

**Important**: Replace `YOUR_USERNAME` with your actual macOS username, or use `~` if supported.

Before running the game, create the output directory:
```bash
mkdir -p ~/Documents/BRAVE_outputs
```

### Option 2: Use Home Directory in Config

If the Godot engine supports environment variable expansion or `~` in paths, you can use:

```json
{
  "person_output_file": "~/Documents/BRAVE_outputs/output_people.json",
  ...
}
```

*(Test this first—Godot 4.4 may or may not expand `~`.)*

## How to Export the Game

1. **Open Godot 4.4** and load your project
2. **Go to Project → Export**
3. **Select the macOS preset** (should already be configured)
4. **Click Export Project** and save the `.dmg` file somewhere (e.g., `~/Downloads/brave_childcare.dmg`)
5. **Install the app** by dragging it to Applications (or double-clicking the `.dmg`)

## Running the Exported Game

### From the Applications Folder

1. Open **Applications** folder in Finder
2. Find **BRAVE Childcare**
3. Double-click to launch (or right-click → Open if you get a security warning)

### Loading Your Config File

1. When the game starts, you should see a **Load Configuration** button or menu
2. Click it to open a file browser
3. Navigate to `Sample Inputs/config_macos.json` (or your custom config)
4. Select it and click **Open**
5. The game will load your configuration and start

### From Terminal

```bash
/Applications/BRAVE\ Childcare.app/Contents/MacOS/BRAVE\ Childcare
```

**Note**: This assumes the app was named "BRAVE Childcare". Adjust the path if the name differs.

### Passing a Config File via Command Line

If your app supports command-line arguments, you may be able to pass the config file:

```bash
/Applications/BRAVE\ Childcare.app/Contents/MacOS/BRAVE\ Childcare --config /path/to/config.json
```

Check the game's command-line parsing to confirm if this is supported.

## Verifying Output Files Are Written

After running a simulation:

```bash
ls -la ~/Documents/BRAVE_outputs/
```

You should see JSON files:
- `output_people_id-XXXX.json`
- `output_poison_id-XXXX.json`
- `output_rooms_id-XXXX.json`
- `output_exposure_id-XXXX.json`
- `output_stats_id-XXXX.json`

If you see an error like `FileAccess.open() returned null`, the app lacks write permissions to the specified path. Check:
1. The directory exists
2. You have write permissions: `touch ~/Documents/BRAVE_outputs/test.txt`
3. The config path is correct and absolute

## Keep Runtime Outputs Out of the App Bundle

If your `outputs/` folder contains many JSON run logs, or `analysis/plots/` contains many generated PNGs, Godot can index them as project files and include them in exports.

Use this one-time cleanup to keep generated artifacts external-only:

1. Add ignore marker files inside `outputs/` and `analysis/plots/`:

  ```bash
  touch outputs/.gdignore
  touch analysis/plots/.gdignore
  ```

  Note: `.gdignore` works by file presence; wildcard patterns inside it are not required.

2. Close the Godot editor completely.

3. Optionally remove stale generated import sidecars in `analysis/plots/`:

  ```bash
  rm -f analysis/plots/*.import(N)
  ```

4. Clear Godot's cached filesystem index for this project:

  ```bash
  rm -f .godot/editor/filesystem_cache*(N)
  ```

5. Reopen the project in Godot and verify `outputs/` and `analysis/plots/` are no longer listed in the FileSystem dock.

6. Re-export the app. Historical JSON files from `outputs/` and generated PNG artifacts from `analysis/plots/` should no longer be bundled.

This does **not** disable runtime logging to external absolute paths (for example, `~/Documents/BRAVE_outputs/` from your config).

## macOS Signing & Notarization (Optional)

If you want to avoid "unidentified developer" warnings:

1. **In Project → Export → macOS options**, set:
   - `Codesign/Identity`: your developer certificate
   - `Codesign/Apple Team ID`: your team ID
2. This requires an Apple Developer account

For now, users can right-click the app and select "Open" to bypass the warning.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "File cannot be opened" error | Check output path in config; ensure it's absolute, not relative |
| App won't start | Try running from Terminal to see detailed error messages |
| Permissions denied on output | Create output directory and verify write access: `touch ~/Documents/BRAVE_outputs/test.txt` |
| Can't find config file | Use absolute path to config in game's load dialog, or embed it in the app bundle |

## Comparing with Web Exports

If you need portability without worrying about file paths, consider exporting to HTML5 (web):
- No file I/O restrictions on localhost
- Runs in any browser
- Easier to distribute via a web server

See the Godot documentation on Web exports for more details.
