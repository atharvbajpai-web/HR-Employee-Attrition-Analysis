# Attrition Analysis

select * from employees;
select * from compensation;
select * from job_details;
select * from satisfaction_performance;

 -- 1. Company-wide headcount, leavers and attrition rate (headline KPI)
select
    count(*) as head_count,
    sum(case when attrition = 'Yes' then 1 else 0 end) as leavers,
    sum(case when attrition = 'No' then 1 else 0 end) as current_employees,
    round(100 * sum(case when attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_Pct
from employees;


-- 2. Attrition by department
select jd.department,
	(select sum(case when attrition='yes' then 1 else 0 end)) as Attrition
from employees as e
join job_details as jd
on e.employee_id = jd.employee_id
group by department;

-- 3. Attrition by job role, highest first
select jd.job_role, 
	(select sum(case when attrition= 'yes' then 1 else 0 end)) as attrition
from employees as e
join job_details as jd
on e.employee_id= jd.employee_id
group by job_role
order by attrition desc;

-- 4. Attrition by gender
select gender, 
	(select sum(case when attrition= 'yes' then 1 else 0 end)) as attrition
from employees
group by gender
order by attrition desc;

-- 5. Attrition by marital status
select marital_status, 
	(select sum(case when attrition= 'yes' then 1 else 0 end)) as attrition
from employees
group by marital_status
order by attrition ;

-- 6. Does overtime drive attrition?
select jd.overtime, 
	(select sum(case when attrition='yes' then 1 else 0 end)) as attrition,
	 round(100.0 * sum(case when e.attrition = 'Yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from employees as e
join job_details as jd
on e.employee_id = jd.employee_id
group by overtime 
order by attrition;
# Yes, overtime drives more attention.

-- 7. Attrition by business-travel frequency
select jd.business_travel, 
	(select sum(case when attrition='yes' then 1 else 0 end)) as attrition
from employees as e
join job_details as jd
on e.employee_id = jd.employee_id
group by business_travel
order by attrition;

-- 8. Average monthly income, avg_hourly rate avg sal hike pct- leavers vs stayers
select 
	case
		when e.attrition = 'yes' then 'Leavers' else 'Stayers'
        end as Employee_status,
	avg(c.monthly_income) as avg_Monthly_Income,
    avg(c.hourly_rate) as avg_Hourly_Rate,
    avg(c.percent_salary_hike) as avg_Salary_Hike_pct
from employees as e
join compensation as c
on e.employee_id = c.employee_id
group by attrition;


-- 9. Attrition by monthly-income band
with cte as (
    select e.attrition,
        case
            when monthly_income < 3000 then '1-3k'
            when monthly_income < 6000 then '3-6k'
            when monthly_income < 10000 then '6-10k'
            when monthly_income < 15000 then '10-15k'
            else '15k+'
        end as income_band
    from employees as e
    join compensation as c
        on e.employee_id = c.employee_id
)
select
    income_band,
    count(*) as headcount,
    sum(case when attrition = 'Yes' then 1 else 0 end) as leavers,
    round(100.0 * sum(case when attrition = 'Yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from cte
group by income_band
order by income_band;


-- 10. Average income by job level: leavers vs stayers (pay gap per level)
select j.job_level,
       round(avg(case when e.attrition = 'no' then c.monthly_income end), 0) as avg_income_stayers,
       round(avg(case when e.attrition = 'yes' then c.monthly_income end), 0) as avg_income_leavers,
       round(avg(case when e.attrition = 'no' then c.monthly_income end)
           - avg(case when e.attrition = 'yes' then c.monthly_income end), 0) as pay_gap
from employees e
join job_details j on j.employee_id = e.employee_id
join compensation c on c.employee_id = e.employee_id
group by j.job_level
order by j.job_level;

-- 11. Do stock options help retention?
select c.stock_option_level,
	(select sum(case when e.attrition='yes' then 1 else 0 end)) as attrition,
round(100 * sum(case when attrition = 'yes' then 1 else 0 end) / count(*), 2) as Attrition_Pct
 from employees as e
 join compensation as c 
 on e.employee_id = c.employee_id
 group by c.stock_option_level;

-- 12. Attrition by tenure bucket (when do people leave?)
with banded as (
    select e.attrition,
           case when j.years_at_company <= 1 then '1. 0-1 yr'
                when j.years_at_company <= 3 then '2. 2-3 yrs'
                when j.years_at_company <= 5 then '3. 4-5 yrs'
                when j.years_at_company <= 10 then '4. 6-10 yrs'
                else '5. 10+ yrs'
           end as tenure_band
    from employees e
    join job_details j on j.employee_id = e.employee_id
)
select tenure_band,
       count(*) as headcount,
       sum(case when attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from banded
group by tenure_band
order by tenure_band;

-- 13. Early-exit analysis: leavers with <= 2 years at the company, by department
select j.department,
       sum(case when e.attrition = 'yes' then 1 else 0 end) as total_leavers,
       sum(case when e.attrition = 'yes' and j.years_at_company <= 2 then 1 else 0 end) as early_leavers,
       round(100.0 * sum(case when e.attrition = 'yes' and j.years_at_company <= 2 then 1 else 0 end)
             / sum(case when e.attrition = 'yes' then 1 else 0 end), 2) as early_leaver_share_pct
from employees e
join job_details j on j.employee_id = e.employee_id
group by j.department
order by early_leaver_share_pct desc;

-- 14. Manager and role stability: average years in role / with manager
select e.attrition,
       round(avg(j.years_at_company), 2) as avg_years_at_company,
       round(avg(j.years_in_current_role), 2) as avg_years_in_role,
       round(avg(j.years_with_curr_manager), 2) as avg_years_with_manager,
       round(avg(j.years_since_last_promotion), 2) as avg_years_since_promotion
from employees e
join job_details j on j.employee_id = e.employee_id
group by e.attrition;

-- 15. Average survey scores: leavers vs stayers
select e.attrition,
       round(avg(s.job_satisfaction), 2) as avg_job_satisfaction,
       round(avg(s.environment_satisfaction), 2) as avg_environment_satisfaction,
       round(avg(s.relationship_satisfaction), 2) as avg_relationship_satisfaction,
       round(avg(s.work_life_balance), 2) as avg_work_life_balance,
       round(avg(s.job_involvement), 2) as avg_job_involvement
from employees e
join satisfaction_performance s on s.employee_id = e.employee_id
group by e.attrition;

-- 16. Job satisfaction score vs attrition rate
select s.job_satisfaction,
       count(*) as headcount,
       sum(case when e.attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when e.attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from employees e
join satisfaction_performance s on s.employee_id = e.employee_id
group by s.job_satisfaction
order by s.job_satisfaction;

-- 17. Work-life balance score vs attrition rate
select s.work_life_balance,
       count(*) as headcount,
       sum(case when e.attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when e.attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from employees e
join satisfaction_performance s on s.employee_id = e.employee_id
group by s.work_life_balance
order by s.work_life_balance;

-- 18. Training frequency vs attrition
select sp.training_times_last_year,
       count(*) as headcount,
       sum(case when e.attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when e.attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from employees e
join satisfaction_performance sp on sp.employee_id = e.employee_id
group by sp.training_times_last_year
order by sp.training_times_last_year;

-- 19. Performance rating vs attrition
select sp.performance_rating,
       count(*) as headcount,
       sum(case when e.attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when e.attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from employees e
join satisfaction_performance sp on sp.employee_id = e.employee_id
group by sp.performance_rating
order by sp.performance_rating;

-- 20. Rank job roles inside each department by attrition rate
with role_stats as (
    select j.department,
           j.job_role,
           count(*) as headcount,
           sum(case when e.attrition = 'yes' then 1 else 0 end) as leavers,
           100.0 * sum(case when e.attrition = 'yes' then 1 else 0 end) / count(*) as attr_rate
    from employees e
    join job_details j on j.employee_id = e.employee_id
    group by j.department, j.job_role
)
select department,
       job_role,
       headcount,
       leavers,
       round(attr_rate, 2) as attrition_rate_pct,
       rank() over (partition by department order by attr_rate desc) as rank_in_department
from role_stats
order by department, rank_in_department;








