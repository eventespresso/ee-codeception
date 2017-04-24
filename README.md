# EE Codeception Test Suite
========

> Note: this is still being developed so its likely it will NOT work in its current state.

This is the codeception test suite for EE that does the following:

- install WP and EE core as a part of this test setup when run.
- copies over any acceptance tests from the `acceptance_tests` folder into the `/tests/acceptance` folder in this repo
- builds and runs codeception acceptance tests.