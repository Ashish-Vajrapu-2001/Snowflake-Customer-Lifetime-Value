SELECT *
FROM {{ ref('snp_crm__customers') }}
WHERE EMAIL IS NOT NULL
  AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')