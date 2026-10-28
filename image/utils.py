def split_statements(sql):
    sql = "".join(line for line in sql.splitlines(keepends=True) if not line.lstrip().startswith("--"))
    return [statement.strip() for statement in sql.split(";") if statement.strip()]


def markdown_table(header, rows):
    return "\n".join(
        [f"| {' | '.join(header)} |", "|" + "---|" * len(header)]
        + [f"| {' | '.join(map(str, row))} |" for row in rows]
    )
