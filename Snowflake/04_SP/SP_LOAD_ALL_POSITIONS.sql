CREATE OR REPLACE PROCEDURE RAW.SP_LOAD_ALL_POSITIONS()
RETURNS VARCHAR
LANGUAGE PYTHON
COMMENT = 'F1 project: Get the data from the API endpoint and load it to the POSITIONS table'
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (F1_API_INTEGRATION)
EXECUTE AS OWNER
AS 
$$
import urllib.request
import json
import sys

def main(session):

    """
    Loads position data for all Race sessions found in RAW.V_SESSIONS.
    """

    API_BASE_URL = "https://api.openf1.org/v1/position"
    TARGET_TABLE = "RAW.POSITIONS"
    
    try:
        # 1. Get the list of session_keys from RAW.V_SESSIONS
        # We assume V_SESSIONS is available and populated
        session_rows = session.sql("SELECT DISTINCT session_key FROM RAW.V_SESSIONS WHERE session_type = 'Race'").collect()
        
        if not session_rows:
            return "Info: No 'Race' sessions found in V_SESSIONS to process."

        # 2. Truncate the target table (Full Refresh pattern matches your Meetings SP)
        session.sql(f"TRUNCATE TABLE {TARGET_TABLE}").collect()
        
        total_row_count = 0
        sessions_processed = 0

        # 3. Loop through each session and fetch data
        for row in session_rows:
            s_key = row['SESSION_KEY']
            
            # Build the URL with the session key parameter
            url = f"{API_BASE_URL}?session_key={s_key}"
            
            try:
                req = urllib.request.Request(url)
                with urllib.request.urlopen(req) as response:
                    if response.getcode() != 200:
                        print(f"Warning: API returned status {response.getcode()} for session {s_key}")
                        continue
                    
                    positions_data = json.loads(response.read())

                if not positions_data:
                    print(f"Info: No position data found for session {s_key}")
                    continue

                # 4. Insert into the target table
                # We loop through the list and insert each record safely
                for position_record in positions_data:
                    json_string = json.dumps(position_record)
                    
                    session.sql(
                        f"INSERT INTO {TARGET_TABLE} (RAW_PAYLOAD) SELECT PARSE_JSON(?);",
                        params=[json_string]
                    ).collect()
                    total_row_count += 1
                
                sessions_processed += 1

            except urllib.error.URLError as e:
                print(f"Network error for session {s_key}: {e}")
                # We continue to the next session rather than failing the whole batch
                continue

        return f"Success! Processed {sessions_processed} sessions. {total_row_count} rows loaded into {TARGET_TABLE}."
            
    # Top-level Error handling
    except Exception as e:
        return f"An unexpected error occurred: {e}"
$$;
