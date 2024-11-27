#!/usr/bin/env bash

if [ ! -f "$1" ]; then
    echo "A picture file must be supplied"
    exit 1
fi

currentyear=$(date +%Y)

read -p "year? (default $currentyear) " year

if [ -z "$year" ]; then
    year=$currentyear
fi

currentmonth=$(date +%m)

read -p "month? (default $currentmonth) " month

if [ -z "$month" ]; then
    month=$currentmonth
fi

currentday=$(date +%d)

read -p "day? (default $currentday) " day

if [ -z "$day" ]; then
    day=$currentday
fi

workingdir="$year/$month/$day"

mkdir -p "$workingdir"

itemnumber=$(ls -1q "$workingdir" | wc -l)
((itemnumber++))

newfilename=$itemnumber.${1#*.}

mv "$1" "$workingdir/$newfilename"

# Check if the JSON file exists
if [ ! -f "ledger.json" ]; then
    echo "{}" > "ledger.json"
fi

# Retrieve existing text for the date, if any
existing_text=$(jq -r --arg date "$workingdir" '.[$date].text // empty' "ledger.json")

if [ -z "$existing_text" ]; then
    read -p "Enter description: " text
    if [ -z "$text" ]; then
        text="Default description"
    fi
else
    echo "Existing description: $existing_text"
    text=$existing_text
fi

# Update JSON with file and text
updated_json=$(jq --arg date "$workingdir" --arg file "$newfilename" --arg text "$text" '
    if .[$date] == null then .[$date] = { files: [], text: $text } else . end |
    .[$date].files += [$file] |
    .[$date].text = .[$date].text // $text
' "ledger.json")

echo "$updated_json" > "ledger.json"

echo "File moved to $workingdir/$newfilename and ledger updated."

