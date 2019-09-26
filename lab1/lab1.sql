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

<<<<<<< HEAD:lab1/1.sql
with recursive landborders (country1, country2, n) as (

select country1, country2, (select 1) as n
from borders
where country1='S' or country2='S'

UNION

select b.country1, b.country2, n+1
from borders b
join landborders l on (l.country1 = b.country1 and l.country2 <> b.country2) or (l.country2=b.country2 and l.country1<>b.country1)
where n+1<=3
)

select * from landborders;
=======
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
with recursive
riverpaths (r_depth, root, child, tot_length) as (
  select (1) as r_depth, name, name as child, length
  from river
  where name = 'Nile'

  union

  select (r_depth + 1) as r_depth, child as root, name, (r.length + rp.tot_length) as tot_length
  from river r
  join riverpaths rp on(
    r.river = rp.child
  )
),

final (name) as (
  select distinct root from riverpaths where r_depth = (select max(r_depth) from riverpaths)
  union
  select distinct root from riverpaths, final where child=name
)

select * from riverpaths;*/
/* NOW ALSO NEED THE CHILDREN OF SOBAT */



with recursive
riverpaths (root, child, length, address) as (
	select name, name as child, length, name as address
	from river
	where name = 'Nile'
	
	union 
	
	select child as root, name, (r.length + rp.length) as length, (rp.address || '-' || rp.child) as address
	from river r
	join riverpaths rp on(
		r.river = rp.child)
	)

select root, address from riverpaths;
	
/* If we just have the parents of a river in one column (concatenated), and the child in another column
We can then in a new tuple get a longer parent-parent-parent where the last parent in the chain was the child in the other column above.
For this we'd have to make sure that if a == b below, then b should be a NULL value (to avoid having Nile-Nile). Example:

a		b
a-b		c
a-b-c	d*/



/*
with recursive riverpaths (r_depth, path, root, length) as (
  select (1) as r_depth, name, name as root, length
  from river
  where name = 'Nile'

  union

  select (r_depth + 1) as r_depth, name, path as root, (r.length + rp.length) as length
  from river r
  join riverpaths rp on(
    r.river = rp.path
  )
)

select * from riverpaths where r_depth = (select max(r_depth) from riverpaths);
*/
>>>>>>> 833dac75a3a33631d7a72f9aaec02c1d2f4e8e0b:lab1/lab1.sql
