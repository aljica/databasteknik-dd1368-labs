WITH 
RECURSIVE branches AS (
  SELECT r.name root_river, r.name river, r.name::text river_branch, r.length, 1 numrivers
  FROM river r
  WHERE r.river IS NULL 
  UNION
  SELECT b.root_river, r.name river, (b.river_branch || '-' || r.name) river_branch, b.length + r.length,
  b.numrivers + 1
  FROM river r
  JOIN branches b
  ON b.river = r.river
),
top_numrivers AS (
  SELECT b.root_river, MAX(b.length) totlength
  FROM branches b
  WHERE b.root_river IN ('Nile', 'Amazonas', 'Yangtze', 'Rhein', 'Donau', 'Mississippi')
  GROUP BY b.root_river
)

SELECT rank() OVER (ORDER BY b.numrivers ASC) rank, b.river_branch path, b.numrivers, tn.totlength
FROM top_numrivers tn
JOIN branches b
ON tn.totlength = b.length AND tn.root_river = b.root_river;
