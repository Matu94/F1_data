CREATE OR REPLACE VIEW RAW.V_MEETINGS 
COMMENT = 'F1 project: parse the JSON column from RAW.MEETINGS table'
AS
SELECT
    RAW_PAYLOAD:circuit_key::INTEGER              AS CIRCUIT_KEY,
    RAW_PAYLOAD:country_key::INTEGER              AS COUNTRY_KEY,
    RAW_PAYLOAD:meeting_key::INTEGER              AS MEETING_KEY,
    RAW_PAYLOAD:circuit_short_name::VARCHAR       AS CIRCUIT_SHORT_NAME,
    RAW_PAYLOAD:country_code::VARCHAR             AS COUNTRY_CODE,
    RAW_PAYLOAD:country_name::VARCHAR             AS COUNTRY_NAME,
    RAW_PAYLOAD:location::VARCHAR                 AS LOCATION,
    RAW_PAYLOAD:meeting_code::VARCHAR             AS MEETING_CODE,
    RAW_PAYLOAD:meeting_name::VARCHAR             AS MEETING_NAME,
    RAW_PAYLOAD:meeting_official_name::VARCHAR    AS MEETING_OFFICIAL_NAME,
    RAW_PAYLOAD:date_start::TIMESTAMP_TZ          AS DATE_START, 
    RAW_PAYLOAD:gmt_offset::VARCHAR               AS GMT_OFFSET, 
    RAW_PAYLOAD:year::INTEGER                     AS YEAR,
    LOADED_AT
FROM RAW.MEETINGS;
