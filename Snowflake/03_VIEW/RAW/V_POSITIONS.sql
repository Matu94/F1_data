CREATE OR REPLACE VIEW RAW.V_POSITIONS AS
SELECT
    RAW_PAYLOAD:"date"::TIMESTAMP_TZ      AS date,
    RAW_PAYLOAD:"driver_number"::INT      AS driver_number,
    RAW_PAYLOAD:"meeting_key"::INT        AS meeting_key,
    RAW_PAYLOAD:"position"::INT           AS position,
    RAW_PAYLOAD:"session_key"::INT        AS session_key,
    LOADED_AT
FROM RAW.POSITIONS;
