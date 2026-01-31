with source as (

    -- 1. Reference the source configuration
    select * from {{ source('yumdeal', 'deals_raw') }}

),

renamed as (

    select
        -- 2. Extract fields from RAW_DATA (JSON)
        -- Note: Snowflake JSON is case-sensitive. Based on previous observations, 
        -- keys "metadata" and "url" are lowercase.
        -- Therefore, we assume "id" is also lowercase.
        
        raw_data:id::string as deal_id,
        raw_data:url::string as deal_url,
        raw_data:title::string as title,
        raw_data:price::float as price,
        
        -- Extract nested timestamp from metadata
        raw_data:metadata:timestamp::timestamp as raw_timestamp,
        
        -- Retain file information
        file_name,
        ingested_at

    from source

)

select * from renamed