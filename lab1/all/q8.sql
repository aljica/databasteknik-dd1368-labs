WITH RECURSIVE landborders (n, country) AS (
  SELECT (1) AS n,
    CASE WHEN country1 = 'S' THEN country2
    ELSE country1
    END AS country
  FROM borders
  WHERE country1 = 'S'
  OR country2 = 'S'

  UNION

  SELECT n + 1 as n,
    CASE WHEN b.country1 = l.country THEN b.country2
    ELSE b.country1
    END AS country
  FROM borders b
  JOIN landborders l
    ON (b.country1 = l.country OR b.country2 = l.country)
    AND (b.country1 <> 'S' AND b.country2 <> 'S')
  WHERE n<5
)

SELECT country, MIN(n) as crossings
FROM landborders
GROUP BY country
ORDER BY crossings;
