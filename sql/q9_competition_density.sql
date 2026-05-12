-- Q9:
-- In which US cities is competition fiercest for restaurants,
-- and do restaurants in those cities/categories rate worse on average?

WITH base_restaurants AS (
  SELECT
    business_id,
    name,
    city,
    state,
    stars,
    is_open,
    review_count,
    categories
  FROM `bdao-group-yelp.yelp_dataset.yelp_restaurants`
  WHERE stars IS NOT NULL
    AND city IS NOT NULL
    AND state IS NOT NULL
    AND categories IS NOT NULL
    AND REGEXP_CONTAINS(LOWER(categories), r'(^|,\s*)restaurants(\s*,|$)')
    AND state IN (
      'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
      'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
      'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
      'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
      'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','DC'
    )
),

category_exploded AS (
  SELECT DISTINCT
    b.business_id,
    b.city,
    b.state,
    b.stars,
    b.is_open,
    b.review_count,
    TRIM(category) AS category
  FROM base_restaurants b,
  UNNEST(SPLIT(b.categories, ',')) AS category
  WHERE TRIM(category) IS NOT NULL
    AND TRIM(category) != ''
    AND LOWER(TRIM(category)) != 'restaurants'
),

city_category_counts AS (
  SELECT
    city,
    state,
    COUNT(DISTINCT category) AS distinct_categories
  FROM category_exploded
  GROUP BY
    city,
    state
),

city_summary AS (
  SELECT
    'City market' AS analysis_level,
    b.city,
    b.state,
    CAST(NULL AS STRING) AS category,

    COUNT(DISTINCT b.business_id) AS restaurant_count,
    AVG(b.stars) AS avg_stars,
    ROUND(100 * AVG(CASE WHEN b.stars >= 4.0 THEN 1 ELSE 0 END), 2) AS pct_4_stars_or_above,
    ROUND(100 * AVG(CASE WHEN b.is_open = 1 THEN 1 ELSE 0 END), 2) AS pct_open,
    AVG(b.review_count) AS avg_review_count,
    c.distinct_categories

  FROM base_restaurants b
  LEFT JOIN city_category_counts c
    ON b.city = c.city
   AND b.state = c.state
  GROUP BY
    b.city,
    b.state,
    c.distinct_categories
  HAVING restaurant_count >= 100
),

ranked_city_summary AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY restaurant_count DESC) AS competition_rank
  FROM city_summary
),

city_category_summary AS (
  SELECT
    'City-category market' AS analysis_level,
    city,
    state,
    category,

    COUNT(DISTINCT business_id) AS restaurant_count,
    AVG(stars) AS avg_stars,
    ROUND(100 * AVG(CASE WHEN stars >= 4.0 THEN 1 ELSE 0 END), 2) AS pct_4_stars_or_above,
    ROUND(100 * AVG(CASE WHEN is_open = 1 THEN 1 ELSE 0 END), 2) AS pct_open,
    AVG(review_count) AS avg_review_count,
    1 AS distinct_categories

  FROM category_exploded
  GROUP BY
    city,
    state,
    category
  HAVING restaurant_count >= 50
),

ranked_city_category_summary AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY restaurant_count DESC) AS competition_rank
  FROM city_category_summary
)

SELECT
  analysis_level,
  competition_rank,
  city,
  state,
  category,
  restaurant_count,
  ROUND(avg_stars, 3) AS avg_stars,
  pct_4_stars_or_above,
  pct_open,
  ROUND(avg_review_count, 1) AS avg_review_count,
  distinct_categories

FROM ranked_city_summary
WHERE competition_rank <= 25

UNION ALL

SELECT
  analysis_level,
  competition_rank,
  city,
  state,
  category,
  restaurant_count,
  ROUND(avg_stars, 3) AS avg_stars,
  pct_4_stars_or_above,
  pct_open,
  ROUND(avg_review_count, 1) AS avg_review_count,
  distinct_categories

FROM ranked_city_category_summary
WHERE competition_rank <= 50

ORDER BY
  analysis_level,
  competition_rank;
