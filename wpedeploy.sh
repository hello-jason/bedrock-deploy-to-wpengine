#!/bin/bash
# Version: 0.3.0
# Last Update: December 14, 2015
#
# Description: Bash script to deploy a Bedrock+Sage WordPress project to WP Engine's hosting platform
# Repository: https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine.git
# README: https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine/blob/master/README.md
#
# Tested Bedrock Version: 1.5.3
# Tested Sage Version: 8.4.2
# Tested bash version: 4.3.42
# Author: Jason Cross
# Author URL: http://hellojason.net/
set -ex
########################################
# PLEASE EDIT
# Your theme directory name (/web/app/themes/yourtheme)
themeName="sage"
# Your WP Engine remote names
wpengineProductionRemote="wpeproduction"
wpengineStagingRemote="wpestaging"
########################################

####################
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
remoteDeployTo=$1
# Get present working directory
presentWorkingDirectory=`pwd`
# Get current branch user is on
currentLocalGitBranch=`git rev-parse --abbrev-ref HEAD`
# Temporary git branch for building and deploying
tempDeployGitBranch="wpedeployscript/${currentLocalGitBranch}"
# Bedrock themes directory
bedrockThemesDirectory="${presentWorkingDirectory}/wp-content/themes/"
# Path to theme directory
sageThemeDirectory="${bedrockThemesDirectory}/${themeName}"

####################
# Perform checks before running script
####################

# Git checks
####################
# Halt if there are uncommitted files
if [[ -n $(git status -s) ]]; then
  echo -e "[\033[31mERROR\e[0m] Found uncommitted changes on current branch \"$currentLocalGitBranch\".\n        Review and commit changes to continue."
  exit 1;
fi

# Check if specified remote exist
git ls-remote "$remoteDeployTo" &> /dev/null
if [ "$?" -ne 0 ]; then
  echo -e "[\033[31mERROR\e[0m] Unable to read from git remote \"$remoteDeployTo\"\n        Visit \033[32mhttps://wpengine.com/git/\e[0m to set this up."
  exit 1;
fi

# Directory checks
####################
# Halt if theme directory does not exist
if [ ! -d "$presentWorkingDirectory"/web/app/themes/"$themeName" ]; then
  echo -e "[\033[31mERROR\e[0m] Theme \"$themeName\" not found.\n        Set \033[32mthemeName\e[0m variable in $0 to match your theme in $bedrockThemesDirectory"
  exit 1
fi

####################
# Begin deploy process
####################
# Checkout new temporary branch
git checkout -b "$tempDeployGitBranch" &> /dev/null

# Copy contents of web/app into wp-content
cp -r web/app wp-content &> /dev/null
rm -rf web &> /dev/null

# Remove Bedrock's mu-plugins
rm "wp-content/mu-plugins/bedrock-autoloader.php" &> /dev/null
rm "wp-content/mu-plugins/disallow-indexing.php" &> /dev/null
rm "wp-content/mu-plugins/register-theme-directory.php" &> /dev/null

# WPE-friendly gitignore
rm .gitignore &> /dev/null
echo -e "/*\n!wp-content/\nwp-content/uploads" > ./.gitignore

####################
# Prepare theme for transfer to WP Engine
echo "Preparing theme on branch ${tempDeployGitBranch}..."
cd "$sageThemeDirectory" &> /dev/null
####################
# Build theme assets
npm install &> /dev/null
bower install &> /dev/null
gulp --production &> /dev/null

# Cleanup theme cruft
rm .bowerrc &> /dev/null
rm .editorconfig &> /dev/null
rm .gitignore &> /dev/null
rm .jscsrc &> /dev/null
rm .jshintrc &> /dev/null
rm .travis.yml &> /dev/null
rm bower.json &> /dev/null
rm gulpfile.js &> /dev/null
rm package.json &> /dev/null
rm ruleset.xml &> /dev/null
rm -rf node_modules &> /dev/null
rm -rf bower_components &> /dev/null

# Back to the top
cd "$presentWorkingDirectory"

####################
# Push to WP Engine
####################
git ls-files | xargs git rm --cached &> /dev/null
cd wp-content/
find . | grep .git | xargs rm -rf
cd ../

git add --all &> /dev/null
git commit -am "WP Engine build from: $(git log -1 HEAD --pretty=format:%s)$(git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/@\1/")" &> /dev/null
echo "Pushing to WPEngine..."

# Push to a remote branch with a different name
# git push remoteName localBranch:remoteBranch
git push "$wpengineRemoteName" "$tempDeployGitBranch" --force

# Back to a clean slate
git checkout "$currentLocalGitBranch" &> /dev/null
rm -rf wp-content/ &> /dev/null
git branch -D "$tempDeployGitBranch" &> /dev/null
echo "Done"
