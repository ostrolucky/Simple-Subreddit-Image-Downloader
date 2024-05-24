#!/usr/bin/env bash

#cfg
subreddit=$1
sort=${2:-hot}
top_time=$3
limit=${4:-0}

if [ "$1" == "-h" ] || [ -z $subreddit ]; then
echo "Usage: $0 SUBREDDIT [hot|new|rising|top|controversial] [all|year|month|week|day] [limit]
Examples:   $0 starterpacks new week 10
            $0 funny top all 50"
exit 0;
fi

base_url="https://www.reddit.com/r/$subreddit/$sort/.json?raw_json=1"
url="${base_url}&t=$top_time"
content=`curl $url`
mkdir -p $subreddit
i=1
while true; do
    images=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.preview.images[0].source.url')
    titles=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.title')
    ids=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.id')
    a=1
    wait # prevent spawning too many processes
    for url in $images; do
        title=$(echo -n "$titles"|sed -n "${a}p")
        id=$(echo -n "$ids"|sed -n "${a}p")
        newname=$(echo $title | tr -d '/\r\n' | sed 's/\// /g')_"$subreddit"_$id.$(echo -n "${url##*.}"|cut -d '?' -f 1 | sed 's/gif/png/')
        echo "$i/$limit : $newname"
        curl --retry 3 --no-clobber --output "$subreddit/$newname" $url &>/dev/null &
        ((a++))
        ((i++))
        if (( i > limit )); then
          wait
          exit 0
        fi
    done
    after=$(echo -n "$content"| jq -r '.data.after//empty')
    if [ -z $after ]; then
        break
    fi
    url="${base_url}&count=200&after=$after&t=$top_time"
    content=`curl --retry 3 $url`
done
