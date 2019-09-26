WITH countries_and_gdp_capita AS (
  SELECT en.continent, c.name country, e.gdp / c.population gdp_per_capita, percent_rank() OVER (PARTITION BY en.continent ORDER BY e.gdp DESC) rank
  FROM economy e
  JOIN encompasses en
  ON e.country = en.country
  JOIN country c
  ON e.country = c.code
  WHERE e.gdp IS NOT NULL
),
richest_countries_per_continent AS (
  SELECT cgc.continent, cgc.country, cgc.gdp_per_capita
  FROM countries_and_gdp_capita cgc
  WHERE cgc.rank <= 0.2
),
poorest_richest_countries AS (
  SELECT DISTINCT t.continent, rc.country
  FROM (
    SELECT rc.continent, MIN(rc.gdp_per_capita) gdp_per_capita
    FROM richest_countries_per_continent rc
    GROUP BY rc.continent
  ) t
  JOIN richest_countries_per_continent rc
  ON t.gdp_per_capita = rc.gdp_per_capita
)

SELECT *
FROM poorest_richest_countries;
