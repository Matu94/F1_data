CREATE OR REPLACE PROCEDURE RAW.SP_LOAD_ALL_SESSIONS()
RETURNS VARCHAR
LANGUAGE PYTHON
COMMENT = 'F1 project: Get the data from the API endpoint and load it to the SESSIONS table'
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'requests')
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
    Provides information about sessions. A session refers to a distinct period of track activity during a Grand Prix or testing     weekend (practice, qualifying, sprint, race, ...).
    """

    API_URL = "https://api.openf1.org/v1/SESSIONS?year=2025"
    TARGET_TABLE = "F1.RAW.SESSIONS"
    
    try:
        # 1. API request
        req = urllib.request.Request(API_URL)
        with urllib.request.urlopen(req) as response:
            if response.getcode() != 200:
                return f"Error: API returned status code {response.getcode()}"
            
            meetings_data = json.loads(response.read())
        
        if not meetings_data:
            return "Info: No data received from API side."
        
        # 2. Truncate the target table
        session.sql(f"TRUNCATE TABLE {TARGET_TABLE}").collect()
        
        # 3. Insert into th target table
        row_count = 0
        for meeting in meetings_data:
            json_string = json.dumps(meeting)
            
            #in PARSE_JSON() the ? sign handles that what we get will be executed as DATA and not as command - so e.g. Truncate command will be inserted, and not executed - SAFETY
            #also it handles escape characters
            #So it is needed to make the code secure against SQL injection and robust when handling data that contains special characters.
            session.sql(
                f"INSERT INTO {TARGET_TABLE} (RAW_PAYLOAD) SELECT PARSE_JSON(?);",
                params=[json_string]
            ).collect()
            row_count += 1
            
        return f"Success! {row_count} rows loaded into {TARGET_TABLE}."
            
    # Errorhandl
    except urllib.error.URLError as e:
        return f"Network error occurred: {e}"
    except json.JSONDecodeError:
        return "Error parsing JSON response."
    except Exception as e:
        return f"An unexpected error occurred: {e}"
$$;
