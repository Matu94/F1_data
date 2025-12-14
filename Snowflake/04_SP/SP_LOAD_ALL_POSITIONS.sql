CREATE OR REPLACE PROCEDURE F1.RAW.SP_LOAD_ALL_POSITIONS()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION='3.9'
PACKAGES=('snowflake-snowpark-python')
HANDLER='main'
EXTERNAL_ACCESS_INTEGRATIONS=(F1_API_INTEGRATION)
EXECUTE AS OWNER
AS
$$
import urllib.request
import json
from snowflake.snowpark.functions import current_timestamp   

API_URL = "https://api.openf1.org/v1/position"

def fetch_positions(session_key):
    url = f"{API_URL}?session_key={session_key}"
    try:
        with urllib.request.urlopen(url) as resp:
            if resp.getcode() != 200:
                return None
            return json.loads(resp.read())
    except Exception:
        return None


def main(session):

    FULL = "RAW.POSITIONS"

    rows = session.sql("""
        SELECT DISTINCT session_key
        FROM RAW.V_SESSIONS
        WHERE session_type = 'Race'
    """).collect()

    if not rows:
        return "No race sessions found."

    session.sql(f"TRUNCATE TABLE {FULL}").collect()

    total = 0
    processed = 0

    for r in rows:
        s_key = r["SESSION_KEY"]

        records = fetch_positions(s_key)
        if not records:
            continue

        sp_df = session.create_dataframe(
            [(rec,) for rec in records],
            schema=["RAW_PAYLOAD"]
        )

        #Add audit column explicitly
        sp_df = sp_df.with_column("LOADED_AT", current_timestamp())

        #Native Snowpark write
        sp_df.write.mode("append").save_as_table(FULL)

        total += len(records)
        processed += 1

    return f"Success! {processed} sessions processed, {total} rows loaded."
$$;
