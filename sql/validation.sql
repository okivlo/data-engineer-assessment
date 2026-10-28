-- Load correctness: did the CSV data land in the tables as intended? Read-only; run after the ETL.
-- The ETL logs this table and writes it to reports/validation_report.md.

select check_name, value, expected, if(value = expected, 'OK', 'FAIL') as status, reason
from (

  -- Row counts against the CSV files are asserted by the ETL itself, so they are not repeated here.

  -- Ids loaded completely: no gaps or duplicates between the first and last id.
  select 'employee ids not contiguous' as check_name,
    count(*) - (max(id) - min(id) + 1) + (count(*) - count(distinct id)) as value, 0 as expected,
    'Employee ids have gaps or duplicates, so rows were lost or doubled in the load' as reason
  from employees

  -- Text columns are not blank (NOT NULL is already enforced by the schema).
  union all select 'blank employee names', count(*), 0,
    'Employees with an empty first or last name' from employees
    where trim(first_name) = '' or trim(last_name) = ''
  union all select 'blank department names', count(*), 0,
    'Departments with an empty name' from departments where trim(department_name) = ''
  union all select 'blank level names', count(*), 0,
    'Levels with an empty name' from levels where trim(level_name) = ''

  -- Relations loaded correctly (already enforced by the foreign keys).
  union all select 'orphan employees (department)', count(*), 0,
    'Employees whose department_id does not exist in departments' from employees e
    left join departments d on d.id = e.department_id where d.id is null
  union all select 'orphan employees (level)', count(*), 0,
    'Employees whose level_id does not exist in levels' from employees e
    left join levels l on l.id = e.level_id where l.id is null

) checks;
