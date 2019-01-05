Simple Subreddit Image Downloader
==========================
Tired of all of those reddit downloaders which want you to install tons of dependencies and then don't work anyway? Me too.

*Simple Subreddit Image Downloader* is bash script which:
- has minimal external dependencies
- downloads full-size images from subreddits
- is crossplatform (tested on windows with cygwin)
- uses SSL connection

This script just downloads all directly linked images in subreddit. For more complex usage, use other reddit image downloader.

Requirements
============
- bash (cygwin is OK)
- wget
- GNU grep (on MacOS install with `brew install grep --with-default-names`)

Usage
=====
`./rdit.sh <subreddit_name>`

Script downloads images to folder named "down" in current directory. If you want to change that, you need to edit destination in rdit.sh for now.