# EE Codeception Library
[![Travis](https://travis-ci.org/eventespresso/ee-codeception.svg?branch=master)](https://travis-ci.org/eventespresso/ee-codeception)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)
[![By Event Espresso](https://img.shields.io/badge/For-Event%20Espresso-blue.svg)](https://github.com/eventespresso/event-espresso-core)

This utility tool is used by [Event Espresso](https://github.com/event-espresso/event-espresso-core) for executing acceptance tests utilizing the [Codeception](http://codeception.com/) library.  

The package can be installed locally and used to run acceptance tests but its primary purpose is for nightly triggered runs of tests via travis (triggered by a server installation of the [automated nightly builds script](https://github.com/eventespresso/ee-addon-circle-nightly))

## Local Installation

**1. Clone this package locally:**
```bash
git clone https://github.com/eventespresso/ee-codeception.git
```
**2. Run `composer install`**

**3. Make sure you have [phantomjs](https://github.com/ariya/phantomjs/) installed on your machine**

**4. Create a `codeception.yml` file and modify to suit your environment.**

This tool is distributed with a `codeception.dist.yml` file that contains all the main settings.  However you will need to modify the DB username and DB password for the (mysql or mariadb) database available for the tests. So just copy all the contents of `codeception.dist.yml` into a `codeception.yml` file in the same path, then modify the relevant configuration items in the file.  

The only items you should *need* to change are `modules.config.WPDb.user` and `modules.config.WPDb.password`.  However, if your database is accessed on something other than `localhost` you'll need to modify that in `modules.config.WPDb.dsn` as well. 

## Usage

To run tests you just need to run this within the root path of the tool:

```
./run-locally.sh
```

However, there are some other arguments you can use with this script to adjust the way tests are setup:

| Argument |   Usage                                                                                                                                                                      | Description                                                                                                                                                                                                                                      |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-h`     |   `./run-locally.sh -h`                                                                                                                                                     | Will output options for what can be used with this command.                                                                                                                                                                                      |
| `-b`     |   `./run-locally.sh -b FET-1234-some-ee-core-branch`                                                                                                                        | This allows you to indicate what branch of EE core you want to be used for tests.                                                                                                                                                                |
| `-t`     |   `./run-locally.sh -t 4.8.36.p                                                   `                                                                                         | This is used to indicate what _tag_ of EE core you want the tests run against. Make sure you use a tag that is not the release tag (with all tests folders removed)                                                                              |
| `-a`     |   `./run-locally.sh -a eea-people-addon                                                                                  `                                                  | This is used to indicate what add-on you want to run acceptance tests for.  You can use this in combination with `-b` to run the add-on against a specific version of EE core. When this flag is used, EE core acceptance tests are not executed.|
| `-s`     |   `./run-locally.sh -s                                                                                                                         `                            | When you want to rebuild your tests from scratch, use this flag.                                                                                                                                                                                 |
| `-f` | `./run-locally.sh -f ActivationCept.php` | When you want to just run a specific acceptance test in the `tests/acceptance` folder.

## What happens under the hood

When tests are triggered, this tool does the following:
* Starts a PHP webserver at `127.0.0.1:8888` and points it to `tests/tmp/wp` folder.
* Starts `phantomjs`
* Installs the latest version of WordPress and configures it live at `http://127.0.0.1:8888` (so it will be accessible for headless browser testing)
* Retrieves and installs the requested branch/tag of Event Espresso core (defaults to master if none is specified).
* Install an Event Espresso add-on (if requested).
* Copies acceptance tests from the `acceptance_tests/tests` folder of Event Espresso core if no EE add-on was installed or the add-on if that was requested.  These tests are copied into the codeception `tests/acceptance` folder.
* Copies any Page objects from the `acceptance_tests/Page` folder of Event Espresso core _and_ the EE add-on (if installed) into `tests/_support/Page` folder of ee-codeception.
* copies any `Helper` traits from the `acceptance_tests/Helpers` folder of Event Espresso core _and_ the EE add-on (if installed) into `src/helpers`
* Executes `vendor/bin/codecept build` to build any fixtures/code needed for running the tests.
* Runs the `build_ee` command with any `ee-codeception.yml` file found in either the `event-espresso-core/acceptance_tests` or the installed EE addon. 
* Installs any additional requested WordPress plugins indicated in the `ee-codeception.yml` file.
* Runs the acceptance tests.
* Stops the PHP webserver and `phantomjs`

So basically this takes care of a lot for you!

## Writing tests

Of course the main purpose of this tool is for easily writing acceptance tests.  We've taken the approach for this tool where instead of writing the tests and adding them to this repository.  This tool provides the framework for writing the tests but the actual tests `*Cept` or `*Cest` should be written and added to the `acceptance_tests` folder within the plugin add-on you are writing the tests for.  This allows for keeping tests specific to the version of the plugin the tests were written for.

However, in this tool will be found the following classes that you should use when writing your tests:

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

Note each custom actor class also by default imports its relevant helper trait.  For `EventEspressoAcceptanceTester` the `EventEspresso\Codeception\helpers\CoreAggregate` trait is imported, and for `EventEspressoAddonAcceptanceTester` the `EventEspresso\Codeception\helpers\AddonAggregate` trait is imported.  These are special generated traits that allow us to have helper traits defined in their associated repository which makes acceptance tests more version aware.

For this reason, _most_ custom actor actions should be built in a helper trait and not in these actors.

### PageObjects

One thing we're striving to do with this tool is to describe all routes/elements etc for the tests via [PageObjects](http://codeception.com/docs/06-ReusingTestCode#pageobjects).  Currently there are _none_ available, however this will change as we begin writing tests and create PageObjects for use.  So whenever possible, use a PageObject to keep your tests dry so if we tweak element location etc in an add-on or EE core, we just have to change the related fixtures in the `PageObject` class(es) and tests should "just work".

As it is with the actual test case classes (`*Cept` or `*Cest`), PageObjects should live with the repository they are built for.  So for example PageObjects for Event Espresso Core would live in the `acceptance_tests/Page` folder and they are copied from there when this tool builds the tests suite. 

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

For helper traits added to add-ons.  Then the yaml entry would be a bit different.  So for example if we had `PeopleAdmin` and `PeopleFrontend` traits in `eea-people-addon/acceptance_tests/Helpers`, then in the `eea-people-addon/acceptance_tests/ee-codeception.yml` file we'd have something like this:

```yaml
addon:
  - PeopleAdmin
  - PeopleFrontend
```

> **Note:** the yaml files do **not** need the fully qualified class name for the entry.  Only the trait name is needed.  However, that's why its important you declare the correct namespace in the file containing the trait.

#### Some general best practices to follow:
- Keep your traits simple and specific to what they are for (eg all EventAdmin related actions could go in a `EventAdmin` trait).
- As much as possible use `PageObjects` in your traits rather than hardcoding references to css elements or paths.  This makes things more future proof as things change. Rather than needing to change all the hardcoded references in your traits, you can just change the PageObject.

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
- Use the array format for adding your locator's as it is [significantly faster](http://codeception.com/docs/modules/WebDriver#locating-elements).  

**PHPStorm Users**

I have my Event Espresso Core and add-ons in a separate project than this library.  Without any modification, that setup means I'm not getting the power of PHPStorm auto-completion and code-inspection when writing acceptance tests.  To get around that, just make sure you add the path to wherever you've installed this tool to the php include paths in your EE Core and/or add-ons project.  Just go to preferences, then `Languages & Frameworks > PHP`.  Then click on the `Project Configuration` tab.  Then click on the `+` near the bottom of that screen and browse to the path this tool was installed in.  Then make sure you click the `Apply` button and you should be all set!
