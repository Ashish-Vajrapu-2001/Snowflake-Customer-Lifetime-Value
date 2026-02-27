{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='INCIDENT_ID',
    merge_exclude_columns=['_silver_load_timestamp'],
    on_schema_change='append_new_columns'
) }}

WITH source AS (
    SELECT
        INCIDENT_ID,
        INCIDENT_NUMBER,
        CUSTOMER_ID,
        ORDER_ID,
        SUBJECT,
        DESCRIPTION,
        CATEGORY,
        SUB_CATEGORY,
        PRIORITY,
        STATUS,
        CHANNEL,
        ASSIGNED_TO,
        FIRST_RESPONSE_DATE,
        RESOLVED_DATE,
        CLOSED_DATE,
        LAST_MODIFIED_DATE,
        _FIVETRAN_SYNCED,
        _FIVETRAN_DELETED
    FROM {{ source('bronze_crm', 'INCIDENTS') }}

    {% if is_incremental() %}
        WHERE _FIVETRAN_SYNCED > (
            SELECT COALESCE(
                MAX(_bronze_sync_timestamp),
                '{{ var("min_date", "2000-01-01") }}'::TIMESTAMP_TZ
            )
            FROM {{ this }}
        )
        OR _FIVETRAN_SYNCED >= DATEADD(
            'day',
            -{{ var('silver_lookback_days', 3) }},
            CURRENT_TIMESTAMP()
        )
    {% endif %}
),

active_records AS (
    SELECT *
    FROM source
    WHERE _FIVETRAN_DELETED = FALSE OR _FIVETRAN_DELETED IS NULL
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY INCIDENT_ID
            ORDER BY _FIVETRAN_SYNCED DESC
        ) AS _rn
    FROM active_records
),

transformed AS (
    SELECT
        INCIDENT_ID,
        INCIDENT_NUMBER,
        CUSTOMER_ID,
        ORDER_ID,
        SUBJECT,
        DESCRIPTION,
        CATEGORY,
        SUB_CATEGORY,
        PRIORITY,
        STATUS,
        CHANNEL,
        ASSIGNED_TO,
        TRY_TO_TIMESTAMP_NTZ(FIRST_RESPONSE_DATE) AS FIRST_RESPONSE_DATE,
        TRY_TO_TIMESTAMP_NTZ(RESOLVED_DATE) AS RESOLVED_DATE,
        TRY_TO_TIMESTAMP_NTZ(CLOSED_DATE) AS CLOSED_DATE,
        TRY_TO_TIMESTAMP_NTZ(LAST_MODIFIED_DATE) AS LAST_MODIFIED_DATE,

        _FIVETRAN_SYNCED          AS _bronze_sync_timestamp,
        CURRENT_TIMESTAMP()       AS _silver_load_timestamp,
        '{{ invocation_id }}'     AS _dbt_run_id,
        _FIVETRAN_DELETED         AS _is_deleted
    FROM deduped
    WHERE _rn = 1
)

SELECT * FROM transformed