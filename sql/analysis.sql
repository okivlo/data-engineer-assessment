-- Analysis queries for the report. Run after transform.sql.
-- report.py reads the result sets by position, so keep the order.

-- 1. Employees with the company for more than 5 years.
-- A date comparison, not years_at_company > 5: that counts completed years and would skip 5.5 years.
select id, first_name, last_name, department_name, level_name, date_started, years_at_company,
       is_valid_start_date
from employee_enriched
where date_started < date_sub(curdate(), interval 5 year)
order by date_started, id;

-- 2. Average salary by department and level.
select department_name, level_name, headcount, avg_salary
from avg_salary_by_department_level;

-- 3. Top 5 highest-paid employees. No tie at rank 5 to be found.
select id, first_name, last_name, department_name, level_name, salary
from employee_enriched
order by salary desc, id
limit 5;

-- 4. Employees per department and level. Empty combinations show as 0.
select d.department_name, l.level_name, count(e.id) as headcount
from departments d
cross join levels l
left join employees e on e.department_id = d.id and e.level_id = l.id
group by d.id, d.department_name, l.id, l.level_name
order by d.id, l.id;

-- 5. Salary spread per level.
select level_name, count(*) as headcount, min(salary) as min_salary,
       round(avg(salary)) as avg_salary, max(salary) as max_salary
from employee_enriched
group by level_id, level_name
order by level_id;

-- 6. Raw salaries per level, for the distribution chart.
select level_name, salary
from employee_enriched
order by level_id;

-- 7. Hires per year.
select year(date_started) as year_started, count(*) as hires
from employee_enriched
group by year_started
order by year_started;
