# Assessment for Data Engineer Candidates for DataGreen

## Purpose

This test is designed to showcase your understanding of databases and data processing, together with your aptitude in a python.

## Prerequisites

- Knowledge of relational databases, including how to create tables, insert data, and query data. For the purpose of this test, we are using MySQL.
- Knowledge of a programming language, including how to read and write files, process data, and access a MySQL database.
- Familiarity with Docker for container management, which we use through the Docker Compose tool. You will need Docker and Docker Compose installed on your development machine.

We have included example data and programme code. The example schema creates a simple table, with example code in several common programming languages to load data from a CSV file and output to a JSON file. There are instructions towards the bottom of this document explaining how to use the Docker containers, start the database, and use the examples.

## Background

We have provided a Github repo containing:

- A **docker compose.yml** file that configures a container for the MySQL database, and the example scripts’ containers.
- An **images** folder containing example programmes showing how the database can be accessed from C, Node, Python, R, Ruby, and Swift.
- An **example_schema.sql** file containing a table schema used by the example scripts.
- A **data** folder containing four files:
  - **example.csv** A tiny dataset, used by the example scripts.
  - **departments.csv** 6 rows, where each rows has an id and a department name
  - **employees.csv** 1,435 rows, where each row has a id, fist_name, last_name, date_of_birth_department_id, date_started, level_id, and salaru.
  - **levels.csv** 7 rows, where each row has id and level_name.

## Assignments

There are a sequence of steps that we would like you to complete. We hope this won't take more than a couple of hours of your time. The assessment consists of the following assignments:

1. Docker and MySQL Setup
2. Data Ingestion and Validation
3. Data Cleaning and Transformation
4. ETL Process and Automation
5. SQL and Data Analysis
6. Data Visualization and Reporting

### Assignment 1: Docker and MySQL Setup
**Objective**: Demonstrate skills in setting up a Docker environment with MySQL.

**Tasks**:

1. **MySQL Database Initialization**:
    * Create initialization scripts to set up the MySQL database schema, including tables for employees, departments, and levels.
    * Include these scripts in your Docker setup so that the MySQL container initializes the database correctly.

**Deliverables**:

* Adjusted `docker-compose.yml` file for setting up the MySQL container.
* SQL scripts for database schema creation and sample data insertion.

### Assignment 2: Data Ingestion and Validation
**Objective**: Demonstrate skills in data ingestion and validation using MySQL within Docker.

**Tasks**:

1. **Load Data into MySQL**:
    * Use the provided `employees.csv`, `departments.csv`, and `levels.csv` files.
    * Write a script or use a tool to load these CSV files into the MySQL database within the Docker container.
2. **Data Validation**:
    * Write SQL queries to validate that the data has been loaded correctly.
    * Check for and report any issues such as missing values or data inconsistencies.

**Deliverables**:

* Scripts or tools used for data ingestion.
* SQL queries used for data validation.
* A report detailing the data validation results and any issues found.

### Assignment 3: Data Cleaning and Transformation
**Objective**: Demonstrate skills in data cleaning and transformation within MySQL.

**Tasks**:

1. **Clean the Data**:
    * Write SQL queries to identify and handle missing values, inconsistent data, and outliers.
    * Perform data cleaning operations directly in the MySQL database.
2. **Transform the Data**:
    * Create new derived columns (e.g., years_at_company, age) using SQL queries.
    * Aggregate data to calculate average salaries by department and level.

**Deliverables**:

* SQL scripts used for data cleaning and transformation.
* Results of the transformations, such as aggregated tables or cleaned data outputs.
* A report explaining the cleaning and transformation process.

### Assignment 4: ETL Process and Automation
**Objective**: Demonstrate skills in building and automating ETL processes.

**Tasks**:

1. **Create an ETL Pipeline**:
    * Develop an ETL pipeline that extracts data from the provided CSV files, transforms it (cleaning, validation), and loads it into MySQL.
    * Use a scripting language (e.g., Python with pandas and SQLAlchemy) or an ETL tool.
2. **Automate the ETL Process**:
    * Set up a cron job or a scheduled task within the Docker container to automate the ETL process.

**Deliverables**:

* ETL scripts or pipeline configurations.
* Instructions for automating the ETL process.
* Documentation of how to schedule and run the ETL process.

### Assignment 5: SQL and Data Analysis
**Objective**: Demonstrate skills in SQL querying and data analysis.

**Tasks**:

1. **Database Queries**:
    * Write SQL queries to answer specific questions:
        * List employees who have been with the company for more than 5 years.
        * Find the average salary by department and level.
        * Identify the top 5 highest-paid employees.
        * Count employees in each level and department.
2. **Data Analysis**:
    * Perform data analysis to uncover insights, such as trends in salaries or employee distribution.

**Deliverables**:
* SQL queries with results.
* Analysis report with insights and visualizations (if applicable).

### Assignment 6: Data Visualization and Reporting
**Objective**: Demonstrate skills in data visualization and reporting.

**Tasks**:

1. **Data Visualization**:
    * Create visualizations to show distributions and trends using tools like Matplotlib, Seaborn, or Tableau (if external tools are allowed).
    * Visualize employee distribution across departments and levels, and trends in salaries.
2. **Reporting**:
    * Generate a report summarizing the data insights, visualizations, and any recommendations.

**Deliverables**:
* Visualization scripts or reports.
* Analysis and insights report.

## Notes on completing these assignments

- We have provided an example schema and code that shows how to handle a simple data ingest and output.
- Details of how to run and connect to the database are below, together with how to use the example schema and code.
- There is no right way to do this. We are interested in the choices that you make, how you justify them, and your development process.
- Consider how normalized your schema should be, and whether or not you should be using foreign keys to join tables.
- When you create a container, make sure that you add the container config to the docker compose.yml file, and add your Dockerfile and code to the images folder.
- Make sure that your code is executable.
- Consider what kind of error handling and testing is appropriate.
- All data input, storage, and output should be in UTF-8. Expect multi-byte characters in the data.
- The MySQL database storage is ephemeral; it will not persist, so make sure all schema and data queries are repeatable.
- You may find it easier to work with a subset of the data when developing your ingest.

## Notes on using the images in the git repo

### Requirements

Make sure you have recent versions of Docker and Docker Compose.

### Building the images

This will build all of the images referenced in the Docker Compose file. You will need to re-run this after making code changes. (You can also specify individual services to build if that is more convenient.)

```
docker compose build
```

### Starting MySQL

To start up the MySQL database. This will will take a short while to run the database’s start-up scripts.

```
docker compose up database
```

Optional: if you want to connect to the MySQL database via the command-line client. This may be useful for looking at the database schema or data.

```
docker compose run database mysql --host=database --user=codetest --password=swordfish codetest
```

### Example scripts

We have provided example code written in Python. This shows how to use a programme in a separate Docker container to connect to the database, using an ORM library where appropriate, to load data from a CSV file, and to query data to output as a JSON file. There should be regarded as illustrative; it is fine to use any of these examples as the basis of your own solution, but we would prefer that you use technologies that you feel comfortable with.

Make sure the MySQL database is running, and then load the example schema with:

```
docker compose run --no-TTY database mysql --host=database --user=codetest --password=swordfish codetest <example_schema.sql
```

Then make sure that the containers have been built with `docker compose build` and run the sample program with:

```
docker compose run python
```

In this case, the programme loads data from the data/example.csv file into that table, and exports data from the database table to a JSON file in the data folder. Note that the script does not truncate the table, so each one you run will add additional content.

### Cleaning up

To tidy up, bringing down all the containers and deleting them.

```
docker compose down
```
