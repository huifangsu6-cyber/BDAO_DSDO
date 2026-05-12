-- Q6: Does the price-tier recommendation hold across major US cities?

WITH cleaned AS (
  SELECT
    business_id,
    name,
    city,
    state,
    stars,
    is_open,
    SAFE_CAST(RestaurantsPriceRange2 AS INT64) AS price_tier
  FROM `bdao-group-yelp.yelp_dataset.yelp_restaurants`
  WHERE stars IS NOT NULL
    AND is_open = 1
    AND RestaurantsPriceRange2 IS NOT NULL
    AND SAFE_CAST(RestaurantsPriceRange2 AS INT64) BETWEEN 1 AND 4
    AND state IN (
      'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
      'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
      'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
      'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
      'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','DC'
    )
),

top_10_cities AS (
  SELECT
    city,
    state,
    COUNT(*) AS total_restaurants_in_city,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS city_rank
  FROM cleaned
  GROUP BY city, state
  ORDER BY total_restaurants_in_city DESC
  LIMIT 10
),

city_price_summary AS (
  SELECT
    c.city,
    c.state,
    t.city_rank,
    t.total_restaurants_in_city,
    c.price_tier,
    CASE
      WHEN c.price_tier = 1 THEN 'Budget (1)'
      WHEN c.price_tier = 2 THEN 'Mid-range (2)'
      WHEN c.price_tier = 3 THEN 'Upscale (3)'
      WHEN c.price_tier = 4 THEN 'Fine dining (4)'
    END AS price_tier_label,
    COUNT(*) AS restaurant_count,
    AVG(c.stars) AS avg_stars,
    ROUND(100 * AVG(CASE WHEN c.stars >= 4.0 THEN 1 ELSE 0 END), 2) AS pct_4_stars_or_above
  FROM cleaned c
  INNER JOIN top_10_cities t
    ON c.city = t.city
   AND c.state = t.state
  GROUP BY
    c.city,
    c.state,
    t.city_rank,
    t.total_restaurants_in_city,
    c.price_tier,
    price_tier_label
),

budget_baseline AS (
  SELECT
    city,
    state,
    avg_stars AS budget_avg_stars
  FROM city_price_summary
  WHERE price_tier = 1
),

mid_range_check AS (
  SELECT
    city,
    state,
    avg_stars AS mid_range_avg_stars
  FROM city_price_summary
  WHERE price_tier = 2
)

SELECT
  s.city_rank,
  s.city,
  s.state,
  s.total_restaurants_in_city,
  s.price_tier,
  s.price_tier_label,
  s.restaurant_count,
  ROUND(s.avg_stars, 3) AS avg_stars,
  ROUND(b.budget_avg_stars, 3) AS budget_avg_stars,
  ROUND(s.avg_stars - b.budget_avg_stars, 3) AS star_difference_vs_budget,
  s.pct_4_stars_or_above,
  CASE
    WHEN m.mid_range_avg_stars > b.budget_avg_stars THEN 'Yes - mid-range higher than budget'
    WHEN m.mid_range_avg_stars = b.budget_avg_stars THEN 'No difference'
    WHEN m.mid_range_avg_stars < b.budget_avg_stars THEN 'No - budget higher than mid-range'
    ELSE 'Cannot compare'
  END AS does_mid_range_beat_budget_in_city
FROM city_price_summary s
LEFT JOIN budget_baseline b
  ON s.city = b.city
 AND s.state = b.state
LEFT JOIN mid_range_check m
  ON s.city = m.city
 AND s.state = m.state
ORDER BY
  s.city_rank,
  s.price_tier;
