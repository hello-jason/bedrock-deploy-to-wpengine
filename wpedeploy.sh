#!/bin/bash
# Version: 2.2
# Last Update: December 29, 2016
#
# Description: Bash script to deploy a Bedrock WordPress project to WP Engine's hosting platform
# Repository: https://github.com/hello-jason/bedrock-deploy-to-wpengine.git
# README: https://github.com/hello-jason/bedrock-deploy-to-wpengine/blob/master/README.md
#
# Tested Bedrock Version: 1.7.2
# Tested bash version: 4.3.42
# Author: Jason Cross
# Author URL: https://hellojason.net/
########################################
# Usage
########################################
# bash wpedeploy.sh nameOfRemote

########################################
# Thanks
########################################
# Thanks to [schrapel](https://github.com/schrapel/wpengine-bedrock-build) for
# providing some of the foundation for this script.
# Also thanks to [cmckni3](https://github.com/cmckni3) for guidance and troubleshooting

########################################
# Set variables
########################################
# WP Engine remote to deploy to
wpengineRemoteName=$1
# Get current branch user is on
currentLocalGitBranch=`git rev-parse --abbrev-ref HEAD`
# Temporary git branch for building and deploying
tempDeployGitBranch="wpedeployscript/${currentLocalGitBranch}"

########################################
# Perform checks before running script
########################################

# Halt if there are uncommitted files
function check_uncommited_files () {
  if [[ -n $(git status -s) ]]; then
    echo -e "[\033[31mERROR\e[0m] Found uncommitted files on current branch \"$currentLocalGitBranch\".\n        Review and commit changes to continue."
    git status
    exit 1
  fi
}

# Check if specified remote exists
function check_remote_exists () {
  echo "Checking if specified remote exists..."
  git ls-remote "$wpengineRemoteName" &> /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "[\033[31mERROR\e[0m] Unknown git remote \"$wpengineRemoteName\"\n        Visit \033[32mhttps://wpengine.com/git/\e[0m to set this up."
    echo "Available remotes:"
    git remote -v
    exit 1
  fi
}

# Gets current timestamp when called
function timestamp () {
  date
}

########################################
# Begin deploy process
########################################
function deploy () {
  # Checkout new temporary branch
  echo -e "Preparing theme on branch ${tempDeployGitBranch}..."
  git checkout -b "$tempDeployGitBranch" &> /dev/null

  # Run composer
  composer install
  # Setup directory structure
  mkdir wp-content && mkdir wp-content/themes && mkdir wp-content/plugins && mkdir wp-content/mu-plugins
  # Copy meaningful contents of web/app into wp-content
  cp -rp web/app/plugins wp-content && cp -rp web/app/themes wp-content && cp -rp web/app/mu-plugins wp-content

  ########################################
  # Push to WP Engine
  ########################################
  # WPE-friendly gitignore
  echo -e "# Ignore everything\n/*\n\n# Except this...\n!wp-content/\n!wp-content/**/*" > .gitignore
  git rm -r --cached . &> /dev/null
  # Find and remove nested git repositories
  rm -rf $(find wp-content -name ".git")
  rm -rf $(find wp-content -name ".github")

  git add --all
  git commit -m "Automated deploy of \"$tempDeployGitBranch\" branch on $(timestamp)"
  echo "Pushing to WP Engine..."

  # Push to a remote branch with a different name
  # git push remoteName localBranch:remoteBranch
  git push "$wpengineRemoteName" "$tempDeployGitBranch":master --force

  ########################################
  # Back to a clean slate
  ########################################
  git checkout "$currentLocalGitBranch" &> /dev/null
  rm -rf wp-content/ &> /dev/null
  git branch -D "$tempDeployGitBranch" &> /dev/null
  echo -e "[\033[32mDone\e[0m] Deployed \"$tempDeployGitBranch\" to \"$wpengineRemoteName\""
}

########################################
# Execute
########################################
# Checks
check_uncommited_files
check_remote_exists

# Uncomment the following line for debugging
# set -x

# Deploy process
deploy
