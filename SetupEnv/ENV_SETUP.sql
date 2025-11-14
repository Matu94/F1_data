USE ROLE ACCOUNTADMIN;

-- 1. Create a custom role for CI/CD process
CREATE ROLE IF NOT EXISTS F1_F1_CICD_ROLE;

-- 2. Create a warehouse for the CI/CD process
CREATE WAREHOUSE IF NOT EXISTS F1_F1_CICD_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- 3. Create the database
CREATE DATABASE IF NOT EXISTS F1;

-- 4. Grant privileges to the new role
GRANT USAGE ON WAREHOUSE F1_CICD_WH TO ROLE F1_CICD_ROLE;
GRANT USAGE ON DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT CREATE SCHEMA ON DATABASE F1 TO ROLE F1_CICD_ROLE;


-- 5. FUTURE GRANTS: Apply permissions automatically to all NEW objects created in the database --

-- Grant comprehensive permissions on all FUTURE schemas
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE F1 TO ROLE F1_CICD_ROLE;

-- Grant permissions for all types of objects that will be created within FUTURE schemas
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE STAGES IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE FILE FORMATS IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE SEQUENCES IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE STREAMS IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TASKS IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE PIPES IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE PROCEDURES IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT ALL PRIVILEGES ON FUTURE FUNCTIONS IN DATABASE F1 TO ROLE F1_CICD_ROLE;

-- Grants for specific objects like Alerts and Streamlit Apps
GRANT CREATE ALERT ON ALL SCHEMAS IN DATABASE F1 TO ROLE F1_CICD_ROLE;
GRANT CREATE STREAMLIT ON ALL SCHEMAS IN DATABASE F1 TO ROLE F1_CICD_ROLE;


-- 6. Create a user
CREATE USER IF NOT EXISTS F1_F1_CICD_USER
  DEFAULT_ROLE = F1_CICD_ROLE
  DEFAULT_WAREHOUSE = F1_CICD_WH
  MUST_CHANGE_PASSWORD = FALSE;

-- Grant the custom role to the new user
GRANT ROLE F1_CICD_ROLE TO USER F1_CICD_USER;


/* I use Keypair auth so here is have to set it up:
using OpenSSL on local machine. Run this commands in the terminal

This command generates a private key and encrypts it using the AES 256 algorithm, which will prompt you to enter and verify a passphrase. REMEMBER FOR THIS PASSPHRASE
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_cicd_key.p8 -v2 aes-256-cbc

Generates public key:
openssl rsa -in snowflake_cicd_key.p8 -pubout -out snowflake_cicd_key.pub

So end of the day we have 2 files: 
.p8 is the private key
.pub is the publick key
*/

-- Add the publick key to the user:
ALTER USER F1_CICD_USER
    SET RSA_PUBLIC_KEY = 'putyourpublichere_withouttheBEGINandENDPUBLICKEY_and_inoneline';


-- 7. Create the TECH schema and the monitoring table for CICD
CREATE SCHEMA IF NOT EXISTS TECH;

CREATE TABLE IF NOT EXISTS F1.TECH.DEPLOYMENT_HISTORY (
    DEPLOYMENT_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FILENAME VARCHAR,
    COMMIT_SHA VARCHAR,
    GITHUB_ACTOR VARCHAR,
    STATUS VARCHAR,
    TYPE VARCHAR, --Type of the deploy. Can be Init(fulldeploy) or normal
    ERROR_MESSAGE VARCHAR
);
