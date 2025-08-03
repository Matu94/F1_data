CREATE OR REPLACE PROCEDURE F1.RAW.SP_LOAD_ALL_MEETINGS()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (F1_API_INTEGRATION)
EXECUTE AS OWNER
AS '
import urllib.request
import json
import sys

def main(session):

    API_URL = "https://api.openf1.org/v1/meetings?year=2025"
    TARGET_TABLE = "F1.RAW.MEETINGS"
    
    try:
        # 1. API adatok lekérése
        req = urllib.request.Request(API_URL)
        with urllib.request.urlopen(req) as response:
            if response.getcode() != 200:
                return f"Error: API returned status code {response.getcode()}"
            
            meetings_data = json.loads(response.read())
        
        if not meetings_data:
            return "Info: No data received from API side."
        
        # Truncate target before ingest
        session.sql(f"TRUNCATE TABLE {TARGET_TABLE}").collect()
        
        # Ingest data into target
        row_count = 0
        for meeting in meetings_data:
            json_string = json.dumps(meeting)
            
            session.sql(
                f"INSERT INTO {TARGET_TABLE} (RAW_PAYLOAD) SELECT PARSE_JSON(?);",
                params=[json_string]
            ).collect()
            row_count += 1
            
        return f"Success! {row_count} rows loaded into {TARGET_TABLE}."
            
    
    except urllib.error.URLError as e:
        return f"Network error occurred: {e}"
    except json.JSONDecodeError:
        return "Error parsing JSON response."
    except Exception as e:
        return f"An unexpected error occurred: {e}"
';