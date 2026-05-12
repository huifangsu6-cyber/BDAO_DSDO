-- Q8 SQL 2:
-- Export restaurant opening-hour and profile data for Python parsing.

SELECT
  business_id,
  name,
  city,
  state,
  stars,
  is_open,
  review_count,
  categories,
  hours,
  RestaurantsPriceRange2,
  OutdoorSeating,
  Caters,
  RestaurantsReservations

FROM `bdao-group-yelp.yelp_dataset.yelp_restaurants`

WHERE stars IS NOT NULL
  AND hours IS NOT NULL
  AND categories IS NOT NULL
  AND REGEXP_CONTAINS(
    LOWER(categories),
    r'(^|,\s*)restaurants(\s*,|$)'
  );
