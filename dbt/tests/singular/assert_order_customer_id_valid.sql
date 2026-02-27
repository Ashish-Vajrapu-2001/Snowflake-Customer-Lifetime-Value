-- Assert: every CUSTOMER_ID in order headers exists as an active record in customers snapshot
SELECT oh.ORDER_ID, oh.CUSTOMER_ID
FROM {{ ref('stg_erp__oe_order_headers_all') }} oh
LEFT JOIN {{ ref('snp_crm__customers') }} snap
    ON oh.CUSTOMER_ID = snap.CUSTOMER_ID
    AND snap.dbt_is_current = TRUE
WHERE oh.CUSTOMER_ID IS NOT NULL
  AND snap.CUSTOMER_ID IS NULL