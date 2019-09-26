let $cities := doc('mondial.xml')//city

let $valid_cities := (
 for $city in $cities
   [
     population/@year = max(population/@year) and
     population > 900000
   ]

 return <city name="{$city/name}"
              lon="{$city/longitude}"
              lat="{$city/latitude}"/>
)

let $R := 6371

let $distances := (
  for $city_1 at $i in $valid_cities
  for $city_2 in $valid_cities[position() > $i]

  let $dlat := ($city_1/@lat - $city_2/@lat) * math:pi() div 180
  let $dlon := ($city_1/@lon - $city_2/@lon) * math:pi() div 180

  let $lat1 := $city_1/@lat * math:pi() div 180
  let $lat2 := $city_2/@lat * math:pi() div 180

  let $a := math:pow(math:sin($dlat div 2), 2)
    + math:pow(math:sin($dlon div 2), 2) * math:cos($lat1) * math:cos($lat2)
  let $c := 2 * math:atan2(math:sqrt($a), math:sqrt(1 - $a))

  let $distance := $R * $c

  return <distance city_1="{$city_1/@name}"
                   city_2="{$city_2/@name}"
                   distance="{$distance}"/>
)

let $max_distance := max($distances/@distance)
return <max_city_distance>{
$distances[@distance = $max_distance]}
</max_city_distance>
