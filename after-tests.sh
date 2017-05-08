#!/usr/bin/env bash

cd ${PROJECT_ROOT}/tests/
if [ -d "_output/debug" ]; then
    SOURCE_DIRECTORIES="_output _output/debug/"
else
    SOURCE_DIRECTORIES="_output"
fi

artifacts upload --target-paths "artifacts/ee-codeception/${TRAVIS_BUILD_ID}/${TRAVIS_JOB_ID}" ${SOURCE_DIRECTORIES}