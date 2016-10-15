#!/bin/bash
# Version: 2.0.0
# Last Update: October 15, 2016
#
# Description: Bash script to deploy a Bedrock WordPress project to WP Engine's hosting platform
# Repository: https://github.com/hello-jason/bedrock-deploy-to-wpengine.git
# README: https://github.com/hello-jason/bedrock-deploy-to-wpengine/blob/master/README.md
#
# Tested Bedrock Version: 1.7.2
# Tested bash version: 4.3.42
# Author: Jason Cross
# Author URL: http://hellojason.net/
########################################
# Usage
####################
# bash wpedeploy.sh nameOfRemote

####################
# Thanks
####################
# Thanks to [schrapel](https://github.com/schrapel/wpengine-bedrock-build) for
# providing some of the foundation for this script.
# Also thanks to [cmckni3](https://github.com/cmckni3) for guidance and troubleshooting

####################
# Set variables
####################
# WP Engine remote to deploy to
wpengineRemoteName=$1
# Get present working directory
presentWorkingDirectory=`pwd`
# Get current branch user is on
currentLocalGitBranch=`git rev-parse --abbrev-ref HEAD`
# Temporary git branch for building and deploying
tempDeployGitBranch="wpedeployscript/${currentLocalGitBranch}"
# Bedrock themes directory
bedrockThemesDirectory="${presentWorkingDirectory}/web/app/themes/"

####################
# Perform checks before running script
####################

# Git checks
####################
# Halt if there are uncommitted files
if [[ -n $(git status -s) ]]; then
  echo -e "[\033[31mERROR\e[0m] Found uncommitted files on current branch \"$currentLocalGitBranch\".\n        Review and commit changes to continue."
  git status
  exit 1
fi

# Check if specified remote exist
git ls-remote "$wpengineRemoteName" &> /dev/null
if [ "$?" -ne 0 ]; then
  echo -e "[\033[31mERROR\e[0m] Unknown git remote \"$wpengineRemoteName\"\n        Visit \033[32mhttps://wpengine.com/git/\e[0m to set this up."
  echo "Available remotes:"
  git remote -v
  exit 1
fi

####################
# Begin deploy process
####################
# Checkout new temporary branch
echo "Preparing theme on branch ${tempDeployGitBranch}..."
git checkout -b "$tempDeployGitBranch" &> /dev/null

# Run composer
composer install

# WPE-friendly gitignore
rm .gitignore &> /dev/null
echo -e "/*\n!wp-content/" > ./.gitignore

# Copy meaningful contents of web/app into wp-content
mkdir wp-content && cp -rp web/app/plugins wp-content && cp -rp web/app/themes wp-content

####################
# Push to WP Engine
####################
git ls-files | xargs git rm --cached &> /dev/null
cd "$presentWorkingDirectory"/wp-content/
find . | grep .git | xargs rm -rf
cd "$presentWorkingDirectory"

git add --all &> /dev/null
git commit -am "WP Engine build from: $(git log -1 HEAD --pretty=format:%s)$(git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/@\1/")" &> /dev/null
echo "Pushing to WPEngine..."

# Push to a remote branch with a different name
# git push remoteName localBranch:remoteBranch
git push "$wpengineRemoteName" "$tempDeployGitBranch":master --force

####################
# Back to a clean slate
####################
git checkout "$currentLocalGitBranch" &> /dev/null
rm -rf wp-content/ &> /dev/null
git branch -D "$tempDeployGitBranch" &> /dev/null
echo "Done"
