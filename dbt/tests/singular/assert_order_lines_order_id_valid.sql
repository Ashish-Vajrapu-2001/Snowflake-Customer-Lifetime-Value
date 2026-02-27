-- Assert: every ORDER_ID in order lines exists in order headers
SELECT child.ORDER_ID
FROM {{ ref('stg_erp__oe_order_lines_all') }} child
LEFT JOIN {{ ref('stg_erp__oe_order_headers_all') }} parent
    ON child.ORDER_ID = parent.ORDER_ID
WHERE child.ORDER_ID IS NOT NULL
  AND parent.ORDER_ID IS NULL