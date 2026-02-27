# CLV Analytics - Silver Layer (dbt Core)

## Overview
This project transforms raw Bronze data (ingested via Fivetran) into clean, conformed Silver models for the Customer Lifetime Value (CLV) Analytics platform.

## Architecture
*   **Source:** Fivetran-managed Bronze tables (Snowflake)
*   **Transformation:** dbt Core (Incremental + Snapshots)
*   **Target:** Silver tables (Snowflake)
*   **Orchestration:** Fivetran Webhook -> dbt Core

## Project Structure
*   `models/staging/`: Incremental staging models (SCD Type 1)
*   `snapshots/`: SCD Type 2 snapshots (History tracking)
*   `tests/`: Data quality tests (Generic + Singular)
*   `macros/`: Reusable SQL logic

## Key Features
*   **Incremental Loading:** Uses `_FIVETRAN_SYNCED` as watermark.
*   **Soft Deletes:** Filters `_FIVETRAN_DELETED` rows in staging; tracks them in snapshots.
*   **SCD Type 2:** Tracks history for Customers and Addresses.
*   **Data Quality:** Comprehensive testing suite (Unique, Not Null, FK, Custom Logic).

## Quick Start