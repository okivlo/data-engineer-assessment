| Check | Value | Expected | Status | Reason |
|---|---|---|---|---|
| employee ids not contiguous | 0 | 0 | OK | Employee ids have gaps or duplicates, so rows were lost or doubled in the load |
| blank employee names | 0 | 0 | OK | Employees with an empty first or last name |
| blank department names | 0 | 0 | OK | Departments with an empty name |
| blank level names | 0 | 0 | OK | Levels with an empty name |
| orphan employees (department) | 0 | 0 | OK | Employees whose department_id does not exist in departments |
| orphan employees (level) | 0 | 0 | OK | Employees whose level_id does not exist in levels |

| Rule | Issues | Reason |
|---|---|---|
| started_before_birth | 61 | Start date is before the date of birth |
| started_under_16 | 374 | Employee was under 16 at the start date |
