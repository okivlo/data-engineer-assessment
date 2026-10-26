-- Schema for the datasets. Repeatable, drops in dependency order.
-- Also added some obvious validation tests.

drop table if exists employees;
drop table if exists departments;
drop table if exists levels;

create table departments (
  id int unsigned not null,
  department_name varchar(80) not null,
  primary key (id),
  unique key uq_departments_name (department_name)
);

create table levels (
  id int unsigned not null,
  level_name varchar(80) not null,
  primary key (id),
  unique key uq_levels_name (level_name)
);

create table employees (
  id int unsigned not null,
  first_name varchar(80) not null,
  last_name varchar(80) not null,
  date_of_birth date not null,
  department_id int unsigned not null,
  date_started date not null,
  level_id int unsigned not null,
  salary decimal(10, 2) not null,
  primary key (id),
  constraint fk_employees_department foreign key (department_id)
    references departments (id) on delete restrict on update cascade,
  constraint fk_employees_level foreign key (level_id)
    references levels (id) on delete restrict on update cascade,
  constraint chk_employees_salary check (salary > 0),
  constraint chk_employees_started_after_birth check (date_started >= date_of_birth)
);
