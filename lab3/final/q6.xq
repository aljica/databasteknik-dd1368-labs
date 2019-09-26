declare function local:get-border-count($init) {
  let $countries := doc('mondial.xml')//country
  let $stack := <country name="{$init/name}" 
                         car_code="{$init/@car_code}" 
                         cross="0">
                  {$init/border}         
                </country>
                         
  return (local:get-border-count-rec($stack, (), $countries))
};

declare function local:get-border-count-rec($stack, $res, $countries) {
  if ($stack) then (
    let $country := head($stack)
    let $rest := tail($stack)
    let $cross := $country/@cross
    let $result := ($res, $country)
  
    let $borders := (
      for $border in $country/border[not(@country = $result/@car_code)]
      let $country := $countries[@car_code = $border/@country]
      return <country name="{$country/name}" 
                      car_code="{$border/@country}" 
                      cross="{$cross + 1}">
                  {$country/border[not(@country = $result/@car_code)]}
             </country>
    )[not(@car_code = $rest/@car_code)]

    return local:get-border-count-rec(
      ($rest, $borders), 
      $result,
      $countries
    ) 
  ) else (
    let $max_num := max(for $r in $res return xs:integer($r/@cross))
    let $crossings := tail($res)
    
    for $cross in 1 to $max_num
    
    let $sum := sum(
      for $crossing in $crossings[@cross <= $cross]
      return count($crossing)
    )
    
    return <cross num="{$cross}" sum="{$sum}">{
      for $country in $crossings[@cross = $cross]
      return <country>{string($country/@name)}</country>
    }</cross>
  )
};

let $init := doc('mondial')//country[name = 'Sweden']
return <from_swe_cross>{local:get-border-count($init)}</from_swe_cross>
