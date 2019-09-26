/* Question 1 */

/*
with provincesCTE (country, count)
as (select country, count(*)
from province
group by country
having count(*)>10),

populationCTE (country)
as (select country
from city, country
where country.capital = city.name
and city.population>5000000),

countriesCTE (country)
as (select provincesCTE.country
from provincesCTE
join populationCTE
on provincesCTE.country = populationCTE.country)

select continent, count(*)
from encompasses, countriesCTE
where countriesCTE.country = encompasses.country
group by continent;
*/

/* Question 2 */

/* THIS IS NOT DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONE
with nextToCTE (count) as (
select count(*)
from city
join located on city.name = located.city
where city.population>3000000),

totalpopCTE (count) as (
select count(*)
from city
where population>3000000),

totalcountCTE (located, total) as (
select * from nextToCTE, totalpopCTE)

select located/total::numeric as ratio from totalcountCTE;
*/

/* Question 3 */

/*
with averageCTE (avg) as (
select round(avg(total)) from (
select count(*) as total from geo_mountain group by country) as totalNumCountries),

numMountainsCTE (count) as (
select count(*) as count from geo_mountain group by country order by count asc),

mountainsAboveAvgCTE (count) as (
select * from numMountainsCTE where count >= (select * from averageCTE)),

intermediateCTE (numcountries, nummountains) as (
select count(*) as numcountries, count
from mountainsAboveAvgCTE
group by count),

maxCountriesCTE (max) as (
select MAX(numcountries) from intermediateCTE)

select * from intermediateCTE group by numcountries, nummountains having MAX(numcountries)=(select * from maxCountriesCTE);
*/

/* Question 4 */

/*
with firstColCTE (country1, count1) as (
select country1, count(*) as count1
from borders
group by country1),

secondColCTE (country2, count2) as (
select country2, count(*) as count2
from borders
group by country2),

totalNeighbors (country, count) as (
select country1, count1+count2
from firstColCTE
join secondColCTE on country1=country2),

fewestNeighbors (num) as (
select min(count) from totalNeighbors)

select * from totalNeighbors where count = (select * from fewestNeighbors);
*/

/* Question 5 */

/*
with mountainInfo (country, mountain_name, coordinates, elevation) as (
select distinct country, name, coordinates, elevation
from mountain
join geo_mountain on name=mountain),

includeContinent (continent, country, mountain_name, coordinates, elevation) as (
select continent, mountainInfo.country, mountain_name, coordinates, elevation
from mountainInfo
join encompasses on mountainInfo.country=encompasses.country
where mountainInfo.country = encompasses.country),

distancefromcenter (continent, mountain_name, distance) as (
select continent, mountain_name, ((coordinates).latitude * (coordinates).latitude + (coordinates).longitude * (coordinates).longitude) as distance
from includeContinent),

distancebycontinent (continent, distance) as (
select continent, min(distance)
from distancefromcenter
group by continent),

finalmountains (continent, mountain_name) as (
select distancefromcenter.continent, mountain_name
from distancefromcenter
join distancebycontinent on distancefromcenter.continent=distancebycontinent.continent and
distancefromcenter.distance = distancebycontinent.distance)

select finalmountains.continent, country, finalmountains.mountain_name, elevation
from finalmountains
join includeContinent on finalmountains.continent=includeContinent.continent and
finalmountains.mountain_name = includeContinent.mountain_name;
*/

/* Question 6 */

/* idk */

/* Question 7 */

/*
with gdpAndPop (code, name, gdp, population) as (
select country.code, country.name, gdp, population
from economy
join country on country=code),

gdpPerCap (code, name, gdpcap) as (
select code, name, gdp/population * 1000000 as gdpcap
from gdpandpop),

gdpwithcontinent (continent, code, name, gdpcap) as (
select continent, code, name, gdpcap
from gdppercap
join encompasses on encompasses.country = gdppercap.code),

totalnumcountries (continent, count) as (
select continent, count(*) as count
from gdpwithcontinent
group by continent),

toptwentypercent (continent, count) as (
select continent, round(count*0.2)
from totalnumcountries),

sortedlist (continent, code, name, gdpcap, count) as (
select gdpwithcontinent.continent, code, name, gdpcap, count
from gdpwithcontinent
join toptwentypercent on gdpwithcontinent.continent=toptwentypercent.continent
where gdpcap is not null
order by continent, gdpcap desc),

countriestoptwentybygdp (continent, code, name, gdpcap, count, rownum) as (
select continent, code, name, gdpcap, count, row_number() over (partition by continent order by gdpcap desc) as rownum
from sortedlist),

finaltoptwentybygdp (continent, name, gdpcap) as (
select continent, name, gdpcap from countriestoptwentybygdp where rownum <= count),

minGDPoftoptwenty (continent, min) as (
select continent, min(gdpcap) as min
from finaltoptwentybygdp
group by continent)

select sortedlist.continent, name
from mingdpoftoptwenty
join sortedlist on min = gdpcap;
*/

/* Question 8 */

/*
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
*/

/* Question 9 */
/*
with recursive riverpaths (path, root) as (
  select name, name as root
  from river
  where name = 'Nile'

  union

  select concat_ws('-', name, root), name as root
  from river r
  join riverpaths rp on(
    r.river = rp.path
  )
)

select * from riverpaths;
*/



/*
with recursive riverpaths (path, length, root) as (
  select name, length, name as root
  from river
  where name = 'Nile' or name = 'Mississippi'

  union

  select name, r.length, path as root
  from river r
  join riverpaths rp on(
    r.river = rp.path
  )
)

select * from riverpaths;
*/

with recursive riverpaths (path, root, length) as (
  select name, name as root, length
  from river
  where name = 'Nile'

  union

  select name, path as root, (r.length + rp.length) as length
  from river r
  join riverpaths rp on(
    r.river = rp.path
  )
)

select * from riverpaths;

/*
select root, root as final from riverpaths group by root;
*/
/*
select count(*), root from riverpaths group by root;
*/
