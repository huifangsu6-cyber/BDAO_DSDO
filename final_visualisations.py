"""Generate final report visualisations from saved CSV outputs.

This script is the executable Python version of `final_visualisations.ipynb`.
Use it if your environment tries to execute the raw notebook JSON and raises
`NameError: name 'null' is not defined`.

It does not run BigQuery. It only reads CSV files from `outputs/tables/` and
saves PNG figures to `outputs/figures/`.
"""

from pathlib import Path
import os
import warnings

import matplotlib

matplotlib.use("Agg")

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def find_table_dir() -> Path:
    """Find CSV inputs in repo-style or Colab upload locations.

    Priority:
    1. TABLE_DIR environment variable, if supplied.
    2. outputs/tables relative to the current working directory.
    3. current working directory, useful when CSVs are uploaded directly to Colab.
    4. /content/outputs/tables in Colab.
    5. /content in Colab.
    """
    env_table_dir = os.environ.get("TABLE_DIR")
    candidates = []
    if env_table_dir:
        candidates.append(Path(env_table_dir))
    candidates.extend(
        [
            Path("outputs/tables"),
            Path.cwd(),
            Path("/content/outputs/tables"),
            Path("/content"),
        ]
    )

    for candidate in candidates:
        if candidate.exists() and any(candidate.glob("*.csv*")):
            return candidate

    return Path("outputs/tables")


TABLE_DIR = find_table_dir()
FIGURE_DIR = Path(os.environ.get("FIGURE_DIR", "outputs/figures"))
FIGURE_DIR.mkdir(parents=True, exist_ok=True)
print(f"Reading CSV files from: {TABLE_DIR.resolve()}")
print(f"Saving figures to: {FIGURE_DIR.resolve()}")

sns.set_theme(style="whitegrid", context="notebook")
plt.rcParams["figure.dpi"] = 120
plt.rcParams["savefig.dpi"] = 300
plt.rcParams["axes.titleweight"] = "bold"
plt.rcParams["axes.titlesize"] = 13
plt.rcParams["axes.labelsize"] = 11
plt.rcParams["xtick.labelsize"] = 9
plt.rcParams["ytick.labelsize"] = 9

REPORT_GREEN = "#1D9E75"
REPORT_ORANGE = "#BA7517"
REPORT_BLUE = "#2F6B9A"
REPORT_RED = "#B04A3A"


def resolve_csv(filename: str) -> Path:
    """Resolve expected CSV names, including accidental .csv.csv exports."""
    path = TABLE_DIR / filename
    candidates = [path]
    if filename.endswith(".csv"):
        candidates.append(TABLE_DIR / f"{filename}.csv")
    else:
        candidates.append(TABLE_DIR / f"{filename}.csv")

    for candidate in candidates:
        if candidate.exists():
            return candidate

    raise FileNotFoundError(
        f"Could not find {filename} in {TABLE_DIR}. Tried: "
        + ", ".join(str(candidate) for candidate in candidates)
    )


def read_result(filename: str) -> pd.DataFrame:
    path = resolve_csv(filename)
    df = pd.read_csv(path)
    print(f"Loaded {path}: {df.shape[0]:,} rows x {df.shape[1]:,} columns")
    return df


def should_display_figures() -> bool:
    """Return True when saved PNGs should also be shown inline.

    The default is True so copy/pasting this script into Colab displays each
    figure in the cell output. Set DISPLAY_FIGURES=0 for quiet/headless runs.
    """
    return os.environ.get("DISPLAY_FIGURES", "1").strip().lower() not in {
        "0",
        "false",
        "no",
    }


def display_saved_figure(path: Path) -> None:
    """Display a saved PNG inline when running in Colab/Jupyter."""
    if not should_display_figures():
        return

    try:
        from IPython.display import Image, display

        display(Image(filename=str(path)))
    except Exception as exc:  # pragma: no cover - display is environment-specific
        print(f"Inline display skipped: {exc}")


def save_current_figure(filename: str) -> None:
    path = FIGURE_DIR / filename
    plt.tight_layout()
    plt.savefig(path, bbox_inches="tight")
    print(f"Saved {path}")
    display_saved_figure(path)
    plt.close()


def plot_q4() -> None:
    q4 = read_result("q4_feature_boost_results.csv")
    q4_plot = q4.sort_values("estimated_star_boost_vs_none", ascending=False).copy()

    plt.figure(figsize=(8, 4.8))
    ax = sns.barplot(
        data=q4_plot,
        x="feature_option",
        y="estimated_star_boost_vs_none",
        color=REPORT_GREEN,
    )
    ax.set_title("Q4: Estimated Rating Boost from One Success Feature")
    ax.set_xlabel("Single feature option")
    ax.set_ylabel("Estimated star boost vs no-feature baseline")
    ax.axhline(0, color="black", linewidth=0.8)
    plt.xticks(rotation=20, ha="right")
    for container in ax.containers:
        ax.bar_label(container, fmt="%.3f", padding=3, fontsize=9)
    save_current_figure("q4_feature_boost.png")


def plot_q5() -> None:
    q5 = read_result("q5_has_tv_results.csv")
    q5_plot = (
        q5.sort_values("rating_gap_has_tv_minus_no_tv", ascending=True)
        .head(10)
        .copy()
    )

    plt.figure(figsize=(8, 5.5))
    ax = sns.barplot(
        data=q5_plot,
        y="category",
        x="rating_gap_has_tv_minus_no_tv",
        color=REPORT_RED,
    )
    ax.set_title("Q5: Largest Negative Rating Gaps for HasTV by Category")
    ax.set_xlabel("Average star gap: HasTV minus No TV")
    ax.set_ylabel("Restaurant category")
    ax.axvline(0, color="black", linewidth=0.8)
    for container in ax.containers:
        ax.bar_label(container, fmt="%.3f", padding=3, fontsize=8)
    save_current_figure("q5_has_tv_gap.png")


def plot_q6() -> None:
    q6 = read_result("q6_price_by_city_results.csv")
    q6_budget_mid = q6[q6["price_tier"].isin([1, 2])].copy()
    q6_pivot = (
        q6_budget_mid.pivot_table(
            index=["city_rank", "city", "state"],
            columns="price_tier",
            values="avg_stars",
            aggfunc="first",
        )
        .reset_index()
        .rename(columns={1: "budget_avg_stars", 2: "mid_range_avg_stars"})
    )
    q6_pivot["mid_minus_budget_gap"] = (
        q6_pivot["mid_range_avg_stars"] - q6_pivot["budget_avg_stars"]
    )
    q6_pivot["city_state"] = q6_pivot["city"] + ", " + q6_pivot["state"]
    q6_plot = q6_pivot.sort_values("city_rank")

    colors = [REPORT_GREEN if v >= 0 else REPORT_RED for v in q6_plot["mid_minus_budget_gap"]]
    plt.figure(figsize=(10, 5.2))
    ax = plt.gca()
    ax.bar(q6_plot["city_state"], q6_plot["mid_minus_budget_gap"], color=colors)
    ax.set_title("Q6: Mid-range vs Budget Rating Gap Across Major Cities")
    ax.set_xlabel("City")
    ax.set_ylabel("Average star gap: Mid-range minus Budget")
    ax.axhline(0, color="black", linewidth=0.8)
    plt.xticks(rotation=35, ha="right")
    for i, value in enumerate(q6_plot["mid_minus_budget_gap"]):
        va = "bottom" if value >= 0 else "top"
        offset = 0.01 if value >= 0 else -0.01
        ax.text(i, value + offset, f"{value:.2f}", ha="center", va=va, fontsize=8)
    save_current_figure("q6_price_by_city.png")


def plot_q7() -> None:
    q7 = read_result("q7_peak_hours_results.csv")
    day_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    q7["day_of_week_name"] = pd.Categorical(q7["day_of_week_name"], categories=day_order, ordered=True)
    heatmap_data = (
        q7.pivot_table(
            index="day_of_week_name",
            columns="checkin_hour",
            values="checkin_count",
            aggfunc="sum",
            fill_value=0,
            observed=False,
        )
        .reindex(day_order)
    )

    plt.figure(figsize=(13, 4.8))
    ax = sns.heatmap(
        heatmap_data,
        cmap="YlGnBu",
        linewidths=0.2,
        linecolor="white",
        cbar_kws={"label": "Check-in count"},
    )
    ax.set_title("Q7: Restaurant Check-in Activity by Day and Hour")
    ax.set_xlabel("Hour of day")
    ax.set_ylabel("Day of week")
    save_current_figure("q7_peak_hours_heatmap.png")


def plot_q8() -> None:
    q8 = read_result("q8_opening_hours_alignment_results.csv")
    coverage_order = ["High coverage", "Partial coverage", "No coverage"]
    q8["peak_coverage_group"] = pd.Categorical(
        q8["peak_coverage_group"], categories=coverage_order, ordered=True
    )
    q8_plot = q8.sort_values("peak_coverage_group")

    plt.figure(figsize=(8, 4.8))
    ax = sns.barplot(
        data=q8_plot,
        x="peak_coverage_group",
        y="avg_stars",
        order=coverage_order,
        color=REPORT_BLUE,
    )
    ax.set_title("Q8: Peak-hour Coverage Does Not Guarantee Higher Ratings")
    ax.set_xlabel("Peak-demand coverage group")
    ax.set_ylabel("Average Yelp star rating")
    ax.set_ylim(0, max(5, q8_plot["avg_stars"].max() + 0.5))
    for container in ax.containers:
        ax.bar_label(container, fmt="%.3f", padding=3, fontsize=9)
    save_current_figure("q8_peak_coverage_rating.png")


def plot_q9() -> None:
    q9 = read_result("q9_competition_density_results.csv")
    q9_city = q9[q9["analysis_level"] == "City market"].copy()
    q9_city["city_state"] = q9_city["city"] + ", " + q9_city["state"]

    plt.figure(figsize=(9, 5.5))
    ax = sns.scatterplot(
        data=q9_city,
        x="restaurant_count",
        y="avg_stars",
        size="avg_review_count",
        sizes=(40, 260),
        color=REPORT_GREEN,
        alpha=0.75,
        legend=False,
    )
    ax.set_title("Q9: Competition Density vs Average Rating by City")
    ax.set_xlabel("Restaurant count in city market")
    ax.set_ylabel("Average Yelp star rating")
    ax.set_ylim(
        max(0, q9_city["avg_stars"].min() - 0.2),
        min(5, q9_city["avg_stars"].max() + 0.2),
    )

    label_df = pd.concat(
        [
            q9_city.nlargest(5, "restaurant_count"),
            q9_city.nlargest(2, "avg_stars"),
            q9_city.nsmallest(2, "avg_stars"),
        ]
    ).drop_duplicates(subset=["city", "state"])
    for _, row in label_df.iterrows():
        ax.annotate(
            row["city_state"],
            (row["restaurant_count"], row["avg_stars"]),
            xytext=(5, 4),
            textcoords="offset points",
            fontsize=8,
        )
    save_current_figure("q9_density_vs_rating.png")


def plot_q10() -> None:
    q10 = read_result("q10_tips_reviews_keywords_results.csv")
    q10_plot = q10[
        ["keyword", "tip_mentions_per_10000_records", "review_mentions_per_10000_records"]
    ].copy()
    q10_plot = q10_plot.sort_values("review_mentions_per_10000_records", ascending=False)
    q10_long = q10_plot.melt(
        id_vars="keyword",
        value_vars=["tip_mentions_per_10000_records", "review_mentions_per_10000_records"],
        var_name="text_source",
        value_name="mentions_per_10000",
    )
    q10_long["text_source"] = q10_long["text_source"].map(
        {
            "tip_mentions_per_10000_records": "Tips",
            "review_mentions_per_10000_records": "Reviews",
        }
    )

    plt.figure(figsize=(10, 5.2))
    ax = sns.barplot(
        data=q10_long,
        x="keyword",
        y="mentions_per_10000",
        hue="text_source",
        palette=[REPORT_ORANGE, REPORT_BLUE],
    )
    ax.set_title("Q10: Operational Complaint Keywords in Tips vs Reviews")
    ax.set_xlabel("Complaint keyword")
    ax.set_ylabel("Mentions per 10,000 text records")
    ax.legend(title="Text source")
    plt.xticks(rotation=20, ha="right")
    save_current_figure("q10_tips_reviews_keywords.png")


def plot_q11() -> None:
    q11 = read_result("q11_failing_winners_results.csv")
    q11_plot = q11[q11["failing_strong_minus_overall_per_10000"] > 0].copy()

    if q11_plot.empty:
        warnings.warn("No positive keyword differences found. Plotting all differences instead.")
        q11_plot = q11.copy()

    q11_plot = q11_plot.sort_values("failing_strong_minus_overall_per_10000", ascending=False)

    plt.figure(figsize=(9, 5))
    ax = sns.barplot(
        data=q11_plot,
        x="keyword",
        y="failing_strong_minus_overall_per_10000",
        color=REPORT_RED,
    )
    ax.set_title("Q11: Complaint Keywords Over-indexing in Failing-strong Restaurants")
    ax.set_xlabel("Complaint keyword")
    ax.set_ylabel("Extra mentions per 10,000 reviews vs overall baseline")
    ax.axhline(0, color="black", linewidth=0.8)
    plt.xticks(rotation=20, ha="right")
    for container in ax.containers:
        ax.bar_label(container, fmt="%.1f", padding=3, fontsize=8)
    save_current_figure("q11_failing_strong_keywords.png")


def print_figure_summary() -> None:
    """Print the output folder and generated PNG files."""
    png_files = sorted(FIGURE_DIR.glob("*.png"))
    print("\nFigure output folder:")
    print(FIGURE_DIR.resolve())

    if png_files:
        print("\nGenerated figure files:")
        for path in png_files:
            print(f"- {path.name}")
    else:
        print("No PNG files found in the figure output folder yet.")


def main() -> None:
    plot_q4()
    plot_q5()
    plot_q6()
    plot_q7()
    plot_q8()
    plot_q9()
    plot_q10()
    plot_q11()
    print_figure_summary()


if __name__ == "__main__":
    main()
