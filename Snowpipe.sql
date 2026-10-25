CREATE OR REPLACE STORAGE INTEGRATION S3_ROLE_INTEGRATION
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::542175737487:role/snowflake_role'
STORAGE_ALLOWED_LOCATIONS = ('s3://northstar-snowpipe-hol/snowflake/');


desc integration S3_role_integration;


create or replace database S3_db;
use schema S3_db.public;

create or replace table S3_table(files string);

create or replace stage S3_stage
  url = ('s3://northstar-snowpipe-hol/snowflake/')
  storage_integration = S3_role_integration;

create or replace pipe S3_db.public.S3_pipe auto_ingest=true as
  copy into S3_db.public.S3_table
  from @S3_db.public.S3_stage;


-- Create Role
use role accountadmin;
ALTER PIPE S3_PIPE SET PIPE_EXECUTION_PAUSED=true;
GRANT OWNERSHIP ON PIPE S3_db.public.S3_pipe TO ROLE accountadmin;
create or replace role S3_role;

-- Grant Object Access and Insert Permission
grant usage on database S3_db to role S3_role;
grant usage on schema S3_db.public to role S3_role;
grant insert, select on S3_db.public.S3_table to role S3_role;
grant usage on stage S3_db.public.S3_stage to role S3_role;

-- Bestow S3_pipe Ownership
grant ownership on pipe S3_db.public.S3_pipe to role S3_role;
