CREATE TABLE IF NOT EXISTS RAW.DRIVERS (
	RAW_PAYLOAD VARIANT,
	LOADED_AT TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'F1 project: Store all the data from the API endpoint: https://api.openf1.org/v1/drivers';
