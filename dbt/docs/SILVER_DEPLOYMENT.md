# Silver Layer Deployment Guide

## Prerequisites
*   Python 3.8+
*   `dbt-snowflake` adapter installed
*   Git access to `clv_analytics_dbt` repository
*   Snowflake role `TRANSFORMER_ROLE` (or equivalent)
*   Bronze tables populated by Fivetran

## Environment Variables
Set these in your shell or CI/CD environment:
*   `DBT_SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier
*   `DBT_SNOWFLAKE_USER`: Service account user
*   `DBT_SNOWFLAKE_PASSWORD`: Service account password
*   `DBT_BRONZE_DB`: Database name for Bronze (default: `BRONZE`)
*   `DBT_SILVER_DB`: Database name for Silver (default: `SILVER`)

## Deployment Steps

1.  **Install Dependencies**