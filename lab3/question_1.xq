for $continent in doc("mondial.xml")//continent

return <Continent name="{$continent/name/text()}">

{(for $countries in doc("mondial.xml")//country[encompassed/@continent = $continent/@id]

for $city in doc("mondial.xml")//city[@id = $countries/@capital]

where $city/population[last()] > 3000000

return <country name="{$countries/name}"><city name="{$city/name}"></city></country>)}
 
</Continent>
