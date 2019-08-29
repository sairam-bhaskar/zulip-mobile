#!/bin/bash

if [[ "$1" == "stop" ]]; then
    echo Stopping esprint server...
    node_modules/esprint/build/cli.js stop
    exit 0
fi

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

MAX_ERRORS=0
MAX_WARNINGS=184

TMP_OUTPUT=/tmp/esprint_temp_output.txt

if [[ "$BITRISE" == "true" ]]; then
    $SCRIPT_DIR/../node_modules/esprint/build/cli.js check --color=always > $TMP_OUTPUT 2>&1
else
    $SCRIPT_DIR/../node_modules/esprint/build/cli.js --color=always > $TMP_OUTPUT 2>&1
fi

cat $TMP_OUTPUT

OUTPUT=$(cat ${TMP_OUTPUT} | grep "problems" | cut -d "(" -f2 | cut -d ")" -f1 | sed 's/errors//g' | sed 's/warnings//g')

COUNT=($(echo "$OUTPUT" | tr ',' '\n'))

ERRORS="${COUNT[0]}"
WARNINGS="${COUNT[1]}"

EXIT_CODE=0

if (( $ERRORS > $MAX_ERRORS )); then
    echo "Too many errors!"
    EXIT_CODE=$((EXIT_CODE+1))
fi

if (( $WARNINGS > $MAX_WARNINGS)); then
    echo "Too many warnings!"
    EXIT_CODE=$((EXIT_CODE+1))
elif (( $WARNINGS < $MAX_WARNINGS)); then
    echo "Congrats!  You decreased the warnings!  Please update ./devScripts/esprint.sh with the new value!"
    EXIT_CODE=$((EXIT_CODE+1))
fi

exit $EXIT_CODE
