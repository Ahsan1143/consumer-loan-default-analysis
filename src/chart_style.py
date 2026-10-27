"""Shared chart styling so every figure in the project looks consistent."""
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib import font_manager

BLUE = "#2a78d6"        # primary series
ORANGE = "#eb6834"      # second series
GRAY = "#898781"        # muted axis / labels
INK = "#0b0b0b"         # primary text
INK_2 = "#52514e"       # secondary text
GRID = "#e1e0d9"        # hairline gridlines
AXIS = "#c3c2b7"        # baseline
SURFACE = "#ffffff"
SEQ_BLUES = ["#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b"]


def apply_style() -> None:
    """Set matplotlib defaults: clean sans font, hairline grid, no chart junk."""
    available = {f.name for f in font_manager.fontManager.ttflist}
    family = next((f for f in ["Inter", "Segoe UI", "Helvetica Neue", "Arial", "DejaVu Sans"]
                   if f in available), "sans-serif")
    mpl.rcParams.update({
        "font.family": family,
        "font.size": 10.5,
        "axes.titlesize": 13,
        "axes.titleweight": "semibold",
        "axes.titlelocation": "left",
        "axes.titlepad": 14,
        "axes.labelcolor": INK_2,
        "axes.labelsize": 10,
        "axes.edgecolor": AXIS,
        "axes.linewidth": 0.8,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.spines.left": False,
        "axes.grid": True,
        "axes.grid.axis": "y",
        "axes.axisbelow": True,
        "grid.color": GRID,
        "grid.linewidth": 0.8,
        "grid.linestyle": "-",
        "xtick.color": GRAY,
        "ytick.color": GRAY,
        "xtick.labelcolor": INK_2,
        "ytick.labelcolor": INK_2,
        "xtick.major.size": 0,
        "ytick.major.size": 0,
        "legend.frameon": False,
        "legend.fontsize": 9.5,
        "figure.facecolor": SURFACE,
        "axes.facecolor": SURFACE,
        "savefig.facecolor": SURFACE,
        "savefig.dpi": 200,
        "savefig.bbox": "tight",
        "lines.linewidth": 2,
        "lines.solid_capstyle": "round",
    })


def subtitle(ax, text: str) -> None:
    """Grey one-line subtitle under the chart title."""
    ax.text(0, 1.015, text, transform=ax.transAxes, fontsize=9.5, color=INK_2, va="bottom")


def source_note(fig, text: str = "Source: Lending Club 36-month loans issued 2007-2011 (29,085 completed loans).") -> None:
    fig.text(0.01, -0.02, text, fontsize=8, color=GRAY, ha="left", va="top")


def pct_axis(ax, axis: str = "y", decimals: int = 0) -> None:
    """Percent tick labels on clean 1/2/5/10 steps (avoids 2.5% ticks)."""
    import matplotlib.ticker as mtick
    target = ax.yaxis if axis == "y" else ax.xaxis
    target.set_major_locator(mtick.MaxNLocator(nbins=6, steps=[1, 2, 5, 10]))
    target.set_major_formatter(mtick.PercentFormatter(decimals=decimals))
