#!/bin/bash
# Version: 0.2.1
# Last Update: December 14, 2015
#
# Description: Bash script to deploy a Bedrock+Sage WordPress project to WP Engine's hosting platform
# Repository: https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine.git
# README: https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine/blob/master/README.md
#
# Tested Bedrock Version: 1.4.5
# Tested Sage Version: 8.3.0
# Author: Jason Cross
# Author URL: http://hellojason.net/

####################
# Thanks
####################
# Thanks to [schrapel](https://github.com/schrapel/wpengine-bedrock-build) for
# providing much of the foundation for this script.

####################
# Issues and TODO
####################

# check if bower, npm, gulp are installed
# check if current user can deploy to WP Engine (has ssh key)
# check if composer has been run
# check if remote exists

####################
# PLEASE EDIT
# Your theme directory name here
themeName="wpengine"
# Your WP Engine remote name
wpengineRemoteName="wpengine"
####################

####################
# Variables
####################
environmentDeployTo=$1
presentWorkingDirectory=`pwd`
currentLocalGitBranch=`git rev-parse --abbrev-ref HEAD`
tempDeployGitBranch="wpedeployscript/${currentLocalGitBranch}"
sageThemeDirectory="${presentWorkingDirectory}/wp-content/themes/${themeName}"

####################
# Perform checks before running script
####################

# Halt if there are uncommitted files
if [[ -n $(git status -s) ]]; then
  echo -e "ERROR: Found uncommitted changes.\nPlease review and commit your changes before continuing."
  exit
fi

# Halt if theme directory does not exist
if [ ! -d "$presentWorkingDirectory"/web/app/themes/"$themeName" ]; then
  echo -e "ERROR: Theme not found.\nPlease edit themeName variable in $0."
  exit
fi

# Check for meaningful deploy environment and set variables for later use
if [ "$environmentDeployTo" == "staging" ]; then
  deployRemoteBranch="staging" &> /dev/null
elif [ "$environmentDeployTo" = "production" ]; then
  deployRemoteBranch="master" &> /dev/null
else
  echo -e "ERROR: Unknown deploy environment.\nPlease specify \`sh $0 staging\` or \`sh $0 production\`."
  exit
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
git push "$wpengineRemoteName" "$tempDeployGitBranch":"$environmentDeployTo" --force

# Back to a clean slate
git checkout "$currentLocalGitBranch" &> /dev/null
rm -rf wp-content/ &> /dev/null
git branch -D "$tempDeployGitBranch" &> /dev/null
echo "Done"
