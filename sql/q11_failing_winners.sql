-- Q11: Which restaurants look strong on paper but still perform poorly or are closed,
-- and what do their customers complain about?

WITH restaurant_scored AS (
  SELECT
    business_id,
    name,
    city,
    state,
    stars,
    is_open,

    CASE
      WHEN LOWER(TRIM(CAST(OutdoorSeating AS STRING))) = 'true' THEN 1
      ELSE 0
    END AS outdoor_seating_score,

    CASE
      WHEN LOWER(TRIM(CAST(Caters AS STRING))) = 'true' THEN 1
      ELSE 0
    END AS caters_score,

    CASE
      WHEN LOWER(TRIM(CAST(RestaurantsReservations AS STRING))) = 'true' THEN 1
      ELSE 0
    END AS reservations_score,

    CASE
      WHEN SAFE_CAST(CAST(RestaurantsPriceRange2 AS STRING) AS INT64) IN (2, 3) THEN 1
      ELSE 0
    END AS price_tier_score

  FROM `bdao-group-yelp.yelp_dataset.yelp_restaurants`
  WHERE stars IS NOT NULL
),

restaurant_with_feature_score AS (
  SELECT
    *,
    outdoor_seating_score
    + caters_score
    + reservations_score
    + price_tier_score AS feature_score
  FROM restaurant_scored
),

failing_strong_restaurants AS (
  SELECT
    *
  FROM restaurant_with_feature_score
  WHERE feature_score >= 3
    AND (
      stars < 3.5
      OR is_open = 0
    )
),

failing_strong_reviews AS (
  SELECT
    rv.review_id,
    rv.business_id,
    rv.text
  FROM `bdao-group-yelp.yelp_dataset.yelp_reviews` rv
  INNER JOIN failing_strong_restaurants fs
    ON rv.business_id = fs.business_id
  WHERE rv.text IS NOT NULL
    AND TRIM(rv.text) != ''
),

overall_restaurant_reviews AS (
  SELECT
    rv.review_id,
    rv.business_id,
    rv.text
  FROM `bdao-group-yelp.yelp_dataset.yelp_reviews` rv
  INNER JOIN `bdao-group-yelp.yelp_dataset.yelp_restaurants` r
    ON rv.business_id = r.business_id
  WHERE rv.text IS NOT NULL
    AND TRIM(rv.text) != ''
),

failing_strong_keyword_counts AS (
  SELECT
    COUNT(*) AS failing_strong_review_count,

    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bmanager\b')) AS manager_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\brude\b')) AS rude_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bminutes\b')) AS minutes_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwrong\b')) AS wrong_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\border\b')) AS order_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bcold\b')) AS cold_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bslow\b')) AS slow_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwait\b')) AS wait_count

  FROM failing_strong_reviews
),

overall_keyword_counts AS (
  SELECT
    COUNT(*) AS overall_review_count,

    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bmanager\b')) AS manager_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\brude\b')) AS rude_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bminutes\b')) AS minutes_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwrong\b')) AS wrong_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\border\b')) AS order_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bcold\b')) AS cold_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bslow\b')) AS slow_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwait\b')) AS wait_count

  FROM overall_restaurant_reviews
),

failing_strong_long AS (
  SELECT
    keyword,
    keyword_count AS failing_strong_keyword_count,
    failing_strong_review_count
  FROM failing_strong_keyword_counts
  UNPIVOT (
    keyword_count FOR keyword IN (
      manager_count AS 'manager',
      rude_count AS 'rude',
      minutes_count AS 'minutes',
      wrong_count AS 'wrong',
      order_count AS 'order',
      cold_count AS 'cold',
      slow_count AS 'slow',
      wait_count AS 'wait'
    )
  )
),

overall_long AS (
  SELECT
    keyword,
    keyword_count AS overall_keyword_count,
    overall_review_count
  FROM overall_keyword_counts
  UNPIVOT (
    keyword_count FOR keyword IN (
      manager_count AS 'manager',
      rude_count AS 'rude',
      minutes_count AS 'minutes',
      wrong_count AS 'wrong',
      order_count AS 'order',
      cold_count AS 'cold',
      slow_count AS 'slow',
      wait_count AS 'wait'
    )
  )
),

failing_strong_cohort_summary AS (
  SELECT
    COUNT(*) AS failing_strong_restaurant_count,
    ROUND(AVG(stars), 3) AS failing_strong_avg_stars,
    COUNTIF(is_open = 0) AS closed_restaurant_count,
    COUNTIF(stars < 3.5) AS low_rated_restaurant_count,
    COUNTIF(feature_score = 3) AS feature_score_3_count,
    COUNTIF(feature_score = 4) AS feature_score_4_count
  FROM failing_strong_restaurants
)

SELECT
  f.keyword,

  c.failing_strong_restaurant_count,
  c.failing_strong_avg_stars,
  c.closed_restaurant_count,
  c.low_rated_restaurant_count,
  c.feature_score_3_count,
  c.feature_score_4_count,

  f.failing_strong_review_count,
  f.failing_strong_keyword_count,
  ROUND(
    10000 * SAFE_DIVIDE(f.failing_strong_keyword_count, f.failing_strong_review_count),
    2
  ) AS failing_strong_mentions_per_10000_reviews,

  o.overall_review_count,
  o.overall_keyword_count,
  ROUND(
    10000 * SAFE_DIVIDE(o.overall_keyword_count, o.overall_review_count),
    2
  ) AS overall_mentions_per_10000_reviews,

  ROUND(
    10000 * SAFE_DIVIDE(f.failing_strong_keyword_count, f.failing_strong_review_count)
    -
    10000 * SAFE_DIVIDE(o.overall_keyword_count, o.overall_review_count),
    2
  ) AS failing_strong_minus_overall_per_10000,

  ROUND(
    SAFE_DIVIDE(
      10000 * SAFE_DIVIDE(f.failing_strong_keyword_count, f.failing_strong_review_count),
      10000 * SAFE_DIVIDE(o.overall_keyword_count, o.overall_review_count)
    ),
    2
  ) AS failing_strong_to_overall_frequency_ratio

FROM failing_strong_long f
INNER JOIN overall_long o
  ON f.keyword = o.keyword
CROSS JOIN failing_strong_cohort_summary c
ORDER BY
  failing_strong_mentions_per_10000_reviews DESC;
