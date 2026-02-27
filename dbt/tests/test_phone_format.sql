SELECT *
FROM {{ ref('stg_erp__addresses') }}
WHERE PHONE IS NOT NULL
  AND NOT REGEXP_LIKE(PHONE, '^\\+?[0-9]{10,15}$')