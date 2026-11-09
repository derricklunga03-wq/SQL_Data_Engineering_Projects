EXPLAIN ANALYZE
SELECT
    cd.name AS cumpany_name,
    COUNT(jpf.*) AS postings_count,
    FROM job_postings_fact AS jpf
    LEFT JOIN company_dim  AS cd
    ON jpf.company_id = cd.company_id
    WHERE jpf.job_country = 'United States'
GROUP BY cd.name
HAVING COUNT(jpf.job_country) > 3000;