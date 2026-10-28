import os

import matplotlib

import matplotlib.pyplot as plt

from utils import markdown_table

COLOR = "#2a6f97"
TENURE_ROWS_SHOWN = 10

matplotlib.use("Agg")  # No display in the container.

def pivot(rows):
    """Turn (row label, column label, value) rows into labels and a grid, keeping first-seen order."""
    row_labels = list(dict.fromkeys(r[0] for r in rows))
    col_labels = list(dict.fromkeys(r[1] for r in rows))
    values = {(r[0], r[1]): r[2] for r in rows}
    grid = [[values.get((r, c), 0) for c in col_labels] for r in row_labels]
    return row_labels, col_labels, grid


def save(fig, report_dir, name):
    fig.tight_layout()
    fig.savefig(os.path.join(report_dir, name), dpi=120)
    plt.close(fig)


def headcount_heatmap(report_dir, headcount):
    departments, levels, grid = pivot(headcount)
    fig, ax = plt.subplots(figsize=(7, 4))
    image = ax.imshow(grid, cmap="Blues")
    ax.set_xticks(range(len(levels)), levels)
    ax.set_yticks(range(len(departments)), departments)
    for y, row in enumerate(grid):
        for x, value in enumerate(row):
            ax.text(x, y, value, ha="center", va="center")
    fig.colorbar(image, ax=ax, label="Employees")
    ax.set_title("Headcount by department and level")
    save(fig, report_dir, "headcount_heatmap.png")


def salary_by_level(report_dir, salaries):
    levels = list(dict.fromkeys(level for level, _ in salaries))
    data = [[float(salary) for level, salary in salaries if level == name] for name in levels]
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.boxplot(data)
    ax.set_xticklabels(levels)
    ax.set_ylabel("Salary")
    ax.set_title("Salary distribution by level")
    save(fig, report_dir, "salary_by_level.png")


def avg_salary_by_department(report_dir, avg_salaries):
    """Average per department, weighted by headcount per level."""
    totals = {}
    for department, _, headcount, avg_salary in avg_salaries:
        count, total = totals.get(department, (0, 0))
        totals[department] = (count + headcount, total + headcount * float(avg_salary))
    departments = list(totals)
    averages = [totals[d][1] / totals[d][0] for d in departments]
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.bar(departments, averages, color=COLOR)
    ax.set_ylabel("Average salary")
    ax.set_title("Average salary by department")
    save(fig, report_dir, "avg_salary_by_department.png")


def hires_per_year(report_dir, hires):
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.bar(range(len(hires)), [count for _, count in hires], color=COLOR)
    ax.set_xticks(range(len(hires)), [year for year, _ in hires], rotation=90)
    ax.set_ylabel("Hires")
    ax.set_title("Hires per year")
    save(fig, report_dir, "hires_per_year.png")


def write(results, report_dir):
    """Write analysis_report.md and its charts. results are the result sets of analysis.sql, in order."""
    tenure, avg_salaries, top_5, headcount, spread, salaries, hires = results
    os.makedirs(report_dir, exist_ok=True)

    headcount_heatmap(report_dir, headcount)
    salary_by_level(report_dir, salaries)
    avg_salary_by_department(report_dir, avg_salaries)
    hires_per_year(report_dir, hires)

    flagged = sum(1 for row in tenure if not row.is_valid_start_date)
    departments, levels, grid = pivot(headcount)
    sections = [
        "# Analysis report",
        "## 1. More than 5 years with the company\n"
        f"{len(tenure)} employees, of which {flagged} have a start date flagged in `data_quality_issues`, "
        f"so their tenure is unreliable. First {TENURE_ROWS_SHOWN} by start date:\n\n"
        + markdown_table(
            ["Id", "First name", "Last name", "Department", "Level", "Started", "Years", "Valid start date"],
            tenure[:TENURE_ROWS_SHOWN],
        ),
        "## 2. Average salary by department and level\n"
        + markdown_table(["Department", "Level", "Employees", "Average salary"], avg_salaries),
        "## 3. Top 5 highest-paid employees\n"
        + markdown_table(["Id", "First name", "Last name", "Department", "Level", "Salary"], top_5),
        "## 4. Employees by department and level\n"
        + markdown_table(["Department"] + levels, [[d] + row for d, row in zip(departments, grid)])
        + "\n\n![Headcount by department and level](headcount_heatmap.png)",
        "## 5. Salary by level\n"
        + markdown_table(["Level", "Employees", "Min", "Average", "Max"], spread)
        + "\n\n![Salary distribution by level](salary_by_level.png)",
        "## 6. Average salary by department\n![Average salary by department](avg_salary_by_department.png)",
        "## 7. Hires per year\n"
        + markdown_table(["Year", "Hires"], hires)
        + "\n\n![Hires per year](hires_per_year.png)",
    ]
    with open(os.path.join(report_dir, "analysis_report.md"), "w", encoding="utf-8") as f:
        f.write("\n\n".join(sections))
        f.write("\n")
