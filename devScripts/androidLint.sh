#!/bin/bash
    
echo "Checking Android Lint..."

SCRIPT_DIR="
$( cd "$( dirname "$0" )" && pwd )"

cd $SCRIPT_DIR/../

cd android

./gradlew lintDevDebug
