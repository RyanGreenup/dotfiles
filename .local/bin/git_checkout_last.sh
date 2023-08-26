#!/bin/bash

# Use the git rev-parse command to get the hash of the second latest commit
echo 'git rev-parse HEAD~1'
git rev-parse HEAD~1
