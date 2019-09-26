let $continents := doc('mondial.xml')//continent/name
let $countries := doc('mondial.xml')//country

return <continents>{
for $continent in $continents
let $enc-continent := lower-case(substring($continent, 0, 10))

return (
  <continent name="{$continent}">{
    for $country in $countries
    let $cities := $country//city

    for $city in $cities[@id = $country/@capital and population > 3000000]
    where $country/encompassed/@continent = $enc-continent
    return <country name="{$country/name}" capital="{$city/name}"/>
  }</continent>)
 }</continents>
