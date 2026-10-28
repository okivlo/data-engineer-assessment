-- Check for data inconsistencies in the source data.
-- Every exception is copied into data_quality_issues with the rule that caught it and a reason.

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

-- Summary per rule.
select r.rule, count(i.id) as issues, r.reason
from (
  select 'started_before_birth' as rule, 'Start date is before the date of birth' as reason
  union all select 'started_under_16', 'Employee was under 16 at the start date'
) r
left join data_quality_issues i on i.rule = r.rule
group by r.rule, r.reason
order by field(r.rule, 'started_before_birth', 'started_under_16');
