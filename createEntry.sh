#!/usr/bin/env bash

if [ ! -f "$1" ]; then
	echo "A picture file must be supplied"
	exit 1
fi

currentyear=$(date +%Y)

read -p "year? (default $currentyear)" year

if [ "$year" = "" ]; then
	year=$currentyear
fi

currentmonth=$(date +%m)

read -p "month? (default $currentmonth)" month 

if [ -z "$month" ]; then
	month=$currentmonth
fi

currentday=$(date +%d)

read -p "day? (default $currentday)" day 

if [ -z "$day" ]; then
	day=$currentday
fi

workingdir="$year/$month/$day"

mkdir -p $workingdir

itemnumber=$(ls -1q $workingdir | wc -l)
((itemnumber++))

newfilename=$itemnumber.${1#*.}

mv "$1" "$workingdir/$newfilename"
updated_json=$(jq --arg year "$year" --arg month "$month" --arg day "$day" --arg file "$newfilename" '
    if .[$year] == null then .[$year] = {} else . end |
    if .[$year][$month] == null then .[$year][$month] = {} else . end |
    if .[$year][$month][$day] == null then .[$year][$month][$day] = [] else . end |
    .[$year][$month][$day] += [$file]
' "ledger.json")

echo "$updated_json" > "ledger.json"
