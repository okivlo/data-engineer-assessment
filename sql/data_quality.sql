-- Check for data inconsistencies in the source data.
-- Every exception is copied into data_quality_issues with the rule that caught it and a reason.
-- Derived table: safe to rerun, it is rebuilt from scratch. Run after the ETL:

drop table if exists data_quality_issues;

create table data_quality_issues (
  id int unsigned not null auto_increment,
  table_name varchar(40) not null,
  record_id int unsigned not null,
  rule varchar(60) not null,
  reason varchar(200) not null,
  detail varchar(200) not null,
  detected_at timestamp not null default current_timestamp,
  primary key (id),
  key ix_data_quality_issues_rule (rule)
);

-- The two date rules do not overlap: an employee gets one reason, the most severe.
insert into data_quality_issues (table_name, record_id, rule, reason, detail)
select 'employees', id, 'started_before_birth',
       'Start date is before the date of birth',
       concat('date_of_birth=', date_of_birth, ', date_started=', date_started)
from employees
where date_started < date_of_birth;

-- Age 16 to 17 is plausible and is not flagged.
insert into data_quality_issues (table_name, record_id, rule, reason, detail)
select 'employees', id, 'started_under_16',
       'Employee was under 16 at the start date',
       concat('date_of_birth=', date_of_birth, ', date_started=', date_started,
              ', age_at_start=', timestampdiff(year, date_of_birth, date_started))
from employees
where date_started >= date_of_birth
  and timestampdiff(year, date_of_birth, date_started) < 16;

-- Start date lies in teh future
insert into data_quality_issues (table_name, record_id, rule, reason, detail)
select 'employees', id, 'start_date_in_future',
       'Start date is in the future',
       concat('date_started=', date_started)
from employees
where date_started > curdate();

-- Salary outside 1.5 x IQR of its level (quartiles via row_number: MySQL has no percentile function).
insert into data_quality_issues (table_name, record_id, rule, reason, detail)
with ranked as (
  select id, level_id, salary,
         row_number() over (partition by level_id order by salary) as rn,
         count(*) over (partition by level_id) as n
  from employees
),
quartiles as (
  select level_id,
         min(case when rn >= ceil(0.25 * n) then salary end) as q1,
         min(case when rn >= ceil(0.75 * n) then salary end) as q3
  from ranked
  group by level_id
)
select 'employees', e.id, 'salary_outlier_for_level',
       'Salary is outside 1.5 x IQR of employees at the same level',
       concat('level_id=', e.level_id, ', salary=', e.salary)
from employees e
join quartiles q on q.level_id = e.level_id
where e.salary < q.q1 - 1.5 * (q.q3 - q.q1)
   or e.salary > q.q3 + 1.5 * (q.q3 - q.q1);

-- Summary: the four rules, including those that found nothing.
select r.rule, count(i.id) as issues
from (
  select 'started_before_birth' as rule
  union all select 'started_under_16'
  union all select 'start_date_in_future'
  union all select 'salary_outlier_for_level'
) r
left join data_quality_issues i on i.rule = r.rule
group by r.rule
order by field(r.rule, 'started_before_birth', 'started_under_16', 'start_date_in_future', 'salary_outlier_for_level');
