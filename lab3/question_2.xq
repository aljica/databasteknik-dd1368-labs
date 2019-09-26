(for $sea in doc("mondial.xml")//sea

let $count := $sea/count(tokenize(@bordering))

let $max := max($count)

order by $max descending

return <sea count="{$max}">{$sea/name/text()}</sea>)[1]
