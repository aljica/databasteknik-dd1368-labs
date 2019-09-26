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
