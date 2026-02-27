-- ============================================================
-- SECTION 1: PII classification tag
-- Created in bronze_db — shared tag used across all layers for lineage
-- ============================================================
CREATE TAG IF NOT EXISTS BRONZE.TAGS.PII_TYPE
    ALLOWED_VALUES
        'EMAIL', 'PHONE', 'FIRST_NAME', 'LAST_NAME', 'FULL_NAME',
        'DOB', 'ADDRESS', 'POSTCODE', 'NATIONAL_ID', 'FINANCIAL', 'OTHER';

-- ============================================================
-- SECTION 2: Masking policies
-- Created in gold_db — fire ONLY when consumers query Gold tables
-- Bronze and Silver: tags set for lineage; masking policy does NOT fire here
-- Applying masking at Bronze causes transformer to read '***MASKED***' into
-- Silver permanently — this must never happen (RULE G1)
-- ============================================================
CREATE OR REPLACE MASKING POLICY GOLD.POLICIES.MASK_PII_STRING
    AS (val STRING) RETURNS STRING ->
    CASE
        WHEN IS_ROLE_IN_SESSION('COMPLIANCE_ROLE') THEN val
        WHEN IS_ROLE_IN_SESSION('ADMIN_ROLE')      THEN val
        ELSE '***MASKED***'
    END;

CREATE OR REPLACE MASKING POLICY GOLD.POLICIES.MASK_PII_DATE
    AS (val DATE) RETURNS DATE ->
    CASE
        WHEN IS_ROLE_IN_SESSION('COMPLIANCE_ROLE') THEN val
        WHEN IS_ROLE_IN_SESSION('ADMIN_ROLE')      THEN val
        ELSE DATE_FROM_PARTS(YEAR(val), 1, 1)
    END;

-- Link masking policies to PII tag (tag-based masking)
-- Policies fire automatically on Gold columns tagged with PII_TYPE
ALTER TAG BRONZE.TAGS.PII_TYPE
    SET MASKING POLICY GOLD.POLICIES.MASK_PII_STRING;

-- ============================================================
-- SECTION 3: Apply PII tags to Bronze columns
-- TAG ONLY — masking policy does NOT fire on Bronze (RULE G1)
-- transformer_role reads real data from Bronze into Silver dbt models
-- ============================================================

-- BRONZE_CRM.CUSTOMERS
ALTER TABLE BRONZE.BRONZE_CRM.CUSTOMERS
    MODIFY COLUMN EMAIL
    SET TAG BRONZE.TAGS.PII_TYPE = 'EMAIL';

ALTER TABLE BRONZE.BRONZE_CRM.CUSTOMERS
    MODIFY COLUMN PHONE
    SET TAG BRONZE.TAGS.PII_TYPE = 'PHONE';

ALTER TABLE BRONZE.BRONZE_CRM.CUSTOMERS
    MODIFY COLUMN FIRST_NAME
    SET TAG BRONZE.TAGS.PII_TYPE = 'FIRST_NAME';

ALTER TABLE BRONZE.BRONZE_CRM.CUSTOMERS
    MODIFY COLUMN LAST_NAME
    SET TAG BRONZE.TAGS.PII_TYPE = 'LAST_NAME';

ALTER TABLE BRONZE.BRONZE_CRM.CUSTOMERS
    MODIFY COLUMN DATE_OF_BIRTH
    SET TAG BRONZE.TAGS.PII_TYPE = 'DOB';

-- BRONZE_ERP.ADDRESSES
ALTER TABLE BRONZE.BRONZE_ERP.ADDRESSES
    MODIFY COLUMN PHONE
    SET TAG BRONZE.TAGS.PII_TYPE = 'PHONE';