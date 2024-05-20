#!/bin/bash

print_usage() {
    echo "Usage: $0 SUBREDDIT [hot|new|rising|top|controversial] [all|year|month|week|day] [limit]"
    echo "Examples:   $0 starterpacks new week 10"
    echo "            $0 funny top all 50"
}

subreddit=$1
sort=${2:-hot}
top_time=$3
limit=${4:-0}

if [[ "$1" == "-h" || -z "$subreddit" ]]; then
    print_usage
    exit 0
fi

base_url="https://www.reddit.com/r/$subreddit/$sort/.json?raw_json=1"
url="${base_url}&t=$top_time"
content=$(curl --retry 3 --silent "$url")

mkdir -p "$subreddit"
i=1

while true; do
    images=$(echo "$content" | jq -r '.data.children[] | select(.data.post_hint == "image") | .data.preview.images[0].source.url')
    titles=$(echo "$content" | jq -r '.data.children[] | select(.data.post_hint == "image") | .data.title')
    ids=$(echo "$content" | jq -r '.data.children[] | select(.data.post_hint == "image") | .data.id')

    a=1
    for url in $images; do
        title=$(echo "$titles" | sed -n "${a}p")
        id=$(echo "$ids" | sed -n "${a}p")
        ext=$(echo "${url##*.}" | cut -d '?' -f 1 | sed 's/gif/png/')
        newname=$(echo "$title" | tr -d '/\r\n' | sed "s/\// /g")_"$subreddit"_$id.$ext
        printf "%d/%d : %s\n" "$i" "$limit" "$newname"
        curl --retry 3 --silent --no-clobber --output "$subreddit/$newname" "$url" &

        ((a++))
        ((i++))

        if (( i > limit )); then
            wait
            exit 0
        fi
    done

    after=$(echo "$content" | jq -r '.data.after // empty')
    if [[ -z "$after" ]]; then
        break
    fi

    url="${base_url}&count=200&after=$after&t=$top_time"
    content=$(curl --retry 3 --silent "$url")
done

wait
