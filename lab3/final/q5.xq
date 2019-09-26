declare function local:get-lat-pop($lat, $cities, $mode) as xs:double {
  sum(
    for $city in $cities
    return (
      if ($mode) then $city[@latitude > $lat] else $city[@latitude < $lat]
    )/@population
  )
};

declare function local:find-balance($cities) {
  for $lat in 1 to 90
  let $north := local:get-lat-pop($lat, $cities, 1)
  let $south := local:get-lat-pop($lat, $cities, 0)
  let $ratio := $north div $south

  return <pop_bal bal="{fn:abs(1- $ratio)}" ratio="{$ratio}" lat="{$lat}" />
};


let $valid_cities := (
 let $cities := doc('mondial.xml')//city
 
 for $city in $cities[latitude > 0]
 let $population := $city/population[@year = max($city/population/@year)]
 where $population
 return <city name="{$city/name}"
              population="{$population}"
              latitude="{$city/latitude}"
              longitude="{$city/longitude}"/>
)

let $balances := local:find-balance($valid_cities)
return
<pop_bals>{
  $balances[@bal = min($balances/@bal)]/@lat
}</pop_bals>
