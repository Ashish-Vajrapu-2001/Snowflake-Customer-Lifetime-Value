{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='LINE_ID',
    merge_exclude_columns=['_silver_load_timestamp'],
    on_schema_change='append_new_columns',
    incremental_predicates=[
        "DBT_INTERNAL_DEST._bronze_sync_timestamp >= DATEADD('day', -{{ var('silver_lookback_days', 3) }}, CURRENT_TIMESTAMP())"
    ]
) }}

WITH source AS (
    SELECT
        LINE_ID,
        ORDER_ID,
        LINE_NUMBER,
        PRODUCT_ID,
        SKU,
        PRODUCT_NAME,
        QUANTITY,
        UNIT_PRICE,
        DISCOUNT_PERCENT,
        DISCOUNT_AMOUNT,
        TAX_AMOUNT,
        LINE_AMOUNT,
        LINE_STATUS,
        WAREHOUSE_ID,
        PROMISED_DATE,
        SHIPPED_DATE,
        DELIVERED_DATE,
        RETURN_REASON,
        CREATED_DATE,
        LAST_UPDATE_DATE,
        LAST_MODIFIED_DATE,
        _FIVETRAN_SYNCED,
        _FIVETRAN_DELETED
    FROM {{ source('bronze_erp', 'OE_ORDER_LINES_ALL') }}

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
            PARTITION BY LINE_ID
            ORDER BY _FIVETRAN_SYNCED DESC
        ) AS _rn
    FROM active_records
),

transformed AS (
    SELECT
        LINE_ID,
        ORDER_ID,
        LINE_NUMBER,
        PRODUCT_ID,
        SKU,
        PRODUCT_NAME,
        QUANTITY,
        UNIT_PRICE,
        DISCOUNT_PERCENT,
        DISCOUNT_AMOUNT,
        TAX_AMOUNT,
        LINE_AMOUNT,
        LINE_STATUS,
        WAREHOUSE_ID,
        TRY_TO_TIMESTAMP_NTZ(PROMISED_DATE) AS PROMISED_DATE,
        TRY_TO_TIMESTAMP_NTZ(SHIPPED_DATE) AS SHIPPED_DATE,
        TRY_TO_TIMESTAMP_NTZ(DELIVERED_DATE) AS DELIVERED_DATE,
        RETURN_REASON,
        TRY_TO_TIMESTAMP_NTZ(CREATED_DATE) AS CREATED_DATE,
        TRY_TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE) AS LAST_UPDATE_DATE,
        TRY_TO_TIMESTAMP_NTZ(LAST_MODIFIED_DATE) AS LAST_MODIFIED_DATE,

        _FIVETRAN_SYNCED          AS _bronze_sync_timestamp,
        CURRENT_TIMESTAMP()       AS _silver_load_timestamp,
        '{{ invocation_id }}'     AS _dbt_run_id,
        _FIVETRAN_DELETED         AS _is_deleted
    FROM deduped
    WHERE _rn = 1
)

SELECT * FROM transformed