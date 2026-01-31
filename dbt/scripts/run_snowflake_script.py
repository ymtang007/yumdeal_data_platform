import snowflake.connector
import os
import sys
# Ensure python-dotenv is installed: pip install python-dotenv
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Read configuration
ACCOUNT = os.getenv('SNOWFLAKE_ACCOUNT')
USER = os.getenv('SNOWFLAKE_USER')
PASSWORD = os.getenv('SNOWFLAKE_PASSWORD')
ROLE = os.getenv('SNOWFLAKE_ROLE')
WAREHOUSE = os.getenv('SNOWFLAKE_WAREHOUSE')
DATABASE = os.getenv('SNOWFLAKE_DATABASE')

# Read Azure configuration
AZURE_BLOB_URL = os.getenv('AZURE_BLOB_URL')
AZURE_SAS_TOKEN = os.getenv('AZURE_SAS_TOKEN')

def run_sql_file(filename):
    print(f"Starting execution of: {filename}")
    
    # Establish connection
    ctx = snowflake.connector.connect(
        user=USER,
        password=PASSWORD,
        account=ACCOUNT,
        role=ROLE,
        warehouse=WAREHOUSE,
        database=DATABASE
    )
    cs = ctx.cursor()

    # Read SQL file content
    with open(filename, 'r') as f:
        sql_content = f.read()

    # Key step: Replace placeholders
    # If these values are missing in env, replace with empty strings or raise error
    if '{{ AZURE_BLOB_URL }}' in sql_content:
        if not AZURE_BLOB_URL or not AZURE_SAS_TOKEN:
             raise ValueError("Error: Missing AZURE variables in .env file!")
             
        print("   Injecting Azure credentials from .env...")
        sql_content = sql_content.replace('{{ AZURE_BLOB_URL }}', AZURE_BLOB_URL)
        sql_content = sql_content.replace('{{ AZURE_SAS_TOKEN }}', AZURE_SAS_TOKEN)

    # Split commands by semicolon and execute
    commands = sql_content.split(';')

    try:
        for cmd in commands:
            if cmd.strip():
                # Hide Token in logs to prevent leakage
                log_cmd = cmd.replace(AZURE_SAS_TOKEN, '***HIDDEN***') if AZURE_SAS_TOKEN else cmd
                print(f"   Executing: {log_cmd[:60]}...") 
                cs.execute(cmd)
        print(f"Successfully executed: {filename}")
    except Exception as e:
        print(f"Error executing {filename}: {e}")
    finally:
        cs.close()
        ctx.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python run_snowflake_script.py <path_to_sql_file>")
        sys.exit(1)
    
    run_sql_file(sys.argv[1])