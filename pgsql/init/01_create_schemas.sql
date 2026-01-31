-- pgsql/init/01_create_schemas.sql

-- 1. Create Schemas (Foundation of Layered Architecture)
CREATE SCHEMA IF NOT EXISTS raw;     -- Raw data layer (Load layer of ELT)
CREATE SCHEMA IF NOT EXISTS staging; -- Cleaning layer (Transform layer of ELT - View)
CREATE SCHEMA IF NOT EXISTS marts;   -- Business layer (Transform layer of ELT - Table)

-- 2. Create Core Raw Table (Single Table Dual Core Design)
-- This table stores both the raw massive JSON and the parsed lightweight JSON
CREATE TABLE IF NOT EXISTS raw.deals_raw (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    platform TEXT NOT NULL CHECK (platform IN ('ubereats', 'grubhub', 'doordash')),
    
    -- Native Payload (Raw Data)
    -- Uses Postgres TOAST mechanism; large fields are compressed and stored separately,
    -- saving memory I/O when not queried.
    native_payload JSONB,
    
    -- Parsed Payload (Extension Data)
    -- Clean data parsed by the JS plugin, used for fast querying and dbt modeling.
    extension_parsed_payload JSONB,
    
    -- Metadata (URL, Timestamp, UserHash, etc.)
    metadata JSONB,
    
    -- Ingestion time (Used for incremental extraction)
    ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Indexes (Performance Optimization)
-- Create GIN index for extension_parsed_payload to optimize JSON handling
-- Allows efficient querying: WHERE extension_parsed_payload->>'price' > 10
CREATE INDEX IF NOT EXISTS idx_parsed_payload_gin 
ON raw.deals_raw USING GIN (extension_parsed_payload);

-- (Optional) Create index for native_payload, used only for full-text search during debugging
-- If raw data is too large, comment out this line to save space
CREATE INDEX IF NOT EXISTS idx_native_payload_gin 
ON raw.deals_raw USING GIN (native_payload);

-- 4. Permission Settings
-- Ensure the application user has ownership and access rights
GRANT ALL ON SCHEMA raw TO yumdeal_user;
GRANT ALL ON TABLE raw.deals_raw TO yumdeal_user;
GRANT ALL ON SCHEMA staging TO yumdeal_user;
GRANT ALL ON SCHEMA marts TO yumdeal_user;