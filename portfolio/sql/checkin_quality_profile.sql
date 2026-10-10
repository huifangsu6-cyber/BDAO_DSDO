-- Portfolio example: quality checks for the transformed check-in table.
-- BigQuery Standard SQL. Requires access to the original coursework dataset.
-- Read-only: no tables are modified.
--
-- Checks are reported as counts; this script does not assert that any
-- particular result is zero without running it in BigQuery.

WITH source AS (
  SELECT business_id, checkin_timestamp
  FROM `bdao-group-yelp.yelp_dataset.yelp_checkin_clean`
),
profile AS (
  SELECT
    COUNT(*) AS total_rows,
    COUNTIF(business_id IS NULL OR TRIM(business_id) = '') AS missing_business_ids,
    COUNTIF(checkin_timestamp IS NULL) AS missing_timestamps,
    COUNT(DISTINCT business_id) AS distinct_business_ids,
    MIN(checkin_timestamp) AS earliest_checkin,
    MAX(checkin_timestamp) AS latest_checkin
  FROM source
),
duplicate_keys AS (
  SELECT COUNT(*) AS duplicate_business_timestamp_groups
  FROM (
    SELECT business_id, checkin_timestamp
    FROM source
    WHERE business_id IS NOT NULL AND checkin_timestamp IS NOT NULL
    GROUP BY business_id, checkin_timestamp
    HAVING COUNT(*) > 1
  )
)
SELECT
  p.*,
  d.duplicate_business_timestamp_groups
FROM profile AS p
CROSS JOIN duplicate_keys AS d;
