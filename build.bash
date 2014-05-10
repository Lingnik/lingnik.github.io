#!/bin/bash
if [ "$#" -lt 1 ]; then
    echo "You need to specify a commit message."
else
    jekyll build
    git add --all
    git commit -m "$*"
    git pull
    git push
    cd ../master
    git add --all
    git commit -m "$*"
    git pull
    git push
    cd ../jekyll
fi
