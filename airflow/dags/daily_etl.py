from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# Default arguments for the DAG configuration
default_args = {
    'owner': 'yumdeal',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define DAG to run daily at 2 AM UTC
# Orchestrates the ELT pipeline: Azure Blob to Snowflake RAW to dbt Transform
dag = DAG(
    'yumdeal_daily_etl_snowflake',
    default_args=default_args,
    description='Daily ELT: Azure Blob -> Snowflake Raw -> dbt Transform',
    schedule_interval='0 2 * * *',
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=['yumdeal', 'snowflake', 'elt'],
)

# Task 1: Extract and Load
# Loads data directly from Azure Blob Storage into the Snowflake RAW table using COPY INTO.
# This approach bypasses local processing for efficiency.
copy_into_snowflake = SnowflakeOperator(
    task_id='load_blob_to_snowflake_raw',
    snowflake_conn_id='snowflake_default', # Ensure this ID is configured in Airflow Connections
    sql="""
        COPY INTO yumdeal_db.raw.deals_raw
        (raw_data, file_name, ingested_at)
        FROM (
            SELECT 
                $1,             -- The JSON content
                metadata$filename, 
                CURRENT_TIMESTAMP()
            FROM @yumdeal_db.raw.yumdeal_azure_stage
        )
        FILE_FORMAT = (FORMAT_NAME = 'yumdeal_db.raw.json_format')
        PATTERN = '.*.json'     -- Only load JSON files
        ON_ERROR = CONTINUE;    -- Skip bad files instead of failing the whole batch
    """,
    dag=dag
)

# Task 2: Transform
# Executes dbt models to parse JSON data into structured tables (Staging and Marts).
run_dbt = BashOperator(
    task_id='dbt_run_snowflake',
    # Uses the snowflake_prod target profile
    bash_command='''
        cd /opt/airflow/dbt && \
        dbt run --profiles-dir . --target snowflake_prod
    ''',
    dag=dag
)

# Task 3: Data Quality Check
# Verifies primary key uniqueness and maintains data integrity.
test_dbt = BashOperator(
    task_id='dbt_test_snowflake',
    bash_command='''
        cd /opt/airflow/dbt && \
        dbt test --profiles-dir . --target snowflake_prod
    ''',
    dag=dag
)

# Task 4: Snapshots (SCD Type 2)
# Archives historical data to track price changes over time.
snapshot_dbt = BashOperator(
    task_id='dbt_snapshot_snowflake',
    bash_command='''
        cd /opt/airflow/dbt && \
        dbt snapshot --profiles-dir . --target snowflake_prod
    ''',
    dag=dag
)

# Define task execution order
copy_into_snowflake >> run_dbt >> test_dbt >> snapshot_dbt