CREATE OR REPLACE PROCEDURE RAW.SP_LOAD_ALL_POSITIONS()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'pandas')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (F1_API_INTEGRATION)
COMMENT='F1 project: Get the data from the API endpoint and load it to the POSITIONS table'
EXECUTE AS OWNER
AS
$$
import urllib.request
import json
import pandas as pd
from snowflake.snowpark.functions import col, parse_json

API_URL = "https://api.openf1.org/v1/position"

def fetch_positions(session_key):
    """Fetch JSON array from the API."""
    url = f"{API_URL}?session_key={session_key}"
    try:
        with urllib.request.urlopen(url) as resp:
            if resp.getcode() != 200:
                return None
            return json.loads(resp.read())
    except Exception:
        return None


def main(session):

    TARGET_TABLE = "POSITIONS"
    TARGET_SCHEMA = "RAW"
    FULL_TARGET = f"{TARGET_SCHEMA}.{TARGET_TABLE}"

    session_keys = session.sql("""
        SELECT DISTINCT session_key 
        FROM RAW.V_SESSIONS 
        WHERE session_type = 'Race'
    """).collect()

    if not session_keys:
        return "Info: No 'Race' sessions found."

    # Full refresh
    session.sql(f"TRUNCATE TABLE {FULL_TARGET}").collect()

    total_rows = 0
    sessions_processed = 0

    for row in session_keys:
        s_key = row["SESSION_KEY"]

        data = fetch_positions(s_key)
        if not data:
            continue

        # Build Snowpark DF with raw JSON strings
        sp_df = session.create_dataframe(
            [(json.dumps(rec),) for rec in data],
            schema=["raw_str"]
        )

        # Convert raw_str → VARIANT
        sp_df = sp_df.select(parse_json(col("raw_str")).alias("RAW_PAYLOAD"))

        # Convert to pandas so write_pandas can apply default LOADED_AT
        pdf = pd.DataFrame({"RAW_PAYLOAD": sp_df.to_pandas()["RAW_PAYLOAD"]})

        # Batch insert (defaults applied automatically)
        session.write_pandas(
            pdf,
            table_name=TARGET_TABLE,
            schema=TARGET_SCHEMA,
            quote_identifiers=False
        )

        total_rows += len(data)
        sessions_processed += 1

    return f"Success! Processed {sessions_processed} sessions. Loaded {total_rows} rows into RAW.POSITIONS."
$$;
