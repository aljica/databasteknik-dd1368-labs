let $cities :=(for $city in //country//city
where $city/population[last()] > 900000
return $city)

let $distance := 
(for $city1 in $cities
  for $city2 in $cities
  return <distance city1="{data($city1/name)}" city2="{ data($city2/name)}">{(
  (:The Haversine Formula:)
  let $dlat := (number($city1/latitude) - number($city2/   latitude)) * math:pi() div 180
  let $dlon := (number($city1/longitude) - number($city2  /longitude)) * math:pi() div 180
  let $rlat1 := (number($city1/latitude))* math:pi() div    180
  let $rlat2 := (number($city2/latitude))* math:pi() div    180
  let $a := math:sin($dlat div 2) * math:sin($dlat div 2)  + math:sin($dlon div 2)* math:sin($dlon div 2) * math:   cos($rlat1) * math:cos($rlat2)
  let $c     := 2 * math:atan2(math:sqrt($a), math:sqrt(1  -$a))
  return $c * 6371.0)} </distance>)
  
let $max := max($distance)
return $distance[data() = $max]