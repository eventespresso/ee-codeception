# EE Codeception Test Suite

> Note: this is still being developed so its likely it will NOT work in its current state.

This is the codeception test suite for EE that does the following:

- install WP and EE core as a part of this test setup when run.
- copies over any acceptance tests from the `acceptance_tests` folder into the `/tests/acceptance` folder in this repo
- builds and runs codeception acceptance tests.

## Requirements

- Most of what you need will be setup by just running `composer install`.
- phantom.js will need installed on your machine and exposed for codeception to use when running tests.

## Running locally

See [requirements](#requirements)

A script has been exposed to enable running locally easier.  To use:

```bash
sh run-locally.sh
```

There is the ability to change what branch/tag of EE core is being used for the tests and/or include any acceptance tests
from an add-on package.  To see what options you have:

```bash
sh run-locally.sh -h
```
