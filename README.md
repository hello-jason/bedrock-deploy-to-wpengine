# Deploy Roots Bedrock WordPress project to WP Engine hosting platform

Last tested: October 8, 2016

Works up to Bedrock 1.7.2

Repo: [https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine](https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine)

## Changelog

v2 - Removes build process for Sage theme.
v1 - Works up to Bedrock 1.7.2, Sage 8.5

## Description

This bash script prepares a WordPress project built on Root's [Bedrock](https://roots.io/bedrock/) boilerplate and deploys it **to the WP Engine hosting platform**.

WP Engine expects to see a standard WordPress project in the document root for your account. Since Bedrock shifts folders and files around a bit, this script temporarily moves everything back to their original locations (on a safe, temporary branch), which is then pushed to WP Engine.

The result is a properly-versioned Bedrock repo that you can safely and repeatedly deploy to WP Engine's production and staging environments.

Demo:

* Demo Bedrock site on WP Engine: [http://bedrocksage.wpengine.com/](http://bedrocksage.wpengine.com/)
* Demo Bedrock site repo: [https://github.com/hello-jason/bedrock-sage-on-wpengine-demo](https://github.com/hello-jason/bedrock-sage-on-wpengine-demo)

## Installation &amp; Setup

### 1. Grab the script

Source code is available at [https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine](https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine). This repo is not meant to be cloned into your project. Rather, just grab the `wpedeploy.sh` file and place it in the top-level directory of your Bedrock project, and keep it with your project's repo.

### 2. Setup git push

Follow [these instructions from WP Engine](https://wpengine.com/git/) to setup SSH access and git push for your WP Engine account.

This readme assumes your remotes are named as follows:

* **Production**: wpeproduction
* **Staging**: wpestaging

### 3. Set theme variable

Out the box, this script assumes your theme's name is **sage**. Open `wpdeploy.sh` and change the following variable (around line 17).

* Set `themeName` to the **directory name** of your theme (/app/themes/**yourthemename**)

## Usage

Run at the **top level** of your project, in the same directory as your `.env` and `composer.json` files. Replace each remote name with the ones you created during step 1.

Deploy to staging:

```
bash wpedeploy.sh wpestaging
```

Deploy to production:

```
bash wpedeploy.sh wpeproduction
```

## FAQs

* **Which branch does it deploy?** - Deploys the local branch you run it on to whichever WP Engine remote you specify (production or staging)
* **What about the uploads directory?** - Completely ignores the uploads directory. You'll have to upload that separately [via SFTP](https://wpengine.com/support/sftp/).
* **How does it handle plugin versions?** - You can upgrade or downgrade version numbers in the `composer.json` file, run `composer update`, then run this script to deploy the new version to WP Engine. However, this script **will not delete** plugins from WP Engine's servers; you will have to do that via SFTP or wp-admin.
* **What about WordPress core?** - This script only deploys the contents of `wp-content` to WP Engine's servers. You should keep WordPress core updated in your composer file, but that only benefits your local dev environment. You will manage WP core for your publicly-facing site in WP Engine's interface directly.
* **Why doesn't it work on Ubuntu?** - It does! But Ubuntu defaults to `dash` rather than `bash`, and the script may fail if you simply run `sh`. Other distros may do the same, so running this script with the `bash` command is important.
* **Why did you remove the build processes for Sagae?** - Since each project will have a different build process for its theme, it makes more sense to focus solely on deploying to WP Engine. More info in [this issue](https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine/issues/13).
