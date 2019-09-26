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
