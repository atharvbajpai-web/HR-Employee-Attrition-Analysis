# HR Employee Attrition Analysis

## Project overview
This project explores employee attrition using SQL and an HR analytics dashboard. The analysis is intended to help HR teams understand the scale of employee exits and examine how attrition varies across departments, job roles, age bands, gender, compensation, tenure, work arrangements, and employee survey measures.

## Dashboard snapshot
The dashboard presents headline workforce KPIs and breakdowns of attrition by department, job role, age band, and gender. It also includes a job-satisfaction table and a gender split among leavers within each age group.

![HR Analytics Dashboard](Dashboard.png)

## Headline results
- **Total employees:** 1,470
- **Employees who left:** 237
- **Employees remaining:** 1,233
- **Overall attrition rate:** 16.12%
- **Average age:** 37
- **Leavers by gender:** 150 male and 87 female

These are the values displayed in the supplied dashboard. Counts describe the number of leavers; they should not be interpreted as attrition *rates* unless the relevant group headcount is also considered.

## Tools and technologies
- **SQL / MySQL:** data preparation, relational table design, joins, aggregations, common table expressions (CTEs), conditional aggregation, and window functions.
- **Dashboarding tool:** the supplied dashboard image is consistent with a BI dashboard, but the specific dashboard application is not identified in the provided files.

## Data model
The schema script splits the source HR dataset into four tables linked by `employee_id`:

| Table | Main contents |
|---|---|
| `employees` | Employee demographics, education, distance from home, prior employers, total work experience, and attrition status |
| `job_details` | Department, job role and level, business travel, overtime, tenure, time in current role, promotion, and manager tenure |
| `compensation` | Monthly income, daily/hourly/monthly rates, salary-hike percentage, and stock-option level |
| `satisfaction_performance` | Environment, job, relationship and work-life satisfaction, job involvement, performance rating, and training frequency |

`employees.employee_id` is the primary key. The other three tables use `employee_id` as both their primary key and a foreign key referencing `employees(employee_id)`. The schema script drops the staging table after creating these tables, so retain a source-data backup before running the script in a new environment.

## SQL analyses included
The `Attrition Analysis.sql` script contains queries for:
1. Overall headcount, leavers, stayers, and attrition percentage.
2. Attrition counts by department, job role, gender, and marital status.
3. Leavers by overtime and business-travel category.
4. Average monthly income, hourly rate, and salary-hike percentage for leavers versus stayers.
5. Attrition rates across monthly-income bands and stock-option levels.
6. Average income for leavers versus stayers by job level.
7. Attrition rates across tenure bands and early exits by department.
8. Average tenure, time in role, time with manager, and time since promotion by attrition status.
9. Survey-score comparisons and attrition rates by job satisfaction and work-life balance.
10. Attrition rates by training frequency and performance rating.
11. Ranking job roles within each department by attrition rate.

## How to reproduce
1. Install or open a MySQL-compatible database environment.
2. Load the original HR dataset into a staging table named `hr_attrition_raw`, adapting the import/table name if needed.
3. Review the column names in `schema.sql`; the script expects the source columns shown there.
4. Run `schema.sql` to create the normalized tables and relationships. **Important:** the script ends by dropping `hr_attrition_raw`; back up the raw table first.
5. Run `Attrition Analysis.sql` query-by-query and inspect the result sets.
6. Recreate the dashboard from the query outputs or connect a BI tool to the tables and build the visuals shown in `Dashboard.png`.

## Interpretation notes and limitations
- The dashboard emphasizes **counts** for several demographic and job-category visuals. A larger count can reflect a larger group, not necessarily a higher likelihood of leaving. Use group-specific attrition rates (leavers divided by group headcount) to compare risk fairly.
- The dashboard alone does not establish why employees leave or prove that a factor causes attrition.
- Validate capitalization and category values (`Yes`/`No`) consistently in SQL. MySQL comparisons may be case-insensitive depending on collation, but consistent values improve portability.
- Review the department chart labels and any truncated labels in the dashboard before publishing.
- The supplied files do not identify the BI tool, source-data provenance, or the period covered by the dataset.

## Repository files
- `README.md` — project overview and reproduction guide.
- `Attrition Analysis.sql` — SQL analysis queries.
- `schema.sql` — table creation and relationships.
- `Dashboard.png` — dashboard snapshot.
- `Attrition_Analysis_Report.docx` / `Attrition_Analysis_Report.pdf` — written analysis report.

## Suggested next steps
- Add attrition-rate visuals alongside counts for department, role, age band, and gender.
- Add slicers for department, job role, tenure, overtime, business travel, and stock-option level.
- Check the SQL result sets for missing values, duplicate employee IDs, and unmatched join keys.
- Treat findings as descriptive analysis and validate possible explanations with additional HR context.
