#!/bin/bash

if [[ $TRAVIS_BRANCH == 'master' ]] ; then
  cd _site
  git init

  git config user.name "Travis CI"
  git config user.email "qmhs414@gmail.com"

  git add .
  git commit -m "Deploy"

  # We redirect any output to
  # /dev/null to hide any sensitive credential data that might otherwise be exposed.
  git push --force --quiet "https://$REPO_TOKEN@github.com/donniesky/donniesky.github.io.git" master > /dev/null 2>&1
else
  echo 'Invalid branch. You can only deploy from master.'
  exit 1
fi