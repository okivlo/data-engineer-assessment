-- Derived columns and aggregates. Run after cleaning.sql.

create or replace view employee_enriched as
select e.id, e.first_name, e.last_name, e.date_of_birth, e.date_started, e.salary,
       e.department_id, d.department_name, e.level_id, l.level_name,
       timestampdiff(year, e.date_of_birth, curdate()) as age,
       timestampdiff(year, e.date_started, curdate()) as years_at_company,
       not exists (
         select 1 from data_quality_issues i
         where i.table_name = 'employees' and i.record_id = e.id
       ) as is_valid_start_date
from employees e
join departments d on d.id = e.department_id
join levels l on l.id = e.level_id;

create or replace view avg_salary_by_department_level as
select department_name, level_name,
       count(*) as headcount,
       round(avg(salary), 2) as avg_salary
from employee_enriched
group by department_id, department_name, level_id, level_name
order by department_id, level_id;
