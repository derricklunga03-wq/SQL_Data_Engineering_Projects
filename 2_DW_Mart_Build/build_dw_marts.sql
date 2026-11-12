
---duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

--step1: CREATE TABLES FOR DATA WAREHOUSE
.read 01_create_tables_dw.sql

--STEP 2: Load the data FROM CSV INTO tables
.read 02_load_schema_dw.sql
