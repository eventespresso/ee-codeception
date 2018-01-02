# EE Codeception Library
[![Travis](https://travis-ci.org/eventespresso/ee-codeception.svg?branch=master)](https://travis-ci.org/eventespresso/ee-codeception)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)
[![By Event Espresso](https://img.shields.io/badge/For-Event%20Espresso-blue.svg)](https://github.com/eventespresso/event-espresso-core)

This utility tool is used by [Event Espresso](https://github.com/event-espresso/event-espresso-core) for executing acceptance tests utilizing the [Codeception](http://codeception.com/) library.  

This package is dockerized and can be executed using the included script for running tests (instructions below).  

This library is also used for nightly triggered runs of tests via travis (triggered by a server installation of the [automated nightly builds script](https://github.com/eventespresso/ee-addon-circle-nightly))

The design of this library follows a "mother ship" paradigm whereby this library itself just contains the main library and dependencies.  Then builds are pulled from the repositories being tested on the initial run.

## Local Installation
### Dependencies
The only thing needed for setting this up for running tests locally is Docker and Git. 

- [Windows Installer](https://docs.docker.com/docker-for-windows/install/)
- [MacOSX Installer](https://docs.docker.com/docker-for-mac/install/)
- [Linux Installer*](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/) (This is a link to the Ubuntu installation instructions.  Other Linux distro instructions are available on the same site.)

### Setup Steps

#### 1. Clone this package locally
```bash
git clone https://github.com/eventespresso/ee-codeception.git
```
#### 2. Execute `run-tests.sh` Script
Make sure you are in the top level folder of this repo (the same level that `run-tests.sh` is found in) then execute this in your terminal/bash client.
```bash
.run-tests.sh
```
That's it!  By default, the tests will be setup and run against Event Espresso core master using the Chrome browser via selenium.  More options are possible.  Read on in the **usage** section below.

>  **NOTE:** The initial run of the tests takes a bit longer than usual (5-20min depending on your internet speed) because all the docker images have to be downloaded and then configured.  Plus the initial setup of the test environment takes a bit for the composer install and wp setup.  However once thats done, subsequent test runs go faster.

###  Usage

To run tests you just need to run this within the root path of the tool:

```
./run-tests.sh
```
By default, this will do the following:

- initialize any docker containers (including pulling any necessary images)
- build for running tests using the Chrome Browser via Selenium
- setup the test environment (including installing WordPress)
- pull in the latest master branch of Event Espresso Core and install the plugin (but not activate it).
- pull in any other plugins currently listed as dependencies for the EE core tests.
- Build the acceptance test environment (copy helpers/page classes/generated traits etc).
- Run the full test suite for EE core (whatever tests were copied from EE core's `/acceptance_tests/tests/` folder)

However, there are some other arguments you can use with this script to adjust the way tests are setup:

| Argument |Usage                                           |  Description                                                                                                                                                                                                                                                            |
| -------- |------------------------------------------------| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-h`     |`./run-tests.sh -h `                            |  Will output the a list of arguments you can use for customizing test runs.                                                                                                                                                                                             |
| `-b`     |`./run-tests.sh -b FET/1234/some-ee-core-branch`|  This allows you to indicate the specific branch of EE core you want to be used for tests.                                                                                                                                                                              |
| `t`      |`./run-tests.sh -t 4.8.57.p`                    |  Used to indicate what _tag_ of EE core you want the tests run against.  Make sure you use a tag that is not the release tag (with all test folders removed)                                                                                                            |
| `-a`     |`./.run-tests.sh -a eea-people-addon`           |  Used to indicate what add-on you want to run acceptance tests for. You can use this in combination with `-b` to run the add-on against a specific version of EE core. When this flag is used, EE core acceptance tests are not executed.                               |
| `s`      |`./run-tests.sh -s`                             |  This flag should be used when you want to rebuild the internal test environment from scratch. Internal rebuilds are just re-installing WordPress and cloning the latest specified plugins (ee core or add-on etc)                                                      |
| `e`      |`./run-tests.sh -e chrome`                      |  This flag is used to specify what browser to use for tests.  There are currently three main options: `chrome`, `firefox`, `phantomjs`.  There's also two additional debugging options (explained later in the advanced usage section): `chromedebug` and `firefoxdebug`|
| `f`      |`./run-tests.sh -f ActivationCept `             |  This is used to indicate specific tests to run  (more in the advanced usage section,)                                                                                                                                                                                  |
| `R`      |`./run-tests.sh -R`                             |  This is a debugging flag. By default  docker containers spun up for testing are stopped and removed after the tests finish running.  Sometimes its advantageous to leave them up after tests are run to debug issues.  Setting this flag allows for that.              |

## What happens under the hood

When tests are triggered, this tool does the following:
* Starts nginx, mariadb, phpfpm, starts a service used for ee-codeception library on, and starts whatever browser service is configured for executing the acceptance tests on (available browser services are selenium - chrome, selenium - firefox, or phantomjs)
* Various volumes are setup for the containers linking the data stored on the host to folders within the containers (more in the _locations_ section below)
* Various volume mounts are setup for the log files logged to by the services (php-fpm, nginx etc)
* Sets up an alias `ee-codeception.test` host for the `web-server` service (nginx) which is what the browsers will use to access the wp instance.
* Installs the latest version of WordPress and configures for the tests.
* Retrieves and installs the requested branch/tag of Event Espresso core (defaults to master if none is specified).
* Install an Event Espresso add-on (if requested).
* Copies acceptance tests from the `acceptance_tests/tests` folder of Event Espresso core if no EE add-on was installed or the add-on if that was requested.  These tests are copied into the codeception `tests/acceptance` folder.
* Copies any Page objects from the `acceptance_tests/Page` folder of Event Espresso core _and_ the EE add-on (if installed) into `tests/_support/Page` folder of ee-codeception.
* copies any `Helper` traits from the `acceptance_tests/Helpers` folder of Event Espresso core _and_ the EE add-on (if installed) into `src/helpers`
* Executes `vendor/bin/codecept build` to build any fixtures/code needed for running the tests.
* Runs the `build_ee` command with any `ee-codeception.yml` file found in either the `event-espresso-core/acceptance_tests` or the installed EE addon. 
* Installs any additional requested WordPress plugins indicated in the `ee-codeception.yml` file.
* Runs the acceptance tests.
* Stops and removes the docker containers (not the images) and returns the exit code from the test run.

So basically this takes care of a lot for you!

## Locations

One of the beauties of this setup is that the files the docker containers use are synced up with your local host system so you can use that for writing tests and/or see what's going on.  Some important locations you'll want to be aware of.  All the locations are relative to the root directory for the ee-codeception library installed on your host machine (i.e the path that `run-tests.sh` is on)

|Location on the Host                  | Location in the Container                | Used for:                                                                                                                                                                                                                                                                                                                                                    |
|------------------------------------- | -----------------------------------------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|./*                                   | /home/accuser/ee-codeception             | Pretty much everything maps to the `ee-codeception` folder on the container                                                                                                                                                                                                                                                                                  |
|./docker/www/wp                       | /home/accuser/www/wp                     | This is where WordPress is installed (and the plugins being tested)  When writing tests, you can quickly test changes in the actual plugin files (eg. to fix something broken in the plugin exposed by a failing test)                                                                                                                                       |
|./docker/www/logs                     | /home/accuser/www/logs                   | This is where the nginx service will record to its access.log and error.log                                                                                                                                                                                                                                                                                  |
|./docker/scripts/logs                 | /var/log/php7                            | This is where the phpfpm service will log its errors                                                                                                                                                                                                                                                                                                         |
|. /docker/www/wp/wp-content/debug.log | /home/accuser/www/wp/wp-content/debug.log| This is where all php errors get logged during test runs in the WordPress environment.                                                                                                                                                                                                                                                                       |
|./tests/output                        | /home/accuser/ee-codeception/tests/output| Whenever a test fails, the browser service will take a screenshot and it is saved to this folder.  This can be useful to figure out what might have happened during the fail and whether its a problem with the code being tested or the actual test code. The `debug` folder in this directory contains any manually triggered screensthos during test runs.| 

## Writing tests

Of course the main purpose of this tool is for easily writing and running acceptance tests. As mentioned earlier, thedesign of this library follows a "mother ship" paradigm whereby this library itself just contains the main library and dependencies.  Then builds are pulled from the repositories being tested on the initial run.

This means instead of writing the tests in this repository, the tests (`*Cept` or `*Cest` files) are written and added to the `acceptance_tests` folder within the plugin/add-on you are writing the tests for.  This allows for keeping tests specific to the version of the plugin the tests were written for.

The only thing that should be added to this tool are non version specific helper methods etc that can be used for _any_ add-on (or ee core) being tested using the library.

In this tool will be found the following classes that you should use when writing your tests:

### Additional Actors

There are two new actors exposed for your tests:
* `EventEspressoAcceptanceTester`
* `EventEspressoAddonAcceptanceTester`

The purpose of these additional actors is to expose more actions for using in your tests so you can focus more on writing the tests than figuring out how to write the tests.  So whenever you write a test you should use `EventEspressoAcceptanceTester` like this (if writing a test for the core plugin):

```php
<?php
$I = new EventEspressoAcceptanceTester($scenario);
//add your additional statements here.
```
By default, this actor will make sure that Event Espresso is activated (and has finished its initial install setup).  It will complete its setup at the "logged out" state.

If you want to bypass the initial activation process (for any specific testing you want to do) you can instantiate this actor by doing this:

```php
$I = new EventEspressoAcceptanceTester($scenario, false);
```

The `EventEspressoAddonAcceptanceTester` is provided as the actor you use for EE add-ons.  Along with the `$scenario` variable, you must provide it with the add-on slug you are testing with.  For example:

```php
$I = new EventEspressoAddonAcceptanceTester($scenario, 'eea-addon-people');
//add  your additional statements here
```
This actor takes care of ensuring EE core and the indicated add-on are activated before executing the additional statements in your `*Cept` file.  Of course, like you could for `EventEspressoAcceptanceTester` it is also possible to skip the activation by sending in `false` as the third parameter on this class:

```php
$I = new EventEspressoAddonAcceptanceTester($scenario, 'eea-addon-people', false);
```
Both these actor classes expose a number of additional actions that should help you with the tests you write (you can check in the actor classes for what is currently available).

> Note each custom actor class also by default imports its relevant helper trait.  For `EventEspressoAcceptanceTester` the `EventEspresso\Codeception\helpers\CoreAggregate` trait is imported, and for `EventEspressoAddonAcceptanceTester` the `EventEspresso\Codeception\helpers\AddonAggregate` trait is imported.  These are special generated traits that allow us to have helper traits defined in their associated repository which makes acceptance tests more version aware.

For this reason, _most_ custom actor actions should be built in a helper trait and not in these actors.

### PageObjects

One thing we're striving to do with this tool is to describe all routes/elements etc for the tests via [PageObjects](http://codeception.com/docs/06-ReusingTestCode#pageobjects).  You can see examples of page objects [here](https://github.com/eventespresso/event-espresso-core/tree/master/acceptance_tests/Page).  Whenever possible, use a PageObject to keep your tests DRY so if we tweak element location etc in an add-on or EE core, we just have to change the related fixtures in the `PageObject` class(es) and tests should "just work".

As it is with the actual test case classes (`*Cept` or `*Cest`), PageObjects should live with the repository they are built for.  So for example PageObjects for Event Espresso Core live in the `acceptance_tests/Page` folder and they are copied from there when this tool builds the tests suite. 

### Helper Traits

As mentioned in the Additional Actors section, the preferred method for adding shared actions for your tests is to create a Helper trait within the `acceptance_tests/Helpers` folder and then when the acceptance test build process is run it will automatically import those actions into the actor via a generated process.  So there's two things you need to do:

#### First: build your trait.

As an example:

```php
<?php
namespace EventEspresso\Codeception\helpers;

trait Test
{
    public function seeSomething()
    {
        /* @var \EventEspressoAcceptanceTester **/
        $I = $this;
        $I->seeElement('#cheesburger');
    }
}
```

Some common things for all Helper traits:

- All of them should be within the `EventEspresso\Codeception\helpers` namespace.
- `$this` will refer to an instance of the actor the trait is registered with.  In this case this is a helper trait added to `event-espresso-core/acceptance_tests/Helpers` so it will be imported into the `EventEspressoAcceptanceTests` actor.

#### Second: add your trait(s) to the `ee-codeception.yml`

For example the trait above would be added to `event-espresso-core/acceptance_tests/ee-codeception.yml` like this:

```yaml
core:
  - Test
```

Each additional trait would be added on a new line indented the same.  So for example if we had another trait named `EventAdmin`:

```yaml
core:
  - Test
  - EventAdmin
```

 The yaml entry is different for helper traits added to add-ons.  For example, if we had `PeopleAdmin` and `PeopleFrontend` traits in `eea-people-addon/acceptance_tests/Helpers`, then in the `eea-people-addon/acceptance_tests/ee-codeception.yml` file we'd have something like this:

```yaml
addon:
  - PeopleAdmin
  - PeopleFrontend
```

> **Note:** the yaml files do **not** need the fully qualified class name for the entry.  Only the trait name is needed.  However, that's why its important you declare the correct namespace in the file containing the trait.

#### Some general best practices to follow:
- Keep your traits simple and specific to what they are for (eg all EventAdmin related actions could go in a `EventAdmin` trait).
- As much as possible use `PageObjects` in your traits rather than hardcoding references to css elements or paths.  This makes things more future proof as things change. Rather than needing to change all the hardcoded references in your traits, you can just change the PageObject.
 - I've found that selenium (and even more so phantomjs) are pretty finicky sometimes with locaters.  Sometimes you need to be really explicit about locating an element to interact with.  Sometimes you have to use the `wait` method to explicitly pause a bit to allow a page to completely load (or a js action to complete) before doing a button click.
 - Sometimes it's helpful to take additional screenshots during test execution when debugging things during a test writing session.  You can easily take a screenshot at a specific point in a test by executing `$I->makeScreenshot('slug-for-screenshot')` and the screenshot will show up in the `./tests/_output/debug` folder named (in the case of this example) `slug-for-screenshot.png`.  Super useful!

### Requiring additional WordPress plugins for installation.

For some of your acceptance tests, you may want to install an additional WordPress plugins to aid with testing.  For example the WP Crontrol plugin (wp-crontrol slug) is commonly used  in manual user testing to force trigger a scheduled cron event (or to verify that scheduled cron events exist).  This library has a way of indicating you want certain WordPress plugins installed.

Within the ee-core or ee-add-on `ee-codeception.yml` file, you can indicate all the extra WordPress plugins you want installed like this:

```yaml
external_plugins:
  - wp-crontrol
  - organize-series
```

If you have the path to the public github repository that should work as well.  The plugins will be installed using wp-cli during the test setup process.  These plugins will be NOT be activated by default, so your test process will need to require activating them before relying on them.

### Other

Along with codeception, this tool also utilizes the excellent [WPBrowser](https://github.com/lucatume/wp-browser) module.  Along with helping with the test framework, this module exposes a number of actions you can use in your tests as well, so its recommended you check out those actions.

**XPath Tools**

One of the main ways in which elements and items in the dom can be "navigated" via acceptance tests is via xPath.  I _highly_ recommend installing a browser plugin such as [XPath Helper for Chrome](https://chrome.google.com/webstore/detail/xpath-helper/hgimnogjllphhhkhlmebbmlgjoejdpjl) for discovering the XPath to use for your tests.  There's also an equivalent tool for other browsers.

**Remember** however:

- Watch for dynamically generated strings used in the css (ids etc).  Anything that could vary between tests should not be used.  To help with this you can use xPath functions such as `starts-with` etc to modify the xPath to be better for tests.
- Avoid hardcoding your xPaths in the actual test Cept/Cest.  Instead, use PageObjects (as mentioned above).  That way if the path changes either because a change in WordPress or a change in core, it's easier to update.
- Use the array format for adding the locators as it is [significantly faster](http://codeception.com/docs/modules/WebDriver#locating-elements) and usually more reliable.  

**PHPStorm Users**

I have my Event Espresso Core and add-ons in a separate project than this library.  Without any modification, that setup means I'm not getting the power of PHPStorm auto-completion and code-inspection when writing acceptance tests.  To get around that, just make sure you add the path to wherever you've installed this tool to the php include paths in your EE Core and/or add-ons project.  Just go to preferences, then `Languages & Frameworks > PHP`.  Then click on the `Project Configuration` tab.  Then click on the `+` near the bottom of that screen and browse to the path this tool was installed in.  Then make sure you click the `Apply` button and you should be all set!

## Advanced Usage

### Watching the tests run in a browser.
This library is configured so you can actually _watch_ tests running in a browser as they are being executed.  Aside from being really cool, it is also a great way to watch things running to help debug the tests themselves and ascertain whether in fact there's a problem with the code being tested or the actual test code.

This utilizes a special browser environment (docker container service) already configured and then you'll just need a VNC client on your host machine.  Mac users already have one built-in so you don't have to do anything (yay!).  Since I'm not a Windows user I don't think there's one built-in, but a little googling and you can probably find one to install on your system.  I'll be writing this from the context of a mac user but most of the things here should translate to Windows users.

#### Step One: Execute tests
Instead of just doing `./run-tests.sh` or `./run-tests.sh -e firefox` for a specific browser.  You'll use either `firefoxdebug` or `chromedebug` to start the special service that exposes a port to the host to listen in on for viewing the browser in action.  So for example if you want to watch the tests run in a chrome browser, you'd do this:

```bash
./run-tests.sh -e chromedebug
```
#### Step Two: Start the VNC client.
Mac users, just load up Safari (or you can do it directly in Alfred if you have Alfred installed) and enter this in the address bar:
```
vnc://localhost:5900
```
That should automatically fire up the vnc client and point it at the open port exposed by the docker container running the browser service.
From that point on, you can simply watch the tests in action :)  Nifty!
