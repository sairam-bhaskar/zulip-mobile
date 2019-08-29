#!/bin/bash

if [ -z ${BITRISE_PULL_REQUEST+x} ]; then
    yarn esprint && yarn testWithCoverage && yarn androidLint
else
    set -ev

    if [[ "$BITRISE_PULL_REQUEST" = "false" ]]; then
        echo "Skipped, this is only done for pull requests."
        exit 0
    fi

    if (( $TEST_JSON_LINT > 0 )); then
        if [[ -z "$JSON_FILES_CHANGED" ]]; then
            echo "No JSON files changed!"
        else
            for f in $JSON_FILES_CHANGED
            do
              [ -f "$f" ] || break
              filename=$(basename "$f")
              extension="${filename##*.}"
              echo "JSON extension: $extension"
              if ["$extension" != "enc"]; then
                if [ -e $f ]; then
                    echo "zin Linting $f"
                else
                    echo "File does not exist: $f"
                fi
              fi
            done
        fi
    fi

    if (( $JAVASCRIPT_FILES_CHANGED_COUNT == 0 )); then
        echo "No javascript files changed!"
    else
        if (( $TEST_ESLINT_CHECKS > 0 )); then
            yarn esprint
        fi

        if (( $TEST_UNIT_TEST_COVERAGE > 0 )); then
            yarn testWithCoverage
        fi

        if (( $TEST_FLOW_CHECKS > 0 )); then
            echo "zin flow check"
        fi

        if (( $TEST_NO_CIRCULAR_CHECKS > 0 )); then
            echo "zin circular check"
        fi
    fi

    if [[ ! -z "$ANDROID_FILES_CHANGED" ]];  then
            yarn androidLint
    fi

    set +ev
fi
