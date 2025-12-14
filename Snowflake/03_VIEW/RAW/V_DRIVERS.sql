CREATE OR REPLACE VIEW RAW.V_DRIVERS AS
SELECT
    RAW_PAYLOAD:broadcast_name::VARCHAR AS broadcast_name,
    RAW_PAYLOAD:country_code::VARCHAR AS country_code,
    RAW_PAYLOAD:driver_number::INT AS driver_number,
    RAW_PAYLOAD:first_name::VARCHAR AS first_name,
    RAW_PAYLOAD:full_name::VARCHAR AS full_name,
    RAW_PAYLOAD:headshot_url::VARCHAR AS headshot_url,
    RAW_PAYLOAD:last_name::VARCHAR AS last_name,
    RAW_PAYLOAD:meeting_key::INT AS meeting_key,
    RAW_PAYLOAD:name_acronym::VARCHAR AS name_acronym,
    RAW_PAYLOAD:session_key::INT AS session_key,
    RAW_PAYLOAD:team_colour::VARCHAR AS team_colour,
    RAW_PAYLOAD:team_name::VARCHAR AS team_name,
    LOADED_AT
FROM RAW.DRIVERS;
