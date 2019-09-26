WITH slices AS (
  SELECT
    CASE
      WHEN c.latitude > 0 AND c.longitude > 0 THEN 'slice_1'
      WHEN c.latitude > 0 AND c.longitude < 0 THEN 'slice_2'
      WHEN c.latitude < 0 AND c.longitude > 0 THEN 'slice_3'
      ELSE 'slice_4'
    END slice, SUM(c.population) pop
  FROM city c
  GROUP BY slice
)

SELECT (
  SELECT s.slice
  FROM slices s
  WHERE s.pop = (
  SELECT MIN(s.pop)
  FROM slices s
  )
) dividend, (
  SELECT s.slice
  FROM slices s
  WHERE s.pop = (
    SELECT MAX(s.pop)
    FROM slices s
  )
) divisor, 1.0 * MIN(s.pop) / MAX(s.pop) ratio
FROM slices s;
