-- Q8 SQL 1:
-- Identify the top global peak day-hour windows from yelp_checkin_clean.

WITH checkin_time AS (
  SELECT
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

    EXTRACT(HOUR FROM checkin_timestamp) AS checkin_hour

  FROM `bdao-group-yelp.yelp_dataset.yelp_checkin_clean`
  WHERE checkin_timestamp IS NOT NULL
),

day_hour_summary AS (
  SELECT
    day_of_week_number,
    day_of_week_name,
    checkin_hour,
    COUNT(*) AS checkin_count
  FROM checkin_time
  GROUP BY
    day_of_week_number,
    day_of_week_name,
    checkin_hour
),

total_checkins AS (
  SELECT
    SUM(checkin_count) AS total_checkin_count
  FROM day_hour_summary
),

ranked_peak_windows AS (
  SELECT
    d.day_of_week_number,
    d.day_of_week_name,
    d.checkin_hour,
    FORMAT('%02d:00-%02d:59', d.checkin_hour, d.checkin_hour) AS hour_block,
    d.checkin_count,
    ROUND(100 * d.checkin_count / t.total_checkin_count, 3) AS pct_of_all_checkins,
    RANK() OVER (ORDER BY d.checkin_count DESC) AS busiest_rank
  FROM day_hour_summary d
  CROSS JOIN total_checkins t
)

SELECT
  day_of_week_number,
  day_of_week_name,
  checkin_hour,
  hour_block,
  checkin_count,
  pct_of_all_checkins,
  busiest_rank
FROM ranked_peak_windows
ORDER BY busiest_rank
LIMIT 20;
