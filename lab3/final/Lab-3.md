## 1.

a) Generate a list of all continents, each continent containing a further sub-list of all the countries on that continent that have capitals with more than 3 million inhabitants. This sub-list must contain both the country and the capital name.

```XQuery
let $continents := doc('mondial')//continent/name
let $countries := doc('mondial')//country

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
```

b) Look at your solution, once you have managed to generate a well-formed XML answer. What can we conclude about the usage of elements, values and attributes of well-formed XML?

**What is well-formed XML?**

- There must be a single root tag.
- Declaration is placed first, if required.
- Each starting tag must have an ending tag.
- \&lt; and \&amp; must be used instead of < and &, respectively.
- Elements must nest inside each other properly with no overlapping markup.

**What are the consequences of non-well-formed XML?**

- Server has to guess.
  - Slower parsing.
  - Possibly wrong.
- No, or only partial, data is returned.

---

## 2.

a) Seas border other seas. Find the sea(s) that border the most other seas and display it/them, together with the count of how many other seas it/they border.

```XQuery
let $seas := doc('mondial')//sea

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
```

b) Compare and contrast the use of built-in aggregating functions in XQuery and SQL, in particular how they can be employed to filter out sought maxima and minima.

The functions are very similar. One must use a subquery or CTE in SQL where you group by certain attributes, while the return value of aggregating function can be set directly to variables in XQuery. Clunky to use subquery in WHERE statement in SQL, slightly better with XPath. 

c) Looking at your solution, do you find it clunky in any way? Compare the way the creators of Mondial store information with your own solution from problem 1, particular in terms of how list are stored. What does this imply for the term well-formed?

The database is still well-formed, however if may have been better to split the bordering attribute into a sublist instead. The use of tokenize makes it clunky. 

---

## 3.

a) Consider problem nr. 3 from Lab 1. Do the exact same thing, except this time, use the number of lakes in the countries, not mountains. That is to say: create a list of elements with attributes where the first attribute shows the number of countries that contain a particular number of lakes, for the countries that contain an above-average number of lakes, and the second shows that number of lakes. Then create an answer that shows only the element(s) with the maximum number of countries from that intermediate result.

```XQuery
let $countries := doc('mondial')//country

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
```

b) Look at your XQuery and SQL solutions and compare the approaches. What can we conclude about the SQL group by operator? What does it actually do logically?

The SQL GROUP BY operator removes all duplicates. In case an aggregating function is used with it, then the values of the parameter column is aggregated in such way the function dictates.

---

## 4.

a) For all the cities with more than 900.000 population, find the pair of cities that are furthest away from each other. You may use a Mercator projection to calculate distance if you want, but your solution _must_ handle the fact that the Earth coordinate system wraps at the datum line, which means cities just on each side of it are not, in fact, a world apart. Hint: Filter out the cities that apply first, or you will be waiting a long, long time for the solution.

```XQuery
let $cities := doc('mondial')//city

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
```

b) Look at your solution critically and try to figure out ways to speed it up. Keep a log of any changes you do so you can show your optimizations.

for $city_2 in$valid_cities[position() > $i], half the amount of checks

---

## 5.

a) Consider the northern hemisphere, that is to say everything north of the equator. Now divide it in two parts along some given latitude. Calculate the total population of cities in both those parts and the ratio between the northern and the southern part. For which integer latitude are the sums of the populations of the two parts closest to each other? Hint: functions.

```XQuery
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
```


b) Could you solve this problem in SQL in a similar way that you solved it here? What features that you employed in this solution are not available in SQL?

```SQL
WITH valid_cities AS (
  SELECT * 
  FROM cities c
  WHERE c.latitude > 0
  AND c.population_year = (
    SELECT MAX(sub_c.population_year) 
    FROM cities sub_c
    WHERE sub_c.name = c.name
  )
)
```

This is not possible in SQL: `for $lat in 1 to 90`, you must use a relatively clunky recursive CTE. Otherwise, `let` statements can be replaced by CTEs or functions (clunky), functions by SQL functions, and where/XPath  conditionals with WHERE statements and, if necessary, subquerys/CTEs. Getting latest population data is also slightly clunkier in SQL, as a subquery is required.

---

## 6.

a) Consider land border crossings. Starting in Sweden, you can reach Norway and Finland with one border crossing. Russia with two. A whole host of countries with 3, and so on. This assumes, of course, that you are never allowed to double back over a border you’ve crossed already. Generate a list of all the countries that are reachable by land border crossing from Sweden under the above conditions, by showing the countries that you can reach at each new border crossing, the sum of countries reachable up to and including the current crossing number and the crossing number for each such group of countries. Hint: Recursion.

The output should be on this form:

```XML
<from_swe_cross>
  <cross num="1" sum="2">
    <country>Finland</country>
    <country>Norway</country>
  </cross>
  <cross num="2" sum="3">
    <country>Russia</country>
  </cross>
      .
      .
      .
</from_swe_cross>
```

```XQuery
declare function local:get-border-count($init) {
  let $countries := doc('mondial')//country
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
```

b) Explain the differences between recursion in XQuery and SQL. Which one matches the recursive definition in CS textbooks? Is the XQuery recursion in your solution tail recursive? Is the SQL recursion tail recursive? In your XQuery solution, do you do a width-first or a depth-first search?

SQL: Select values for a CTE, then select from/join with itself to expand based on the earlier step.

XQuery: Just like many other functional languages, the head and tail of a list can be extracted easily. In the solution, the length of the tail is the base whether the recursion should continue or not.

The recursive function is tail recursive, as each loop simply lops off the head of the `$stack` variable and the returning function call can be replaced by a goto call to the start of the function. The recursion is the last thing that happens.

SQL is not tail call recursive, despite keyword RECURSIVE. It is iterative. 

width-first. save crossing/num at each level, continue down a level save num until null, 

---

## 7.

Now that you have solved a number of similar problems in SQL and XQuery, working against relational tables and XML documents, respectively, present us with the what you think are the pros and cons of each storage approach, as well as each programming language.

XQuery is more similar to traditional, procedural languages than the mainly declarative SQL language. XQuery is more flexible than SQL, // select all, descendants, ancestor.

XML very noisy syntax, SQL tables easier to read

SQL key constraints, triggers
