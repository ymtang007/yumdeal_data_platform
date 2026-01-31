-- Switch to admin role for infrastructure setup
USE ROLE ACCOUNTADMIN;

-- 1. Create Compute Resources
CREATE WAREHOUSE IF NOT EXISTS yumdeal_wh 
    WITH WAREHOUSE_SIZE = 'X-SMALL' 
    AUTO_SUSPEND = 60 
    AUTO_RESUME = TRUE;

-- 2. Create Storage Resources
CREATE DATABASE IF NOT EXISTS yumdeal_db;

-- 3. Create RBAC (Role Based Access Control)
CREATE ROLE IF NOT EXISTS yumdeal_dev_role;

-- 4. Grant Permissions
-- Warehouse access
GRANT USAGE, OPERATE ON WAREHOUSE yumdeal_wh TO ROLE yumdeal_dev_role;

-- Database access
GRANT USAGE ON DATABASE yumdeal_db TO ROLE yumdeal_dev_role;

-- Schema access (allows creating tables/stages/formats)
-- Note: 'public' schema is created by default, but we use 'raw'
CREATE SCHEMA IF NOT EXISTS yumdeal_db.raw;
GRANT ALL ON SCHEMA yumdeal_db.raw TO ROLE yumdeal_dev_role;
GRANT CREATE TABLE ON SCHEMA yumdeal_db.raw TO ROLE yumdeal_dev_role;
GRANT CREATE STAGE ON SCHEMA yumdeal_db.raw TO ROLE yumdeal_dev_role;
GRANT CREATE FILE FORMAT ON SCHEMA yumdeal_db.raw TO ROLE yumdeal_dev_role;

-- 5. Assign Role to User
GRANT ROLE yumdeal_dev_role TO USER yumdeal;