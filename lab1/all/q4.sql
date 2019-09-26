WITH borders_count AS (
SELECT c.name country, COUNT(*) borders
  FROM borders b
  JOIN country c
  ON c.code IN (b.country1, b.country2)
  GROUP BY c.name
)

SELECT *
FROM borders_count bc
WHERE bc.borders = (SELECT MIN(bc.borders) FROM borders_count bc);
