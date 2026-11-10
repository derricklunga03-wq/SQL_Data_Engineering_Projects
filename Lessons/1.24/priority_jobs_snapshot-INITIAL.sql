CREATE OR REPLACE TABLE main.priority_jobs_snapshot (
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP 
);

INSERT INTO main.priority_jobs_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at)

    SELECT
        jfd.job_id,
        jfd.job_title_short,
        cd.company_name as company_name,
        jfd.job_posted_date,
        jfd.salary_year_avg,
        r.priority_lvl,
        CURRENT_TIMESTAMP  
        FROM