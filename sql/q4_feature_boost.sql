-- Q4: Which one of the three winning features gives the biggest single-feature rating boost?

WITH cleaned AS (
  SELECT
    business_id,
    name,
    city,
    state,
    stars,

    CASE
      WHEN LOWER(TRIM(CAST(OutdoorSeating AS STRING))) = 'true' THEN 1
      WHEN LOWER(TRIM(CAST(OutdoorSeating AS STRING))) = 'false' THEN 0
      ELSE NULL
    END AS has_outdoor_seating,

    CASE
      WHEN LOWER(TRIM(CAST(Caters AS STRING))) = 'true' THEN 1
      WHEN LOWER(TRIM(CAST(Caters AS STRING))) = 'false' THEN 0
      ELSE NULL
    END AS has_caters,

    CASE
      WHEN LOWER(TRIM(CAST(RestaurantsReservations AS STRING))) = 'true' THEN 1
      WHEN LOWER(TRIM(CAST(RestaurantsReservations AS STRING))) = 'false' THEN 0
      ELSE NULL
    END AS has_reservations

  FROM `bdao-group-yelp.yelp_dataset.yelp_restaurants`
  WHERE stars IS NOT NULL
    AND is_open = 1
),

complete_feature_rows AS (
  SELECT *
  FROM cleaned
  WHERE has_outdoor_seating IS NOT NULL
    AND has_caters IS NOT NULL
    AND has_reservations IS NOT NULL
),

baseline AS (
  SELECT
    AVG(stars) AS baseline_avg_stars,
    COUNT(*) AS baseline_restaurant_count
  FROM complete_feature_rows
  WHERE has_outdoor_seating = 0
    AND has_caters = 0
    AND has_reservations = 0
),

single_feature_groups AS (
  SELECT
    'OutdoorSeating only' AS feature_option,
    AVG(stars) AS avg_stars,
    COUNT(*) AS restaurant_count,
    ROUND(100 * AVG(CASE WHEN stars >= 4.0 THEN 1 ELSE 0 END), 2) AS pct_4_stars_or_above
  FROM complete_feature_rows
  WHERE has_outdoor_seating = 1
    AND has_caters = 0
    AND has_reservations = 0

  UNION ALL

  SELECT
    'Caters only' AS feature_option,
    AVG(stars) AS avg_stars,
    COUNT(*) AS restaurant_count,
    ROUND(100 * AVG(CASE WHEN stars >= 4.0 THEN 1 ELSE 0 END), 2) AS pct_4_stars_or_above
  FROM complete_feature_rows
  WHERE has_outdoor_seating = 0
    AND has_caters = 1
    AND has_reservations = 0

 
