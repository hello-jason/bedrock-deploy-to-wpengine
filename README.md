# Deploy Bedrock+Sage WordPress project to WP Engine hosting platform

This bash script prepares a WordPress project using the [Bedrock](https://roots.io/bedrock/) boilerplate with the [Sage](https://roots.io/sage/) starter theme **to the WP Engine hosting platform**.

Demo: [http://bedrocksage.wpengine.com/](http://bedrocksage.wpengine.com/)

## Purpose

WP Engine expects to see a standard WordPress project in the document root for your account. Since Bedrock shifts things around a bit, this script temporarily moves your files &amp; directories around so WP Engine knows how to serve your Bedrock+Sage site. But it does this on a separate branch, leaving your Bedrock project in tact.

## Installation &amp; Setup

### 1. Setup git push

Follow [these instructions from WP Engine](https://wpengine.com/git/) to setup SSH access and git push for your WP Engine account.

### 2. Set theme variable

Out the box, this script assumes your theme's name is **sage**. Open `wpdeploy.sh` and change the following variable (around line 17).

* Set `themeName` to the **directory name** of your theme (/app/themes/**yourthemename**)

### 3. Run script

In short, it performs a few checks, creates a temporary deployment branch, then builds the site **locally**. It force pushes to the specified environment using WP Engine's git push feature. When complete, it removes the temp branch and puts you back on the branch you started from.

Run at the **top level** of your project, in the same directory as your `.env` and composer.json files.

Deploy to staging:

```
bash sh wpedeploy.sh staging
```

Deploy to production:

```
bash sh wpedeploy.sh production
```

## Notes

* Deploys the local branch you run it on to whichever remote WP Engine branch you specify (production or staging)
* Completely ignores the uploads directory
* Ubuntu defaults to `dash` rather then `bash`, so the `bash` command is important here. There are issues running this with `dash`.
