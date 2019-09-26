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
