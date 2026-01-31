-- Switch to project role context
USE ROLE yumdeal_dev_role;
USE WAREHOUSE yumdeal_wh;
USE DATABASE yumdeal_db;
USE SCHEMA raw;

-- 1. Create File Format
CREATE OR REPLACE FILE FORMAT json_format
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = FALSE;

-- 2. Create Azure Stage (使用占位符)
CREATE OR REPLACE STAGE yumdeal_azure_stage
    URL = '{{ AZURE_BLOB_URL }}'
    CREDENTIALS = (AZURE_SAS_TOKEN = '{{ AZURE_SAS_TOKEN }}')
    FILE_FORMAT = json_format;

-- 3. Create Raw Data Table
CREATE OR REPLACE TABLE deals_raw (
    raw_data VARIANT,
    file_name STRING,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);