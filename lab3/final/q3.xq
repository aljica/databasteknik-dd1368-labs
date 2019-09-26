let $countries := doc('mondial.xml')//country

let $lakes_per_country := (
  for $country in $countries
  let $lakes := count($country//located_at/@lake)
  where $lakes > 0
  return <country name="{$country/name}" lakes="{$lakes}"/>
)

let $lakes_and_countries := (
  let $lakes := (
    for $entry in $lakes_per_country[@lakes > avg($lakes_per_country/@lakes)]
    let $lakes := $entry/@lakes
    return <lakes count="{$lakes}"/>
  )

  for $lake in distinct-values($lakes/@count)
  let $count := count($lakes[@count = $lake])
  return <lake_amount countries="{$count}" lakes="{$lake}"/>
)

let $max := max($lakes_and_countries/@countries)

return <max_countries_per_lake_count>{
$lakes_and_countries[@countries = $max]}
</max_countries_per_lake_count>
