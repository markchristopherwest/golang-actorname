#!/bin/sh

# This script only needs to be run by the upstream package maintainer (Mark Christopher West)
# if the upstream actorname wordlists change

set -e

PKG="actorname"

[ -d .bzr/ ] && bzr revert ${PKG}.go || true
for f in adverbs adjectives names; do
	rm -f "$f".txt.list
	printf "	$f = [...]string{" > "$f".txt.list
	for w in $(cat /usr/share/actorname/"$f".txt); do
		printf '"%s", ' "$w" >> "$f".txt.list
	done
	sed -i -e "s/, $/}\n/" "$f".txt.list
	sed -i "/^\s\+${f}\s\+= \[\.\.\.\]string{.*$/d" ${PKG}.go
done
printf "\n)\n\n" >> "$f".txt.list
grep -B 1000 "^var (" ${PKG}.go > above
grep -A 1000 "^// Adverb returns" ${PKG}.go > below
cat above *.txt.list below > ${PKG}.go
go fmt ${PKG}.go
rm -f *.txt.list above below
cat /usr/share/doc/actorname/README.md > README.md
