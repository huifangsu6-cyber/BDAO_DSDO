-- Q7: When are restaurants busiest by hour and day using yelp_checkin_clean?

WITH checkin_time AS (
  SELECT
    business_id,
    checkin_timestamp,

    EXTRACT(DAYOFWEEK FROM checkin_timestamp) AS day_of_week_number,
    CASE EXTRACT(DAYOFWEEK FROM checkin_timestamp)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week_name,

    EXTRACT(HOUR FROM checkin_timestamp) AS checkin_hour,

    FORMAT('%02d:00-%02d:59',
      EXTRACT(HOUR FROM checkin_timestamp),
      EXTRACT(HOUR FROM checkin_timestamp)
    ) AS hour_block

  FROM `bdao-group-yelp.yelp_dataset.yelp_checkin_clean`
  WHERE checkin_timestamp IS NOT NULL
),

hour_day_summary AS (
  SELECT
    day_of_week_number,
    day_of_week_name,
    checkin_hour,
    hour_block,
    COUNT(*) AS checkin_count
  FROM checkin_time
  GROUP BY
    day_of_week_number,
    day_of_week_name,
    checkin_hour,
    hour_block
),

total_checkins AS (
  SELECT
    SUM(checkin_count) AS total_checkin_count
  FROM hour_day_summary
)

SELECT
  h.day_of_week_number,
  h.day_of_week_name,
  h.checkin_hour,
  h.hour_block,
  h.checkin_count,
  ROUND(100 * h.checkin_count / t.total_checkin_count, 3) AS pct_of_all_checkins,
  RANK() OVER (ORDER BY h.checkin_count DESC) AS busiest_rank
FROM hour_day_summary h
CROSS JOIN total_checkins t
ORDER BY
  h.day_of_week_number,
  h.checkin_hour;
