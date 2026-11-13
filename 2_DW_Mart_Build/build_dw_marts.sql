
---duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

--step1: CREATE TABLES FOR DATA WAREHOUSE
.read 01_create_tables_dw.sql

--STEP 2: Load the data FROM CSV INTO tables
.read 02_load_schema_dw.sql

--create flat mart table
.read 03_create_flat_mart.sql

--mart - create skills mart
.read 04_create_skills_mart.sql

--step5:Mart- create priority role mart
.read 05_create_priority_mart.sql

---step 6:Mart- update priority role mart
.read 06_update_priority_mart.sql
