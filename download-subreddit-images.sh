#!/bin/bash

#cfg
subreddit=$1
sort=$2
top_time=$3
limit=$4

if [ "$1" == "-h" ] || [ -z $subreddit ]; then
echo "Usage: $0 SUBREDDIT [hot|new|rising|top|controversial] [all|year|month|week|day] [limit]
Examples:   $0 starterpacks new week 10
            $0 funny top all 50"
exit 0;
fi

if [ -z $sort ]; then
    sort="hot"
fi

if [ -z $top_time ];then
    top_time=""
fi

if [ -z $limit ]; then
	limit=0
fi

url="https://www.reddit.com/r/$subreddit/$sort/.json?raw_json=1&t=$top_time"
content=`curl $url`
mkdir -p $subreddit
i=1
while : ; do
    urls=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.preview.images[0].source.url')
    names=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.title')
    ids=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.id')
    a=1
    wait # prevent spawning too many processes
    for url in $urls; do
        name=`echo -n "$names"|sed -n "$a"p`
        id=`echo -n "$ids"|sed -n "$a"p`
        ext=`echo -n "${url##*.}"|cut -d '?' -f 1 | sed 's/gif/png/' `
        newname=`echo $name | sed "s/^\///;s/\// /g"`_"$subreddit"_$id.$ext
        printf "$i/$limit : $newname\n"
        curl --retry 3 --no-clobber --output "$subreddit/$newname" $url &>/dev/null &
        ((a=a+1))
        ((i=i+1))
        if [ $i -gt $limit ] ; then
          exit 0
        fi
    done
    after=$(echo -n "$content"| jq -r '.data.after//empty')
    if [ -z $after ]; then
        break
    fi
    url="https://www.reddit.com/r/$subreddit/$sort/.json?count=200&after=$after&raw_json=1&t=$top_time"
    content=`curl $url`
done
