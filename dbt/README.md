# CLV Analytics Data Platform - Silver Layer

This dbt project transforms raw Bronze data (ingested via Fivetran) into the Silver layer.
It handles cleaning, conforming, deduplication, and SCD Type 2 history tracking.

## Architecture
*   **Source:** Snowflake `BRONZE` database (Fivetran managed)
*   **Transformation:** dbt Core
*   **Target:** Snowflake `SILVER` database
*   **Orchestration:** Fivetran Webhook -> dbt Runner

## Models
*   **Incremental Models (SCD1):** 11 tables (Orders, Lines, Addresses, etc.)
*   **Snapshots (SCD2):** 2 tables (Customers, Products)

## Quick Start