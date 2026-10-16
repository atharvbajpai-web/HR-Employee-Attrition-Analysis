# schema

create database hr_employee_attrition;
show tables;
rename table `hr-employee-attrition` to hr_attrition_raw;
alter table hr_attrition_raw rename column ï»¿Age to age;
# splitting the data into 4 tables

CREATE TABLE employees AS
SELECT Employee_Number      AS employee_id,
       Age                  AS age,
       Gender               AS gender,
       Marital_Status       AS marital_status,
       Education            AS education_level,
       Education_Field      AS education_field,
       Distance_From_Home   AS distance_from_home,
       Num_Companies_Worked AS num_companies_worked,
       Total_Working_Years  AS total_working_years,
       Attrition            AS attrition
FROM hr_attrition_raw;

CREATE TABLE job_details AS
SELECT Employee_Number             AS employee_id,
       Department                  AS department,
       Job_Role                    AS job_role,
       Job_Level                   AS job_level,
       Business_Travel             AS business_travel,
       Over_Time                   AS overtime,
       Years_At_Company            AS years_at_company,
       Years_In_CurrentRole        AS years_in_current_role,
       Years_Since_Last_Promotion  AS years_since_last_promotion,
       Years_With_Curr_Manager     AS years_with_curr_manager
FROM hr_attrition_raw;

CREATE TABLE compensation AS
SELECT Employee_Number      AS employee_id,
       Monthly_Income       AS monthly_income,
       Daily_Rate           AS daily_rate,
       Hourly_Rate          AS hourly_rate,
       Monthly_Rate         AS monthly_rate,
       Percent_Salary_Hike  AS percent_salary_hike,
       Stock_Option_Level   AS stock_option_level
FROM hr_attrition_raw;

CREATE TABLE satisfaction_performance AS
SELECT Employee_Number            AS employee_id,
       Environment_Satisfaction   AS environment_satisfaction,
       Job_Satisfaction           AS job_satisfaction,
       Relationship_Satisfaction  AS relationship_satisfaction,
       Work_Life_Balance          AS work_life_balance,
       Job_Involvement            AS job_involvement,
       Performance_Rating         AS performance_rating,
       Training_Times_Last_Year   AS training_times_last_year
FROM hr_attrition_raw;

# Adding primary and foreign keys 
ALTER TABLE employees ADD PRIMARY KEY (employee_id);
ALTER TABLE job_details ADD PRIMARY KEY (employee_id),
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE compensation ADD PRIMARY KEY (employee_id),
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE satisfaction_performance ADD PRIMARY KEY (employee_id),
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

# dropping raw table
drop table hr_attrition_raw;

select count(*) from employees;
select count(*) from compensation;
select count(*) from job_details;
select count(*) from satisfaction_performance;


