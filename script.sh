#!/bin/bash
# This script is used to run the tests for a single application
# It is called by bash script.sh <repo> <version> <app>
# Example: bash script.sh vue-example 1.0.0 another-app
# This script only works on macOS since it uses AppleScript to open a new terminal window

# https://github.com/tatotux/vue-example.git as example
repo="$1"

# Change to the git repo folder
cd "../$repo"

# Check if the repo is on the master branch
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "master" ]; then
    echo "Warning: Repo $repo is not on the master branch. Skipping..."
    exit 1
fi

# Pull the latest changes from the remote repository
git pull
if [ $? -ne 0 ]; then
    echo "Warning: Failed to pull latest changes for repo $repo. Skipping..."
    exit 1
fi

# Set the version using APPNAME
APPNAME set-version "$2"

current_dir=$(pwd)
osascript -e "tell application \"Terminal\" to do script \"cd \\\"$current_dir\\\" && npm run serve\""

# Wait for the application to start
sleep 15

# Change to the another-app folder
cd "../$3"

# Run the playwright tests
npx playwright test --grep '@appSmoke'

# Kill the application
osascript -e 'tell application "Terminal" to activate' -e 'tell application "System Events" to keystroke "c" using control down' &> /dev/null
osascript -e 'tell application "Terminal" to close first window without saving' &> /dev/null
