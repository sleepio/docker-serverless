#!/bin/bash

if [[ $@ = *"--no-publish"* ]]; then export NO_PUBLISH=true; else export NO_PUBLISH=false; fi

/usr/local/bin/serverless $@
