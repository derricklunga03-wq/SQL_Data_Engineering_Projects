SELECT
    table_name,
    column_name,
    data_type
FROM 
    information_schema.columns
 WHERE table_name = 'job_postings_fact';


DESCRIBE 
SELECT 
   job_title_short,
    salary_year_avg,
FROM
     job_postings_fact;
    