# Deploy Bedrock+Sage WordPress project to WP Engine hosting platform

## Brief

This bash script prepares a WordPress project built on Root's [Bedrock](https://roots.io/bedrock/) boilerplate with the [Sage](https://roots.io/sage/) starter theme and deploys it **to the WP Engine hosting platform**. It can be easily modified if you do not use the Sage theme.

* Repo: [https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine](https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine)
* Demo: [http://bedrocksage.wpengine.com/](http://bedrocksage.wpengine.com/)

## Purpose

WP Engine expects to see a standard WordPress project in the document root for your account. Since Bedrock shifts folders and files around a bit, this script temporarily moves everything back to their original locations (on a safe, temporary branch), which is then pushed to WP Engine.

The result is a properly-versioned Bedrock repo that you can safely and repeatedly deploy to WP Engine's production and staging environments.

## Installation &amp; Setup

### 1. Grab the script

Source code is available at [https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine](https://github.com/hello-jason/bedrock-sage-deploy-to-wpengine). This repo is not meant to be cloned into your project. Rather, just grab the `wpedeploy.sh` file and place it in the top-level directory of your Bedrock project, and keep it with your project's repo.

### 2. Setup git push

Follow [these instructions from WP Engine](https://wpengine.com/git/) to setup SSH access and git push for your WP Engine account.

This guide assumes your remotes are named as follows:

* **Production**: wpeproduction
* **Staging**: wpestaging

### 3. Set theme variable

Out the box, this script assumes your theme's name is **sage**. Open `wpdeploy.sh` and change the following variable (around line 17).

* Set `themeName` to the **directory name** of your theme (/app/themes/**yourthemename**)

### 4. Run script

In short, it performs a few checks, creates a temporary deployment branch, then builds the site **locally**. It force pushes to the specified environment using WP Engine's git push feature. When complete, it removes the temp branch and puts you back on the branch you started from.

Run at the **top level** of your project, in the same directory as your `.env` and composer.json files. Replace each remote name with the ones you created during step 1. **Note**, running this script with the `bash` command is important; Ubuntu defaults to `dash` rather than `bash`, and the script will fail if you simply run `sh`.

Deploy to staging:

```
bash wpedeploy.sh wpestaging
```

Deploy to production:

```
bash wpedeploy.sh wpeproduction
```

## FAQs

* **What branch does it deploy?** - Deploys the local branch you run it on to whichever WP Engine remote you specify (production or staging)
* **What about the uploads directory?** - Completely ignores the uploads directory. You'll have to upload that separately [via SFTP](https://wpengine.com/support/sftp/).
* **How does it handle plugin versions?** - You can upgrade or downgrade version numbers in the `composer.json` file, run `composer update`, then run this script to deploy the new version to WP Engine. However, this script **will not delete** plugins from WP Engine's servers; you will have to do that via SFTP.
* **What about WordPress core?** - This script only deploys the contents of `wp-content`. You will manage WP core in WP Engine's interface.
