sed <.circleci/failure_results.xml "s%_TIMESTAMP_STRING_%$(date -Iseconds|sed s%[+-][0-9][0-9]:[0-9][0-9]$%%)%" | \
    sed "s%_FAILURE_STRING_%$(jq <test-results/snyk/results.json .summary)%" \
    > test-results/snyk/results.xml

