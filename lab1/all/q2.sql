WITH cities_over_3M AS (
  SELECT c.name city, c.country, c.province, c.population
  FROM city c
  WHERE c.population > 3000000
),
landlocked_cities_over_3M AS (
  SELECT DISTINCT c.city, c.country, c.province, c.population
  FROM located l
  JOIN cities_over_3M c
  ON c.city = l.city
  WHERE l.river IS NULL
  AND l.lake IS NULL
  AND l.sea IS NULL
)

SELECT (
  1.0 * (SELECT COUNT(*) FROM landlocked_cities_over_3M) / (SELECT COUNT(*) FROM cities_over_3M)
) ratio;
