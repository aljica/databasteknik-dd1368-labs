let $seas := doc('mondial.xml')//sea

let $max_borders := max(
  for $sea in $seas
  return count(tokenize($sea/@bordering, '\s'))
) 

return <max_sea_borders>{
for $sea in $seas
let $borders := count(tokenize($sea/@bordering, '\s'))
where $borders = $max_borders
return <sea name="{$sea/name}" borders="{$borders}"/>}
</max_sea_borders>
