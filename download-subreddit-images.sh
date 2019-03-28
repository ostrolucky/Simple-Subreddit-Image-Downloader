#!/bin/bash

#cfg
useragent="Love by u/gadelat"

subreddit=$1
url="https://www.reddit.com/r/$subreddit/.json?raw_json=1"
content=`wget -U "$useragent" -q -O - $url`
mkdir -p $subreddit
while : ; do
    urls=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")) | .data.preview.images[0].source.url')
    names=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")) | .data.title')
    ids=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")) | .data.id')
    a=1
    wait # prevent spawning too many processes
    for url in $urls; do
        name=`echo -n "$names"|sed -n "$a"p`
        id=`echo -n "$ids"|sed -n "$a"p`
        ext=`echo -n "${url##*.}"|cut -d '?' -f 1`
        newname="$name"_"$subreddit"_$id.$ext
        echo $name
        wget -U "$useragent" --no-check-certificate -nv -nc -P down -O "$subreddit/$newname" $url &>/dev/null &
        a=$(($a+1))
    done
    after=$(echo -n "$content"| jq -r '.data.after')
    if [ -z $after ]; then
        break
    fi
    url="https://www.reddit.com/r/$subreddit/.json?count=200&after=$after&raw_json=1"
    content=`wget -U "$useragent" --no-check-certificate -q -O - $url`
    #echo -e "$urls"
done
