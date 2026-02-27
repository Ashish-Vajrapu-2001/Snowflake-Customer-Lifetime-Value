# CLV Analytics — Bronze Layer Deployment Guide

## Prerequisites
- Snowflake account: {{PLACEHOLDER_SNOWFLAKE_ACCOUNT}}
- Fivetran account with API access enabled
- Azure SQL: DBA access to run Change Tracking enablement on source DBs
- Python 3.8+ with requests and pyyaml libraries

## Deployment Steps

### Step 1 — Snowflake Infrastructure
  snowsql -a {{PLACEHOLDER_SNOWFLAKE_ACCOUNT}} -f sql/01_setup_infrastructure.sql
  Verify:
    SHOW DATABASES;   -- BRONZE, SILVER, GOLD
    SHOW WAREHOUSES;  -- LOADING_WH, TRANSFORM_WH
    SHOW ROLES;       -- LOADER_ROLE, TRANSFORMER_ROLE, ANALYST_ROLE

### Step 2 — Enable Change Tracking on Azure SQL Sources
  Run on each NATIVE_UPDATE source (requires DBA access on source):
  
  **SRC-001 (ERP):**
  sqlcmd -S {{PLACEHOLDER_SRC_001_HOST}} -d ERP_DB -i sql/02_enable_change_tracking.sql
  
  **SRC-002 (CRM):**
  sqlcmd -S {{PLACEHOLDER_SRC_002_HOST}} -d CRM_DB -i sql/02_enable_change_tracking.sql
  
  Verify:
    SELECT name FROM sys.change_tracking_tables
  
  Note: Skip for TELEPORT sources (SRC-003 Marketing) — Change Tracking not required.

### Step 3 — Fivetran Setup (Group + Destination + Connectors)
  Fill in all {{PLACEHOLDER_*}} values in fivetran/setup_fivetran.py and the YAML files, then:
  python fivetran/setup_fivetran.py
  Verify in Fivetran dashboard → Connectors — all connectors show "Connected" or "Syncing"

### Step 4 — Monitor Initial Sync
  Watch Fivetran dashboard → Connectors → CLV_Analytics_* → Sync status
  Bronze schemas and tables are created automatically by Fivetran as sync runs

### Step 5 — Verify Bronze Tables Populated
  SELECT COUNT(*), MAX(_FIVETRAN_SYNCED)
  FROM BRONZE.BRONZE_ERP.OE_ORDER_HEADERS_ALL;
  
  SELECT COUNT(*), MAX(_FIVETRAN_SYNCED)
  FROM BRONZE.BRONZE_CRM.CUSTOMERS;
  
  All tables should show COUNT > 0 and a recent _FIVETRAN_SYNCED timestamp

### Step 6 — Apply Governance
  Bronze schemas must exist (Step 5 must complete first):
  snowsql -a {{PLACEHOLDER_SNOWFLAKE_ACCOUNT}} -f sql/03_governance.sql
  Verify:
    SHOW TAGS IN DATABASE BRONZE;            -- PII_TYPE tag present
    SHOW MASKING POLICIES IN DATABASE GOLD;  -- MASK_PII_STRING, MASK_PII_DATE

## Validation Checklist
  [ ] All Bronze schemas exist: SHOW SCHEMAS IN DATABASE BRONZE
  [ ] All Bronze tables contain rows (COUNT > 0)
  [ ] MAX(_FIVETRAN_SYNCED) is recent for all tables
  [ ] TRANSFORMER_ROLE can SELECT from all Bronze tables
  [ ] FUTURE GRANTS confirmed: Fivetran adds new table → TRANSFORMER_ROLE auto-selects it
  [ ] PII_TYPE tag exists in BRONZE.TAGS
  [ ] Masking policies exist in GOLD.POLICIES
  [ ] PII tags applied to all PII columns
  [ ] Resource monitors assigned to both warehouses

## Troubleshooting

  Sync fails — "Change Tracking not enabled":
    Run sql/02_enable_change_tracking.sql on the Azure SQL source, then
    trigger manual resync: Fivetran dashboard → Connector → Sync Now

  TRANSFORMER_ROLE cannot SELECT from new Bronze table:
    GRANT USAGE ON ALL SCHEMAS IN DATABASE BRONZE TO ROLE TRANSFORMER_ROLE;
    GRANT SELECT ON ALL TABLES  IN DATABASE BRONZE TO ROLE TRANSFORMER_ROLE;
    (FUTURE GRANTS cover new tables going forward — ON ALL fixes existing gaps)

  API 409 on connector creation:
    Connector already exists — safe to ignore, script continues

  Fivetran adds unexpected columns:
    Expected — Fivetran handles schema drift automatically, no action needed