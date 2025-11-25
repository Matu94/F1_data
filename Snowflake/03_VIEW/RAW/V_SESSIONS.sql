CREATE OR REPLACE VIEW RAW.V_SESSIONS
  COMMENT = 'F1 project: parse the JSON column from RAW.SESSIONS table'
AS
SELECT
    RAW_PAYLOAD:session_key::INTEGER       AS session_key,
    RAW_PAYLOAD:meeting_key::INTEGER       AS meeting_key,
    RAW_PAYLOAD:circuit_key::INTEGER       AS circuit_key,
    RAW_PAYLOAD:country_key::INTEGER       AS country_key,
    RAW_PAYLOAD:circuit_short_name::STRING AS circuit_short_name,
    RAW_PAYLOAD:country_code::STRING       AS country_code,
    RAW_PAYLOAD:country_name::STRING       AS country_name,
    RAW_PAYLOAD:location::STRING           AS location,
    RAW_PAYLOAD:session_name::STRING       AS session_name,
    RAW_PAYLOAD:session_type::STRING       AS session_type,
    TRY_TO_TIMESTAMP_TZ(RAW_PAYLOAD:date_start::STRING) AS date_start,
    TRY_TO_TIMESTAMP_TZ(RAW_PAYLOAD:date_end::STRING)   AS date_end,
    RAW_PAYLOAD:gmt_offset::TIME           AS gmt_offset,
    RAW_PAYLOAD:year::INTEGER              AS year,
    LOADED_AT
FROM RAW.SESSIONS; 
