--mart - create skills mart
DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;

SELECT'===Loading Skills Dim For Skills Mort ===' AS info;
CREATE TABLE skills_mart.dim_skills(
skills_id INTEGER PRIMARY KEY,
skills VARCHAR,
type VARCHAR

);
  
INSERT INTO skills_mart.dim_skills(
    skills_id,
    skills,
    type
  )

SELECT
    skills_id,
    skills,
    type
FROM skills_dim;

SELECT'===Loading Date Dim For Skills Mort ===' AS info;
CREATE TABLE skills_mart.dim_date_month(
month_start_date DATE  PRIMARY KEY,
year INTEGER,
month INTEGER,
quarter_name VARCHAR,
year_quarter VARCHAR
);

SELECT'===Loading Skill Fact For Skills Mort ===' AS info;
INSERT INTO skills_mart.dim_date_month(
month_start_date ,
year,
month ,
quarter_name ,
year_quarter 
)



SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date):: VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date) :: VARCHAR  || 'Q-' ||
     EXTRACT(QUARTER FROM job_posted_date):: VARCHAR AS year_quarter
    FROM job_postings_fact
ORDER BY month_start_date;

CREATE TABLE skills_mart.fact_skill_demand_monthly(
    skill_id   INTEGER,
    month_start_date  DATE,
    job_title_short VARCHAR,
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_mention_posting_count INTEGER,
   PRIMARY KEY (
    skill_id,
    month_start_date,
    job_title_short
),
FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills(skills_id),
FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)

);

INSERT INTO skills_mart.fact_skill_demand_monthly(
    skill_id   ,
    month_start_date ,
    job_title_short ,
    postings_count ,
    remote_postings_count ,
    health_insurance_postings_count ,
    no_degree_mention_posting_count 

)

WITH job_postings_prep AS (
SELECT
    jpf.job_id,
    sjd.skill_id AS skills_id,
    DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
    jpf.job_title_short,
    CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
    CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_required
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON sjd.job_id = jpf.job_id
)
SELECT
    skills_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS posting_count,
    SUM(is_remote) AS remote_posting_count ,
    SUM(has_health_insurance) AS has_health_insurance_posting_count ,
    SUM(no_degree_required) AS no_degree_required_posting_count
FROM
    job_postings_prep
GROUP BY ALL
ORDER BY skills_id,month_start_date,job_title_short;

SELECT 'Skill Dimension' AS table_name,COUNT(*) AS record_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Month Dimension',COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT'Skill Demand Fact',COUNT(*) FROM skills_mart.fact_skill_demand_monthly;
  
SELECT'===Skills Demand Fact Sample===' AS info;
SELECT * FROM skills_mart.dim_skills LIMIT 5;

SELECT'===Date Month Dimention Sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT'===Skills Demand Fact Sample===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;