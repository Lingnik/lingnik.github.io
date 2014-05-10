How to build:

We expect a base folder that contains two sub-folders:
master, a clone of the repo -- the actual built site
jekyll, a clone of the repo but 'git checkout jekyll' -- the jekyll src


Go into the jekyll directory
`git pull`
Make your changes
`jekyll build`
`git push`
`cd ../master/`
`git add --all`
`git commit -m "describe"`
`git push`

