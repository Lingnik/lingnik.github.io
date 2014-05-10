#!/bin/bash
jekyll build
git add --all
git commit
git pull
git push
cd ../master
git add --all
git commit
git pull
git push
cd ../jekyll
