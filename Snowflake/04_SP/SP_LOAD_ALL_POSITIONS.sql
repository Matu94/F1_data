CREATE OR REPLACE PROCEDURE RAW.SP_LOAD_ALL_POSITIONS()
RETURNS STRING
LANGUAGE PYTHON
COMMENT = 'F1 project: Get the data from the API endpoint and load it to the POSITIONS table'
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'requests', 'pandas')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (F1_API_INTEGRATION)
EXECUTE AS OWNER
AS
$$
import snowflake.snowpark as snowpark
import requests
import pandas as pd

def main(session: snowpark.Session):
    # 1. Get the list of session_keys from the RAW.V_SESSIONS
    # use collect() to bring the keys into Python memory for looping
    # Note: Snowflake returns column names in UPPERCASE by default
    session_rows = session.sql("SELECT DISTINCT session_key FROM RAW.V_SESSIONS where session_type = 'Race'").collect()
    
    base_url = "https://api.openf1.org/v1/position"
    all_positions_data = []
    processed_count = 0
    
    # 2. Loop through each session and fetch data
    for row in session_rows:
        s_key = row['SESSION_KEY']
        
        # build the parameterized URL
        api_url = f"{base_url}?session_key={s_key}"
        
        try:
            response = requests.get(api_url)
            response.raise_for_status() # Raise error for bad responses 
            
            data = response.json()
            
            # The API returns a list of position objects
            if isinstance(data, list) and len(data) > 0:
                all_positions_data.extend(data)
                
            processed_count += 1
            
        except Exception as e:
            # log errors instead of failing completely 
            print(f"Error fetching data for session {s_key}: {e}")

    # 3. Write Data to Snowflake
    if all_positions_data:
        # Create a DataFrame from the collected list of dicts
        # Snowpark will automatically infer the schema from the JSON keys
        df = session.create_dataframe(all_positions_data)
        
        # Write to the target table (Mode: append to add to existing data)
        # Ensure the target table RAW.POSITIONS exists or let Snowpark create it
        df.write.mode("append").save_as_table("RAW.POSITIONS")
        
        return f"Success: Processed {processed_count} sessions. Loaded {len(all_positions_data)} position records."
    
    return "No data found to load."
$$;
