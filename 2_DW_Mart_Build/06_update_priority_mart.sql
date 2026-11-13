---step 6:Mart- update priority role mart


SELECT '=== Updating Role for priority Mart ===' AS info;

--update data enginner to priority 1
UPDATE priority_mart.priority_role
SET priority_lvl = 1
WHERE role_name = 'Data Engineer';

--add data scientist as level 3
INSERT INTO priority_mart.priority_role (role_id, role_name, priority_lvl)
VALUES (4, 'Data Scientist', 3)
ON CONFLICT (role_id) DO UPDATE
SET role_name = excluded.role_name,
    priority_lvl = excluded.priority_lvl;

SELECT * FROM priority_mart.priority_role;

-----------------------




-- Step 3: Create temporary source table
-- This table contains the current state of priority jobs from the data warehouse
CREATE OR REPLACE TEMP TABLE src_priority_jobs AS 
SELECT 
  jpf.job_id,
  jpf.job_title_short,
  cd.name AS company_name,
  jpf.job_posted_date,
  jpf.salary_year_avg,
  r.priority_lvl,
  CURRENT_TIMESTAMP AS updated_at
FROM
    job_postings_fact AS jpf                          -- updated to use main schema
LEFT JOIN company_dim AS cd                           -- updated to use main schema
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_role AS r
    ON jpf.job_title_short = r.role_name;

-- Step 4: MERGE operation to update snapshot

MERGE INTO priority_mart.priority_jobs_snapshot AS tgt     -- updated to use priority_mart schema
USING src_priority_jobs AS src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at

WHEN NOT MATCHED THEN
    INSERT (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_lvl,
        updated_at
    )
    VALUES (
        src.job_id,
        src.job_title_short,
        src.company_name,
        src.job_posted_date,
        src.salary_year_avg,
        src.priority_lvl,
        src.updated_at
    )

WHEN NOT MATCHED BY SOURCE THEN DELETE;

-- Verify mart was updated
SELECT 'Priority Roles Dimension' AS table_name, COUNT(*) as record_count FROM priority_mart.priority_role
UNION ALL
SELECT 'Priority Jobs Snapshot', COUNT(*) FROM priority_mart.priority_jobs_snapshot;

-- Show sample data from each table
SELECT '=== Priority Roles Dimension Sample ===' AS info;
SELECT * FROM priority_mart.priority_role;

SELECT '=== Priority Jobs Snapshot Sample ===' AS info;
SELECT 
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_mart.priority_jobs_snapshot          -- updated to use priority_mart schema
GROUP BY job_title_short
ORDER BY job_count DESC;
