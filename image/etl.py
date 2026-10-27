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
    with engine.begin() as conn:  # One transaction means we either load everything or nothing. Conscious choice.

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


if __name__ == "__main__":
    load(sqlalchemy.create_engine(DATABASE_URL))
