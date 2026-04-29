from __future__ import annotations

import argparse
import json
import threading
import time
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots


# Quadrant divider configuration.
QUADRANT_COST_THRESHOLD = 50.0
QUADRANT_EXPOSURE_THRESHOLD = 50000.0

QUADRANT_LABELS = {
    "bottom_left": "Healthier and Cheaper",
    "bottom_right": "Healthier but More Expensive",
    "top_left": "Cheaper but Not as Healthy",
    "top_right": "Less Healthy and More Expensive",
}
QUADRANT_LINE_COLOR = "rgba(120, 120, 120, 0.55)"
QUADRANT_LABEL_COLOR = "rgba(100, 100, 100, 0.70)"
QUADRANT_LABEL_SIZE = 12

# Filtered table configuration (runs below both boundaries).
RATIO_COLUMN_LABEL = "Cost / Cum Exposure"
RATIO_DECIMALS = 6


def _dashboard_wrapper_html(dashboard_filename: str, poll_ms: int) -> str:
        return f"""<!doctype html>
<html>
    <head>
        <meta charset=\"utf-8\" />
        <meta name=\"viewport\" content=\"width=device-width,initial-scale=1\" />
        <title>Live Childcare Dashboard</title>
        <style>
            html, body {{ margin: 0; padding: 0; height: 100%; background: #111; color: #ddd; font-family: sans-serif; }}
            #status {{ padding: 8px 12px; font-size: 13px; background: #1b1b1b; border-bottom: 1px solid #2b2b2b; }}
            #frame {{ width: 100%; height: calc(100% - 38px); border: 0; background: white; }}
            .ok {{ color: #80ed99; }}
            .warn {{ color: #ffd166; }}
        </style>
    </head>
    <body>
        <div id=\"status\">Live dashboard: <span class=\"ok\">connected</span></div>
        <iframe id=\"frame\" src=\"/{dashboard_filename}?ts=0\"></iframe>
        <script>
            const statusEl = document.getElementById('status');
            const frame = document.getElementById('frame');
            let lastSig = null;
            const pollMs = {poll_ms};

            async function checkForUpdate() {{
                try {{
                    const res = await fetch('/__dashboard_mtime', {{ cache: 'no-store' }});
                    if (!res.ok) throw new Error('status ' + res.status);
                    const sig = (await res.text()).trim();
                    if (lastSig === null) {{
                        lastSig = sig;
                    }} else if (sig !== lastSig) {{
                        lastSig = sig;
                        frame.src = '/{dashboard_filename}?ts=' + Date.now();
                        statusEl.innerHTML = 'Live dashboard: <span class=\"ok\">updated ' + new Date().toLocaleTimeString() + '</span>';
                    }}
                }} catch (err) {{
                    statusEl.innerHTML = 'Live dashboard: <span class=\"warn\">waiting for updates...</span>';
                }}
            }}

            setInterval(checkForUpdate, pollMs);
            checkForUpdate();
        </script>
    </body>
</html>
"""


def _find_stats_path() -> Path:
    repo_root_candidates = [Path.cwd(), Path.cwd().parent, Path.cwd().parent.parent]
    for candidate in repo_root_candidates:
        probe = candidate / "outputs" / "output_childcare_stats.json"
        if probe.exists():
            return probe
    raise FileNotFoundError(
        "Could not find outputs/output_childcare_stats.json from current working directory context."
    )


def _load_run_summary_rows(stats_path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []

    with stats_path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                # Ignore incomplete trailing lines while the game is still writing.
                continue
            if row.get("event") == "run_summary":
                rows.append(row)

    if not rows:
        raise ValueError(f"No run_summary rows found in {stats_path}")

    return rows


def _build_dashboard_figure(stats_df: pd.DataFrame) -> go.Figure:
    stats_df = stats_df.sort_values("run_number").reset_index(drop=True)
    stats_df["run_duration_hms"] = pd.to_timedelta(stats_df["time"], unit="s").astype(str)
    stats_df["run_clock_time"] = pd.to_datetime(stats_df["timestamp"]).dt.strftime("%I:%M%p").str.lower()

    hover_columns = {
        "player_name": True,
        "run_number": True,
        "run_duration_hms": True,
        "ach_total_cost": ":.2f",
        "exposure_mean_cumulative": ":.2f",
    }

    cost_sorted = stats_df.sort_values("ach_total_cost", ascending=True).reset_index(drop=True)
    cost_sorted["leaderboard_label"] = cost_sorted.apply(
        lambda row: f"{row.name + 1}. {row['player_name']} (Run {int(row['run_number'])} - {row['run_clock_time']})",
        axis=1,
    )

    exposure_sorted = stats_df.sort_values("exposure_mean_cumulative", ascending=True).reset_index(drop=True)
    exposure_sorted["leaderboard_label"] = exposure_sorted.apply(
        lambda row: f"{row.name + 1}. {row['player_name']} (Run {int(row['run_number'])} - {row['run_clock_time']})",
        axis=1,
    )

    alerts_sorted = stats_df.sort_values("alert_trigger_count", ascending=True).reset_index(drop=True)
    alerts_sorted["leaderboard_label"] = alerts_sorted.apply(
        lambda row: f"{row.name + 1}. {row['player_name']} (Run {int(row['run_number'])} - {row['run_clock_time']})",
        axis=1,
    )

    qualified_df = stats_df[
        (stats_df["ach_total_cost"] < QUADRANT_COST_THRESHOLD)
        & (stats_df["exposure_mean_cumulative"] < QUADRANT_EXPOSURE_THRESHOLD)
    ].copy()

    qualified_df[RATIO_COLUMN_LABEL] = qualified_df["ach_total_cost"] / qualified_df[
        "exposure_mean_cumulative"
    ].replace(0, pd.NA)
    qualified_df = qualified_df.sort_values(["ach_total_cost", "exposure_mean_cumulative"], ascending=[True, True])

    cost_fig = px.bar(
        cost_sorted,
        x="ach_total_cost",
        y="leaderboard_label",
        orientation="h",
        hover_data=hover_columns,
        labels={"ach_total_cost": "Total Cost", "leaderboard_label": "Leaderboard"},
    )
    cost_fig.update_traces(marker_color="#b56576")

    exposure_fig = px.bar(
        exposure_sorted,
        x="exposure_mean_cumulative",
        y="leaderboard_label",
        orientation="h",
        hover_data=hover_columns,
        labels={"exposure_mean_cumulative": "Mean Cumulative Exposure", "leaderboard_label": "Leaderboard"},
    )
    exposure_fig.update_traces(marker_color="#6d597a")

    alerts_fig = px.bar(
        alerts_sorted,
        x="alert_trigger_count",
        y="leaderboard_label",
        orientation="h",
        hover_data=hover_columns,
        labels={"alert_trigger_count": "Alert Count", "leaderboard_label": "Leaderboard"},
    )
    alerts_fig.update_traces(marker_color="#e76f51")

    scatter_fig = px.scatter(
        stats_df,
        x="ach_total_cost",
        y="exposure_mean_cumulative",
        hover_data=hover_columns,
        color="player_name",
        text="run_number",
        labels={
            "ach_total_cost": "Total Cost",
            "exposure_mean_cumulative": "Mean Cumulative Exposure",
        },
    )
    scatter_fig.update_traces(textposition="top center", marker={"size": 11, "opacity": 0.9})

    if qualified_df.empty:
        table_values = [["No runs below both thresholds."], ["-"], ["-"], ["-"], ["-"]]
    else:
        table_values = [
            qualified_df["player_name"].tolist(),
            qualified_df["ach_total_cost"].map(lambda v: f"{v:.2f}").tolist(),
            qualified_df["exposure_mean_cumulative"].map(lambda v: f"{v:.2f}").tolist(),
            qualified_df["alert_trigger_count"].map(lambda v: f"{int(v)}").tolist(),
            qualified_df[RATIO_COLUMN_LABEL]
            .map(lambda v: "NA" if pd.isna(v) else f"{float(v):.{RATIO_DECIMALS}f}")
            .tolist(),
        ]

    panel_height = max(300, 20 * len(stats_df) + 160)
    table_height = max(220, 34 * max(1, len(qualified_df) + 1))

    fig = make_subplots(
        rows=5,
        cols=1,
        specs=[[{"type": "xy"}], [{"type": "xy"}], [{"type": "xy"}], [{"type": "xy"}], [{"type": "table"}]],
        subplot_titles=(
            "Cost Leaderboard (Lowest Cost Wins)",
            "Mean Cumulative Exposure Leaderboard (Lowest Wins)",
            "Alert Trigger Count Leaderboard (Fewest Wins)",
            "Cost vs Mean Cumulative Exposure",
            f"Healthier and Cheaper (Cost < {QUADRANT_COST_THRESHOLD}, Exposure < {QUADRANT_EXPOSURE_THRESHOLD})",
        ),
        vertical_spacing=0.05,
        row_heights=[0.2, 0.2, 0.2, 0.27, 0.13],
    )

    for trace in cost_fig.data:
        fig.add_trace(trace, row=1, col=1)

    for trace in exposure_fig.data:
        fig.add_trace(trace, row=2, col=1)

    for trace in alerts_fig.data:
        fig.add_trace(trace, row=3, col=1)

    for trace in scatter_fig.data:
        fig.add_trace(trace, row=4, col=1)

    fig.add_trace(
        go.Table(
            header={
                "values": ["Player Name", "Cost", "Cumulative Exposure", "Alert Count", RATIO_COLUMN_LABEL],
                "fill_color": "#e9ecef",
                "align": "left",
                "font": {"size": 12},
            },
            cells={
                "values": table_values,
                "fill_color": "white",
                "align": "left",
                "height": 28,
                "font": {"size": 11},
            },
        ),
        row=5,
        col=1,
    )

    fig.update_layout(
        title="Childcare Simulation Run Summary",
        bargap=0.12,
        height=panel_height * 3 + table_height,
        width=900,
        legend_title_text="User",
        hovermode="closest",
        showlegend=True,
    )

    fig.update_xaxes(title_text="Total Cost", row=1, col=1)
    fig.update_yaxes(
        title_text="Leaderboard",
        row=1,
        col=1,
        categoryorder="array",
        categoryarray=cost_sorted["leaderboard_label"].tolist()[::-1],
    )

    fig.update_xaxes(title_text="Mean Cumulative Exposure", row=2, col=1)
    fig.update_yaxes(
        title_text="Leaderboard",
        row=2,
        col=1,
        categoryorder="array",
        categoryarray=exposure_sorted["leaderboard_label"].tolist()[::-1],
    )

    fig.update_xaxes(title_text="Alert Count", row=3, col=1)
    fig.update_yaxes(
        title_text="Leaderboard",
        row=3,
        col=1,
        categoryorder="array",
        categoryarray=alerts_sorted["leaderboard_label"].tolist()[::-1],
    )

    fig.update_xaxes(title_text="Total Cost", row=4, col=1)
    fig.update_yaxes(title_text="Mean Cumulative Exposure", row=4, col=1)

    fig.add_shape(
        type="line",
        xref="x4",
        yref="y4 domain",
        x0=QUADRANT_COST_THRESHOLD,
        x1=QUADRANT_COST_THRESHOLD,
        y0=0,
        y1=1,
        line={"color": QUADRANT_LINE_COLOR, "width": 1.5, "dash": "dash"},
    )
    fig.add_shape(
        type="line",
        xref="x4 domain",
        yref="y4",
        x0=0,
        x1=1,
        y0=QUADRANT_EXPOSURE_THRESHOLD,
        y1=QUADRANT_EXPOSURE_THRESHOLD,
        line={"color": QUADRANT_LINE_COLOR, "width": 1.5, "dash": "dash"},
    )

    _pad = 0.03
    _quadrant_specs = [
        ("bottom_left", "left", _pad, "bottom", _pad),
        ("bottom_right", "right", 1 - _pad, "bottom", _pad),
        ("top_left", "left", _pad, "top", 1 - _pad),
        ("top_right", "right", 1 - _pad, "top", 1 - _pad),
    ]

    for key, xanchor, xpos, yanchor, ypos in _quadrant_specs:
        fig.add_annotation(
            xref="x4 domain",
            yref="y4 domain",
            x=xpos,
            y=ypos,
            text=f"<i>{QUADRANT_LABELS[key]}</i>",
            showarrow=False,
            xanchor=xanchor,
            yanchor=yanchor,
            font={"size": QUADRANT_LABEL_SIZE, "color": QUADRANT_LABEL_COLOR},
        )

    return fig


def render_dashboard(stats_path: Path, export_path: Path) -> int:
    rows = _load_run_summary_rows(stats_path)
    stats_df = pd.DataFrame(rows)
    fig = _build_dashboard_figure(stats_df)

    export_path.parent.mkdir(parents=True, exist_ok=True)
    fig.write_html(str(export_path), full_html=True, include_plotlyjs=True)

    return len(stats_df)


class DashboardAutoUpdater:
    def __init__(self, stats_path: Path, export_path: Path, poll_seconds: float = 2.0) -> None:
        self.stats_path = stats_path
        self.export_path = export_path
        self.poll_seconds = max(0.25, poll_seconds)
        self._stop_event = threading.Event()
        self._thread = threading.Thread(target=self._run, name="dashboard-monitor", daemon=False)
        self._last_signature: tuple[int, int] | None = None

    def start(self) -> None:
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        self._thread.join(timeout=5.0)

    def _file_signature(self) -> tuple[int, int] | None:
        if not self.stats_path.exists():
            return None
        stat = self.stats_path.stat()
        return (stat.st_mtime_ns, stat.st_size)

    def _render_with_retry(self, retries: int = 3) -> None:
        for attempt in range(1, retries + 1):
            try:
                run_count = render_dashboard(self.stats_path, self.export_path)
                print(
                    f"[{time.strftime('%H:%M:%S')}] Dashboard updated: {run_count} runs -> {self.export_path}"
                )
                return
            except Exception as exc:  # pragma: no cover - runtime resilience path
                if attempt == retries:
                    print(f"[{time.strftime('%H:%M:%S')}] Update failed: {exc}")
                    return
                time.sleep(0.5)

    def _run(self) -> None:
        # Initial render.
        self._last_signature = self._file_signature()
        if self._last_signature is not None:
            self._render_with_retry()

        while not self._stop_event.is_set():
            signature = self._file_signature()
            if signature is not None and signature != self._last_signature:
                self._last_signature = signature
                self._render_with_retry()
            self._stop_event.wait(self.poll_seconds)


class DashboardHttpServer:
    def __init__(self, export_path: Path, host: str, port: int, refresh_poll_ms: int = 1200) -> None:
        self.export_path = export_path
        self.host = host
        self.port = port
        self.refresh_poll_ms = max(250, refresh_poll_ms)
        self._httpd: ThreadingHTTPServer | None = None
        self._thread: threading.Thread | None = None

    def _make_handler(self):
        export_path = self.export_path
        dashboard_filename = export_path.name
        poll_ms = self.refresh_poll_ms

        class _Handler(SimpleHTTPRequestHandler):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, directory=str(export_path.parent), **kwargs)

            def log_message(self, format: str, *args) -> None:  # noqa: A003
                return

            def end_headers(self) -> None:
                self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
                super().end_headers()

            def do_GET(self) -> None:  # noqa: N802
                parsed = urlparse(self.path)
                path = parsed.path

                if path == "/" or path == "/live":
                    body = _dashboard_wrapper_html(dashboard_filename, poll_ms).encode("utf-8")
                    self.send_response(HTTPStatus.OK)
                    self.send_header("Content-Type", "text/html; charset=utf-8")
                    self.send_header("Content-Length", str(len(body)))
                    self.end_headers()
                    self.wfile.write(body)
                    return

                if path == "/__dashboard_mtime":
                    sig = "0"
                    if export_path.exists():
                        st = export_path.stat()
                        sig = f"{st.st_mtime_ns}:{st.st_size}"
                    body = sig.encode("utf-8")
                    self.send_response(HTTPStatus.OK)
                    self.send_header("Content-Type", "text/plain; charset=utf-8")
                    self.send_header("Content-Length", str(len(body)))
                    self.end_headers()
                    self.wfile.write(body)
                    return

                super().do_GET()

        return _Handler

    def start(self) -> None:
        handler = self._make_handler()
        self._httpd = ThreadingHTTPServer((self.host, self.port), handler)
        self._thread = threading.Thread(target=self._httpd.serve_forever, name="dashboard-http", daemon=True)
        self._thread.start()

    def stop(self) -> None:
        if self._httpd is not None:
            self._httpd.shutdown()
            self._httpd.server_close()
        if self._thread is not None:
            self._thread.join(timeout=2.0)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Auto-refresh Plotly leaderboard dashboard when output_childcare_stats.json changes."
    )
    parser.add_argument(
        "--poll-seconds",
        type=float,
        default=2.0,
        help="Polling interval for file change detection.",
    )
    parser.add_argument(
        "--stats-path",
        type=Path,
        default=None,
        help="Optional explicit path to output_childcare_stats.json.",
    )
    parser.add_argument(
        "--export-path",
        type=Path,
        default=None,
        help="Optional explicit path for generated HTML dashboard.",
    )
    parser.add_argument(
        "--serve",
        action="store_true",
        help="Start a local web server with auto-refresh wrapper page.",
    )
    parser.add_argument(
        "--host",
        type=str,
        default="127.0.0.1",
        help="Host interface for the local web server.",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8050,
        help="Port for the local web server.",
    )
    parser.add_argument(
        "--refresh-poll-ms",
        type=int,
        default=1200,
        help="Browser-side polling interval in milliseconds for wrapper auto-refresh.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    stats_path = args.stats_path if args.stats_path is not None else _find_stats_path()
    export_path = (
        args.export_path
        if args.export_path is not None
        else stats_path.parent.parent / "analysis" / "game_results_dashboard.html"
    )

    print(f"Monitoring stats file: {stats_path}")
    print(f"Writing dashboard HTML: {export_path}")
    print("Press Ctrl+C to stop.")

    updater = DashboardAutoUpdater(stats_path=stats_path, export_path=export_path, poll_seconds=args.poll_seconds)
    server: DashboardHttpServer | None = None

    if args.serve:
        server = DashboardHttpServer(
            export_path=export_path,
            host=args.host,
            port=args.port,
            refresh_poll_ms=args.refresh_poll_ms,
        )
        server.start()
        print(f"Live server: http://{args.host}:{args.port}/live")
        print(f"Static HTML: http://{args.host}:{args.port}/{export_path.name}")

    updater.start()

    try:
        while True:
            time.sleep(1.0)
    except KeyboardInterrupt:
        print("Stopping monitor...")
        updater.stop()
        if server is not None:
            server.stop()


if __name__ == "__main__":
    main()
