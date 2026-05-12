-- Q5: Is HasTV associated with lower ratings within restaurant categories,
-- or is the overall HasTV finding confounded by restaurant type?

WITH restaurant_categories AS (
  SELECT
    business_id,
    name,
    city,
    state,
    stars,
    review_count,
    is_open,

    CASE
      WHEN LOWER(TRIM(CAST(HasTV AS STRING))) = 'true' THEN 'Has TV'
      WHEN LOWER(TRIM(CAST(HasTV AS STRING))) = 'false' THEN 'No TV'
      ELSE NULL
    END AS tv_group,

    TRIM(category) AS category

  FROM `bdao-group-yelp.yelp_dataset.yelp_restaurants`,
  UNNEST(SPLIT(categories, ',')) AS category

  WHERE stars IS NOT NULL
    AND HasTV IS NOT NULL
    AND categories IS NOT NULL
),

cleaned AS (
  SELECT
    *
  FROM restaurant_categories
  WHERE tv_group IS NOT NULL
    AND category IS NOT NULL
    AND category != ''
    AND LOWER(category) != 'restaurants'
),

category_tv_summary AS (
  SELECT
    category,
    tv_group,
    COUNT(DISTINCT business_id) AS restaurant_count,
    AVG(stars) AS avg_stars,
    ROUND(100 * AVG(CASE WHEN stars >= 4.0 THEN 1 ELSE 0 END), 2) AS pct_4_stars_or_above
  FROM cleaned
  GROUP BY
    category,
    tv_group
),

category_pivot AS (
  SELECT
    category,

    MAX(CASE WHEN tv_group = 'Has TV' THEN restaurant_count END) AS has_tv_restaurant_count,
    MAX(CASE WHEN tv_group = 'Has TV' THEN avg_stars END) AS has_tv_avg_stars,
    MAX(CASE WHEN tv_group = 'Has TV' THEN pct_4_stars_or_above END) AS has_tv_pct_4_stars_or_above,

    MAX(CASE WHEN tv_group = 'No TV' THEN restaurant_count END) AS no_tv_restaurant_count,
    MAX(CASE WHEN tv_group = 'No TV' THEN avg_stars END) AS no_tv_avg_stars,
    MAX(CASE WHEN tv_group = 'No TV' THEN pct_4_stars_or_above END) AS no_tv_pct_4_stars_or_above

  FROM category_tv_summary
  GROUP BY category
),

filtered_categories AS (
  SELECT
    *
  FROM category_pivot
  WHERE has_tv_restaurant_count >= 50
    AND no_tv_restaurant_count >= 50
)

SELECT
  category,

  has_tv_restaurant_count,
  ROUND(has_tv_avg_stars, 3) AS has_tv_avg_stars,
  has_tv_pct_4_stars_or_above,

  no_tv_restaurant_count,
  ROUND(no_tv_avg_stars, 3) AS no_tv_avg_stars,
  no_tv_pct_4_stars_or_above,

  ROUND(has_tv_avg_stars - no_tv_avg_stars, 3) AS rating_gap_has_tv_minus_no_tv,

  ROUND(
    has_tv_pct_4_stars_or_above - no_tv_pct_4_stars_or_above,
    2
  ) AS pct_4_star_gap_has_tv_minus_no_tv

FROM filtered_categories
ORDER BY
  rating_gap_has_tv_minus_no_tv ASC;
