#!/usr/bin/env bash

# the git ref gets passed in as the only argument
ref="$1"

# pretend we're running tests
echo "running tests"

# only deploy if we're on the main branch
[[ "$ref" == "refs/heads/main" ]] && echo "Deploying"
