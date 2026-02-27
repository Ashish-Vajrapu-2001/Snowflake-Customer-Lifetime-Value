-- Assert: every ORDER_ID in order lines exists in order headers
SELECT ol.LINE_ID, ol.ORDER_ID
FROM {{ ref('stg_erp__oe_order_lines_all') }} ol
LEFT JOIN {{ ref('stg_erp__oe_order_headers_all') }} oh
    ON ol.ORDER_ID = oh.ORDER_ID
WHERE ol.ORDER_ID IS NOT NULL
  AND oh.ORDER_ID IS NULL