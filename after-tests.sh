#!/usr/bin/env bash

cd ./tests/

artifacts upload --target-paths "artifacts/ee-codeception/${TRAVIS_BUILD_ID}/${TRAVIS_JOB_ID}" _output

cd ../