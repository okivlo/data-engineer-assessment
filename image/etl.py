#!/usr/bin/env python

import csv
import logging
import os

import sqlalchemy

# Normally you'd use a .env file.
DATABASE_URL = os.environ.get(
    "DATABASE_URL", "mysql://codetest:swordfish@database/codetest?charset=utf8mb4"
)
DATA_DIR = os.environ.get("DATA_DIR", "/data")
SQL_DIR = os.environ.get("SQL_DIR", "/sql")
REPORT_DIR = os.environ.get("REPORT_DIR", "/reports")

# Parent tables first, due to foreign key constraints.
TABLES = [
    ("departments", ["id", "department_name"]),
    ("levels", ["id", "level_name"]),
    (
        "employees",
        [
            "id",
            "first_name",
            "last_name",
            "date_of_birth",
            "department_id",
            "date_started",
            "level_id",
            "salary",
        ],
    ),
]

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("etl")


def read_csv(table, columns):
    with open(os.path.join(DATA_DIR, f"{table}.csv"), encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    if rows and list(rows[0]) != columns:
        raise SystemExit(f"{table}.csv has columns {list(rows[0])}, expected {columns}")
    return rows


def load(engine):
    with engine.begin() as conn:  # All or nothing

        for table, _ in reversed(TABLES):
            conn.execute(sqlalchemy.text(f"delete from {table}"))

        for table, columns in TABLES:
            rows = read_csv(table, columns)
            insert = f"insert into {table} ({', '.join(columns)}) values ({', '.join(':' + c for c in columns)})"
            conn.execute(sqlalchemy.text(insert), rows)
            loaded = conn.execute(sqlalchemy.text(f"select count(*) from {table}")).scalar()
            if loaded != len(rows):
                raise SystemExit(f"{table}: {len(rows)} rows in CSV but {loaded} loaded")
            log.info("%s: %d rows loaded", table, loaded)


def split_statements(sql):
    sql = "".join(line for line in sql.splitlines(keepends=True) if not line.lstrip().startswith("--"))
    return [statement.strip() for statement in sql.split(";") if statement.strip()]


def run_script(engine, name):
    with open(os.path.join(SQL_DIR, name), encoding="utf-8") as f:
        statements = split_statements(f.read())
    results = []
    with engine.begin() as conn:
        for statement in statements:
            result = conn.exec_driver_sql(statement)
            if result.returns_rows:
                results.append(result.fetchall())
    return results


def markdown_table(header, rows):
    return "\n".join(
        [f"| {' | '.join(header)} |", "|" + "---|" * len(header)]
        + [f"| {' | '.join(map(str, row))} |" for row in rows]
    )


if __name__ == "__main__":
    engine = sqlalchemy.create_engine(DATABASE_URL)
    load(engine)

    (checks,) = run_script(engine, "validation.sql")
    (issues,) = run_script(engine, "data_quality.sql")
    os.makedirs(REPORT_DIR, exist_ok=True)
    with open(os.path.join(REPORT_DIR, "validation_report.md"), "w", encoding="utf-8") as f:
        f.write(markdown_table(["Check", "Value", "Expected", "Status", "Reason"], checks))
        f.write("\n\n")
        f.write(markdown_table(["Rule", "Issues", "Reason"], issues))
        f.write("\n")
    if any(check.status == "FAIL" for check in checks):
        raise SystemExit("Validation failed, see validation_report.md")

    for script in ("cleaning.sql", "transform.sql"):
        run_script(engine, script)
        log.info("%s done", script)
