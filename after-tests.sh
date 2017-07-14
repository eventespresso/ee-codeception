#!/usr/bin/env bash

cd ${PROJECT_ROOT}/tests/

artifacts upload --target-paths "artifacts/ee-codeception/${TRAVIS_BUILD_ID}/${TRAVIS_JOB_ID}" _output

cd ${PROJECT_ROOT}