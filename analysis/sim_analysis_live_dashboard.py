from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
from matplotlib.ticker import FuncFormatter


RUN_ID_RE = re.compile(r"^id-\d{4}$")
PREFIX_PATTERN = re.compile(r"^run_(id-\d{4})_(\d{2})_(.+)\.png$", re.IGNORECASE)
SUFFIX_PATTERN = re.compile(r"^(\d{2})_(.+)_run-(id-\d{4})\.png$", re.IGNORECASE)


@dataclass(frozen=True)
class RunMeta:
    run_id: str
    player_name: str
    timestamp: str


def _find_repo_root() -> Path:
    here = Path.cwd().resolve()
    candidates = [here, *here.parents]
    for candidate in candidates:
        if (candidate / "project.godot").exists() or (candidate / "outputs").exists():
            return candidate
    return here


def _normalize_run_id(raw_run_id: Any) -> str | None:
    if raw_run_id is None:
        return None
    text = str(raw_run_id).strip()
    if not text:
        return None
    if text.startswith("id-"):
        return text if RUN_ID_RE.match(text) else None
    if text.isdigit():
        return f"id-{int(text):04d}"
    return None


def _load_run_metadata(stats_path: Path) -> dict[str, RunMeta]:
    run_meta: dict[str, RunMeta] = {}
    if not stats_path.exists():
        return run_meta

    with stats_path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue

            if row.get("event") != "run_summary":
                continue

            normalized = _normalize_run_id(row.get("run_id"))
            if not normalized:
                continue

            run_meta[normalized] = RunMeta(
                run_id=normalized,
                player_name=str(row.get("player_name") or "Unknown"),
                timestamp=str(row.get("timestamp") or ""),
            )

    return run_meta


def _collect_run_images(plot_dir: Path) -> dict[str, dict[str, str]]:
    run_images: dict[str, dict[str, str]] = {}
    if not plot_dir.exists():
        return run_images

    for png_path in sorted(plot_dir.glob("*.png")):
        name = png_path.name

        prefix_match = PREFIX_PATTERN.match(name)
        if prefix_match:
            run_id = prefix_match.group(1)
            slot = prefix_match.group(2)
            label = prefix_match.group(3)
        else:
            suffix_match = SUFFIX_PATTERN.match(name)
            if not suffix_match:
                continue
            slot = suffix_match.group(1)
            label = suffix_match.group(2)
            run_id = suffix_match.group(3)

        key = f"{slot}_{label}"
        run_images.setdefault(run_id, {})[key] = png_path.name

    return run_images


def _latest_run_id_from_stats(stats_path: Path) -> str | None:
    latest: str | None = None
    if not stats_path.exists():
        return None

    with stats_path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue
            if row.get("event") != "run_summary":
                continue
            normalized = _normalize_run_id(row.get("run_id"))
            if normalized:
                latest = normalized

    return latest


def _latest_run_id_from_plots(run_images: dict[str, dict[str, str]]) -> str | None:
    if not run_images:
        return None

    def _run_sort_key(run_id: str) -> int:
        return int(run_id.split("-")[1])

    return max(run_images.keys(), key=_run_sort_key)


def _safe_label(run_id: str, meta: RunMeta | None) -> str:
    if not meta:
        return run_id

    ts_label = meta.timestamp
    if ts_label:
        try:
            dt = datetime.fromisoformat(ts_label)
            ts_label = dt.strftime("%Y-%m-%d %H:%M")
        except ValueError:
            pass

    if ts_label:
        return f"{run_id} - {meta.player_name} - {ts_label}"
    return f"{run_id} - {meta.player_name}"


def _build_html(run_images: dict[str, dict[str, str]], run_meta: dict[str, RunMeta], initial_run_id: str) -> str:
    sorted_runs = sorted(run_images.keys(), key=lambda rid: int(rid.split("-")[1]))

    payload = {
        "runs": [
            {
                "run_id": rid,
                "label": _safe_label(rid, run_meta.get(rid)),
                "images": run_images[rid],
            }
            for rid in sorted_runs
        ],
        "initial": initial_run_id,
    }

    payload_json = json.dumps(payload)

    return f"""<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>Simulation Analysis Gallery</title>
  <style>
    :root {{
      --bg: #f7f6f3;
      --card: #ffffff;
      --ink: #1d2a35;
      --muted: #5f6b76;
      --accent: #2b7a78;
      --edge: #d9d8d4;
    }}
    * {{ box-sizing: border-box; }}
    body {{ margin: 0; font-family: \"Avenir Next\", \"Segoe UI\", sans-serif; background: linear-gradient(180deg, #f7f6f3 0%, #ece9e1 100%); color: var(--ink); }}
    .shell {{ max-width: 1200px; margin: 0 auto; padding: 20px 16px 40px; }}
    .top {{ background: var(--card); border: 1px solid var(--edge); border-radius: 12px; padding: 14px; display: flex; flex-wrap: wrap; gap: 12px; align-items: center; justify-content: space-between; }}
    .title {{ font-size: 1.25rem; font-weight: 700; }}
    .sub {{ color: var(--muted); font-size: 0.92rem; margin-top: 3px; }}
    .picker {{ display: flex; align-items: center; gap: 8px; }}
    select {{ border: 1px solid #bcc5cc; border-radius: 8px; padding: 8px 10px; min-width: 320px; background: #fff; color: var(--ink); }}
    .grid {{ display: grid; grid-template-columns: 1fr; gap: 14px; margin-top: 16px; }}
    .plot-card {{ background: var(--card); border: 1px solid var(--edge); border-radius: 12px; padding: 12px; }}
    .plot-title {{ font-weight: 600; margin-bottom: 8px; color: #22303d; }}
    .plot-image {{ width: 100%; height: auto; border-radius: 8px; border: 1px solid #d3d9df; background: #fafafa; }}
    .missing {{ border: 1px dashed #d0bfbf; border-radius: 8px; color: #8a5a5a; padding: 16px; background: #fff7f7; }}
    @media (min-width: 960px) {{
      .grid {{ grid-template-columns: 1fr 1fr; }}
      .plot-card.wide {{ grid-column: 1 / -1; }}
    }}
  </style>
</head>
<body>
  <div class=\"shell\">
    <div class=\"top\">
      <div>
        <div class=\"title\">Simulation Analysis Gallery</div>
        <div class=\"sub\" id=\"activeRunLabel\">Run</div>
      </div>
      <div class=\"picker\">
        <label for=\"runSelect\">Run</label>
        <select id=\"runSelect\"></select>
      </div>
    </div>
    <div id=\"plots\" class=\"grid\"></div>
  </div>

  <script>
    const payload = {payload_json};
    const runSelect = document.getElementById('runSelect');
    const plots = document.getElementById('plots');
    const activeRunLabel = document.getElementById('activeRunLabel');

    const preferredOrder = [
      '01_exposure_by_individual',
      '02_exposure_over_time',
      '03_exposure_differences',
      '04_exposure_rate',
      '05_room_trends'
    ];

    function titleFromKey(key) {{
      const noSlot = key.replace(/^\\d{{2}}_/, '');
    return noSlot.replaceAll('_', ' ').replace(/\\b\\w/g, c => c.toUpperCase());
    }}

    function sortKeys(keys) {{
      const orderMap = new Map(preferredOrder.map((k, i) => [k, i]));
      return [...keys].sort((a, b) => {{
        const aa = a.replace(/^\\d{{2}}_/, '');
        const bb = b.replace(/^\\d{{2}}_/, '');
        const ai = orderMap.has(aa) ? orderMap.get(aa) : 999;
        const bi = orderMap.has(bb) ? orderMap.get(bb) : 999;
        if (ai !== bi) return ai - bi;
        return a.localeCompare(b);
      }});
    }}

    function renderRun(runId) {{
      const run = payload.runs.find(r => r.run_id === runId);
      if (!run) return;

      activeRunLabel.textContent = run.label;
      plots.innerHTML = '';

      const imageKeys = sortKeys(Object.keys(run.images));
      for (const key of imageKeys) {{
        const filename = run.images[key];
        const card = document.createElement('section');
        card.className = 'plot-card' + (key.includes('room_trends') ? ' wide' : '');

        const title = document.createElement('div');
        title.className = 'plot-title';
        title.textContent = titleFromKey(key);
        card.appendChild(title);

        if (filename) {{
          const img = document.createElement('img');
          img.className = 'plot-image';
          img.alt = key;
          img.loading = 'lazy';
          img.src = `plots/${{filename}}`;
          card.appendChild(img);
        }} else {{
          const miss = document.createElement('div');
          miss.className = 'missing';
          miss.textContent = 'Missing image for this plot slot.';
          card.appendChild(miss);
        }}

        plots.appendChild(card);
      }}
    }}

    for (const run of payload.runs) {{
      const option = document.createElement('option');
      option.value = run.run_id;
      option.textContent = run.label;
      runSelect.appendChild(option);
    }}

    const initialRun = payload.runs.some(r => r.run_id === payload.initial)
      ? payload.initial
      : (payload.runs.length ? payload.runs[payload.runs.length - 1].run_id : null);

    if (initialRun) {{
      runSelect.value = initialRun;
      renderRun(initialRun);
    }}

    runSelect.addEventListener('change', () => renderRun(runSelect.value));
  </script>
</body>
</html>
"""


def _seconds_to_clock(x: float, _pos: float) -> str:
    total_seconds = int(round(x))
    hours = (total_seconds // 3600) % 24
    minutes = (total_seconds % 3600) // 60
    return f"{hours:02d}:{minutes:02d}"


def _load_json_lines(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    if not path.exists():
        return rows
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return rows


def _role_colors() -> dict[str, str]:
    return {
        "infants": "#FF6B6B",
        "younger toddlers": "#4ECDC4",
        "older toddlers": "#45B7D1",
        "preschoolers": "#FFA07A",
        "providers": "#95E1D3",
        "floaters": "#C7CEEA",
        "unknown": "#CCCCCC",
    }


def generate_run_plots(repo_root: Path, run_id: str) -> None:
    output_dir = repo_root / "outputs"
    input_dir = repo_root / "inputs"
    plot_dir = repo_root / "analysis" / "plots"
    plot_dir.mkdir(parents=True, exist_ok=True)

    output_prefix = f"run_{run_id}_"
    exposure_file = output_dir / f"output_childcare_people_movement_exposure_{run_id}.json"
    person_file = input_dir / "persons_childcare_pop.json"
    room_file = output_dir / f"output_childcare_rooms_{run_id}.json"

    exposure_rows = _load_json_lines(exposure_file)
    exposure_df = pd.DataFrame(exposure_rows)
    if exposure_df.empty:
        print(f"No exposure data for {run_id}; skipping plot generation.")
        return

    person_data: list[dict[str, Any]] = []
    if person_file.exists():
        person_data = json.loads(person_file.read_text(encoding="utf-8"))
    pid_to_role = {str(p.get("pid", "")): p.get("role", "unknown") for p in person_data}

    exposure_df["role"] = exposure_df["pid"].map(pid_to_role).fillna("unknown")
    exposure_df["time"] = pd.to_numeric(exposure_df["time"], errors="coerce")
    exposure_df["cumulative_viral_exposure"] = pd.to_numeric(
        exposure_df["cumulative_viral_exposure"], errors="coerce"
    )
    exposure_df = exposure_df.dropna(subset=["time", "cumulative_viral_exposure"])

    final_exposure = exposure_df.sort_values("time").drop_duplicates("pid", keep="last")
    final_exposure = final_exposure.sort_values("cumulative_viral_exposure", ascending=False)
    colors = _role_colors()

    # Plot 01: cumulative exposure grouped by role.
    roles = final_exposure["role"].sort_values().unique()
    role_counts = {role: len(final_exposure[final_exposure["role"] == role]) for role in roles}

    fig, ax = plt.subplots(figsize=(14, 6))
    x_pos = 0.0
    x_tick_positions: list[float] = []
    x_tick_labels: list[str] = []
    bar_width = 0.6
    for role in roles:
        role_data = final_exposure[final_exposure["role"] == role]
        color = colors.get(role, "#CCCCCC")
        role_start = x_pos
        for _, row in role_data.iterrows():
            ax.bar(
                x_pos,
                row["cumulative_viral_exposure"],
                width=bar_width,
                color=color,
                alpha=0.8,
                edgecolor="black",
                linewidth=0.5,
            )
            x_pos += bar_width
        role_center = role_start + (len(role_data) - 1) * bar_width / 2
        x_tick_positions.append(role_center)
        x_tick_labels.append(str(role))
        x_pos += 0.3

    ax.set_xticks(x_tick_positions)
    ax.set_xticklabels(x_tick_labels)
    ax.set_xlabel("Role", fontsize=12)
    ax.set_ylabel("Cumulative Viral Exposure", fontsize=12)
    ax.set_title("Viral Exposure by Individual (grouped by role)", fontsize=14, fontweight="bold")
    legend_elements = [
        Patch(facecolor=colors.get(role, "#CCCCCC"), edgecolor="black", label=f"{role} ({role_counts[role]})")
        for role in roles
    ]
    ax.legend(handles=legend_elements, loc="upper right", frameon=True)
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig(plot_dir / f"{output_prefix}01_exposure_by_individual.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    # Plot 02: exposure over time by role.
    fig, ax = plt.subplots(figsize=(12, 6))
    for role in sorted(exposure_df["role"].dropna().unique()):
        role_data = exposure_df[exposure_df["role"] == role].sort_values(["pid", "time"])
        color = colors.get(role, "#CCCCCC")
        for _, pid_data in role_data.groupby("pid"):
            ax.plot(pid_data["time"], pid_data["cumulative_viral_exposure"], color=color, linewidth=0.7, alpha=0.18)
        time_avg = role_data.groupby("time")["cumulative_viral_exposure"].mean()
        ax.plot(
            time_avg.index,
            time_avg.values,
            label=f"{role} mean",
            linewidth=3.0,
            color=color,
            alpha=0.95,
            marker="o",
            markersize=3,
        )
    ax.xaxis.set_major_formatter(FuncFormatter(_seconds_to_clock))
    ax.set_xlabel("Clock Time (HH:MM)", fontsize=12)
    ax.set_ylabel("Cumulative Viral Exposure", fontsize=12)
    ax.set_title("Viral Exposure Over Time by Role (individual trajectories + role means)", fontsize=14, fontweight="bold")
    ax.legend(frameon=True, loc="best")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(plot_dir / f"{output_prefix}02_exposure_over_time.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    # Plot 03: first differences.
    fig, ax = plt.subplots(figsize=(12, 6))
    for role in sorted(exposure_df["role"].dropna().unique()):
        role_data = exposure_df[exposure_df["role"] == role].sort_values(["pid", "time"]).copy()
        color = colors.get(role, "#CCCCCC")
        role_data["delta_exposure"] = role_data.groupby("pid")["cumulative_viral_exposure"].diff()
        for _, pid_data in role_data.groupby("pid"):
            pid_diff = pid_data.dropna(subset=["delta_exposure"])
            ax.plot(pid_diff["time"], pid_diff["delta_exposure"], color=color, linewidth=0.7, alpha=0.18)
        role_mean_diff = role_data.groupby("time")["delta_exposure"].mean().dropna()
        ax.plot(
            role_mean_diff.index,
            role_mean_diff.values,
            label=f"{role} mean diff",
            linewidth=3.0,
            color=color,
            alpha=0.95,
            marker="o",
            markersize=3,
        )
    ax.xaxis.set_major_formatter(FuncFormatter(_seconds_to_clock))
    ax.set_xlabel("Clock Time (HH:MM)", fontsize=12)
    ax.set_ylabel("Difference in Cumulative Viral Exposure", fontsize=12)
    ax.set_title(
        "Exposure Change Over Time by Role (individual differences + role-mean differences)",
        fontsize=14,
        fontweight="bold",
    )
    ax.legend(frameon=True, loc="best")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(plot_dir / f"{output_prefix}03_exposure_differences.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    # Plot 04: exposure rate.
    fig, ax = plt.subplots(figsize=(12, 6))
    for role in sorted(exposure_df["role"].dropna().unique()):
        role_data = exposure_df[exposure_df["role"] == role].sort_values(["pid", "time"]).copy()
        color = colors.get(role, "#CCCCCC")
        role_data["delta_exposure"] = role_data.groupby("pid")["cumulative_viral_exposure"].diff()
        role_data["delta_time_s"] = role_data.groupby("pid")["time"].diff()
        role_data["exposure_rate_per_hour"] = np.where(
            role_data["delta_time_s"] > 0,
            role_data["delta_exposure"] * 3600.0 / role_data["delta_time_s"],
            np.nan,
        )
        for _, pid_data in role_data.groupby("pid"):
            pid_rate = pid_data.dropna(subset=["exposure_rate_per_hour"])
            ax.plot(pid_rate["time"], pid_rate["exposure_rate_per_hour"], color=color, linewidth=0.7, alpha=0.18)
        role_mean_rate = role_data.groupby("time")["exposure_rate_per_hour"].mean().dropna()
        ax.plot(
            role_mean_rate.index,
            role_mean_rate.values,
            label=f"{role} mean rate",
            linewidth=3.0,
            color=color,
            alpha=0.95,
            marker="o",
            markersize=3,
        )
    ax.xaxis.set_major_formatter(FuncFormatter(_seconds_to_clock))
    ax.set_xlabel("Clock Time (HH:MM)", fontsize=12)
    ax.set_ylabel("Exposure Rate (units per hour)", fontsize=12)
    ax.set_title("Exposure Rate Over Time by Role (individual rates + role-mean rates)", fontsize=14, fontweight="bold")
    ax.legend(frameon=True, loc="best")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(plot_dir / f"{output_prefix}04_exposure_rate.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    # Plot 05: room trends.
    room_rows = _load_json_lines(room_file)
    room_df = pd.DataFrame(room_rows)
    if not room_df.empty:
        if "event" in room_df.columns:
            room_df = room_df[room_df["event"] == "room_state"].copy()
        room_df["time"] = pd.to_numeric(room_df["time"], errors="coerce")
        room_df["viral_load"] = pd.to_numeric(room_df["viral_load"], errors="coerce")
        room_df["ach"] = pd.to_numeric(room_df["ach"], errors="coerce")
        room_df = room_df.dropna(subset=["time", "viral_load", "ach"]).sort_values(["room_name", "time"])
        room_names = sorted(room_df["room_name"].dropna().unique())

        if len(room_names) > 0:
            cmap = plt.get_cmap("tab20")
            room_color_map = {name: cmap(i % 20) for i, name in enumerate(room_names)}
            fig, axes = plt.subplots(3, 3, figsize=(18, 12), sharex=True)
            axes_flat = axes.flatten()

            for i, room_name in enumerate(room_names[:8]):
                ax = axes_flat[i]
                ax2 = ax.twinx()
                room_data = room_df[room_df["room_name"] == room_name]
                color = room_color_map[room_name]
                ax.plot(room_data["time"], room_data["viral_load"], color=color, linewidth=2.2, alpha=1.0, linestyle="-")
                ax2.plot(room_data["time"], room_data["ach"], color=color, linewidth=1.2, alpha=0.65, linestyle="--")
                ax.set_title(room_name, fontsize=12, fontweight="bold")
                ax.grid(True, alpha=0.25)
                ax.xaxis.set_major_formatter(FuncFormatter(_seconds_to_clock))
                if i % 3 == 0:
                    ax.set_ylabel("Viral Load")
                if i % 3 == 2:
                    ax2.set_ylabel("ACH")

            legend_ax = axes_flat[8]
            legend_ax.axis("off")
            room_handles = [
                Line2D([0], [0], color=room_color_map[name], lw=3.0, label=name)
                for name in room_names[:8]
            ]
            style_handles = [
                Line2D([0], [0], color="black", lw=2.5, ls="-", label="Viral Load (solid)"),
                Line2D([0], [0], color="black", lw=2.5, ls="--", label="ACH (dashed)"),
            ]
            legend_ax.legend(
                handles=room_handles + style_handles,
                loc="center",
                frameon=True,
                title="Rooms / Line Styles",
                fontsize=12,
                title_fontsize=13,
            )

            for idx in [6, 7]:
                axes_flat[idx].set_xlabel("Clock Time (HH:MM)")

            plt.suptitle("Viral Load by Room", fontsize=16, fontweight="bold")
            plt.tight_layout(rect=[0.0, 0.0, 1.0, 0.96])
            plt.savefig(plot_dir / f"{output_prefix}05_room_trends.png", dpi=300, bbox_inches="tight")
            plt.close(fig)

    print(f"Plots generated for {run_id} in {plot_dir}")


def render_gallery(
    stats_path: Path,
    export_path: Path,
    plot_dir: Path | None = None,
    repo_root: Path | None = None,
    run_id: str | None = None,
    skip_plot_generation: bool = False,
) -> tuple[int, str]:
    stats_path = stats_path.resolve()
    export_path = export_path.resolve()
    resolved_repo_root = repo_root.resolve() if repo_root is not None else _find_repo_root()
    resolved_plot_dir = plot_dir.resolve() if plot_dir is not None else resolved_repo_root / "analysis" / "plots"

    run_meta = _load_run_metadata(stats_path)
    selected_run_id = _normalize_run_id(run_id) if run_id else _latest_run_id_from_stats(stats_path)
    if not selected_run_id:
        raise RuntimeError(f"Unable to determine run id from {stats_path}")

    if not skip_plot_generation:
        generate_run_plots(resolved_repo_root, selected_run_id)

    run_images = _collect_run_images(resolved_plot_dir)
    if not run_images:
        raise FileNotFoundError(f"No run-scoped PNG files found in {resolved_plot_dir}")

    initial_run_id = selected_run_id if selected_run_id in run_images else _latest_run_id_from_plots(run_images)
    if not initial_run_id:
        raise RuntimeError("Unable to determine initial run id from stats or plot files.")

    html = _build_html(run_images, run_meta, initial_run_id)
    export_path.parent.mkdir(parents=True, exist_ok=True)
    export_path.write_text(html, encoding="utf-8")

    return len(run_images), initial_run_id


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create an HTML gallery for simulation analysis plots by run id."
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=None,
        help="Optional repo root path. Auto-detected by default.",
    )
    parser.add_argument(
        "--stats-path",
        type=Path,
        default=None,
        help="Optional explicit path to output_childcare_stats.json.",
    )
    parser.add_argument(
        "--plot-dir",
        type=Path,
        default=None,
        help="Optional explicit path to analysis/plots.",
    )
    parser.add_argument(
        "--export-path",
        type=Path,
        default=None,
        help="Optional explicit path for output HTML.",
    )
    parser.add_argument(
        "--skip-plot-generation",
        action="store_true",
        help="Only build the HTML gallery from existing PNG files.",
    )
    parser.add_argument(
        "--run-id",
        type=str,
        default=None,
        help="Optional explicit run id (e.g., id-0149). Defaults to latest from stats.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve() if args.repo_root else _find_repo_root()

    stats_path = args.stats_path.resolve() if args.stats_path else repo_root / "outputs" / "output_childcare_stats.json"
    plot_dir = args.plot_dir.resolve() if args.plot_dir else repo_root / "analysis" / "plots"
    export_path = args.export_path.resolve() if args.export_path else repo_root / "analysis" / "sim_analysis_gallery.html"

    run_count, initial_run_id = render_gallery(
        stats_path=stats_path,
        export_path=export_path,
        plot_dir=plot_dir,
        repo_root=repo_root,
        run_id=args.run_id,
        skip_plot_generation=args.skip_plot_generation,
    )

    print(f"Gallery written: {export_path}")
    print(f"Runs in dropdown: {run_count}")
    print(f"Initial run: {initial_run_id}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
