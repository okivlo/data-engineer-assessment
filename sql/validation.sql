-- Load correctness: did the CSV data land in the tables as intended? Read-only; run after the ETL:
-- docker compose exec -T database mysql -ucodetest -pswordfish codetest -t < sql/validation.sql

select check_name, value, expected, if(value = expected, 'OK', 'FAIL') as status
from (

  -- Expected counts are the data rows of the CSV files (the ETL asserts this too).
  select 'rows: departments' as check_name, count(*) as value, 5 as expected from departments
  union all select 'rows: levels', count(*), 6 from levels
  union all select 'rows: employees', count(*), 1435 from employees

  -- Ids loaded completely: no gaps or duplicates between the first and last id.
  union all select 'employee ids not contiguous',
    count(*) - (max(id) - min(id) + 1) + (count(*) - count(distinct id)), 0 from employees

  -- Relations loaded correctly (already enforced by the foreign keys).

) checks;
