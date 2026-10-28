-- Clean the loaded data in place. Safe to rerun. Run after data_quality.sql.
-- Rows in data_quality_issues are flagged (is_valid_start_date in transform.sql)

update employees
set first_name = trim(first_name),
    last_name = trim(last_name)
where first_name <> trim(first_name)
   or last_name <> trim(last_name);

update departments set department_name = trim(department_name) where department_name <> trim(department_name);

update levels set level_name = trim(level_name) where level_name <> trim(level_name);
