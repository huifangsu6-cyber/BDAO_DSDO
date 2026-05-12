-- Q10: Do customer tips flag the same operational problems as full reviews?

WITH restaurant_tips AS (
  SELECT
    t.text
  FROM `bdao-group-yelp.yelp_dataset.yelp_tips` t
  INNER JOIN `bdao-group-yelp.yelp_dataset.yelp_restaurants` r
    ON t.business_id = r.business_id
  WHERE t.text IS NOT NULL
    AND TRIM(t.text) != ''
),

restaurant_reviews AS (
  SELECT
    rv.text
  FROM `bdao-group-yelp.yelp_dataset.yelp_reviews` rv
  INNER JOIN `bdao-group-yelp.yelp_dataset.yelp_restaurants` r
    ON rv.business_id = r.business_id
  WHERE rv.text IS NOT NULL
    AND TRIM(rv.text) != ''
),

tip_keyword_counts AS (
  SELECT
    COUNT(*) AS total_tip_records,

    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bmanager\b')) AS manager_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\brude\b')) AS rude_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bminutes\b')) AS minutes_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwrong\b')) AS wrong_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\border\b')) AS order_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bcold\b')) AS cold_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bslow\b')) AS slow_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwait\b')) AS wait_count

  FROM restaurant_tips
),

review_keyword_counts AS (
  SELECT
    COUNT(*) AS total_review_records,

    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bmanager\b')) AS manager_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\brude\b')) AS rude_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bminutes\b')) AS minutes_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwrong\b')) AS wrong_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\border\b')) AS order_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bcold\b')) AS cold_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bslow\b')) AS slow_count,
    COUNTIF(REGEXP_CONTAINS(LOWER(text), r'\bwait\b')) AS wait_count

  FROM restaurant_reviews
),

tip_long AS (
  SELECT
    keyword,
    keyword_count AS tip_keyword_count,
    total_tip_records
  FROM tip_keyword_counts
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

review_long AS (
  SELECT
    keyword,
    keyword_count AS review_keyword_count,
    total_review_records
  FROM review_keyword_counts
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
)

SELECT
  t.keyword,

  t.total_tip_records,
  t.tip_keyword_count,
  ROUND(10000 * t.tip_keyword_count / t.total_tip_records, 2) AS tip_mentions_per_10000_records,

  r.total_review_records,
  r.review_keyword_count,
  ROUND(10000 * r.review_keyword_count / r.total_review_records, 2) AS review_mentions_per_10000_records,

  ROUND(
    (10000 * t.tip_keyword_count / t.total_tip_records)
    -
    (10000 * r.review_keyword_count / r.total_review_records),
    2
  ) AS tip_minus_review_mentions_per_10000,

  ROUND(
    SAFE_DIVIDE(
      10000 * t.tip_keyword_count / t.total_tip_records,
      10000 * r.review_keyword_count / r.total_review_records
    ),
    2
  ) AS tip_to_review_frequency_ratio

FROM tip_long t
INNER JOIN review_long r
  ON t.keyword = r.keyword
ORDER BY
  review_mentions_per_10000_records DESC;
