sed <.circleci/results.xml "s%_TIMESTAMP_STRING_%$(date -Iseconds|sed s%[+-][0-9][0-9]:[0-9][0-9]$%%)%" >test-results/snyk/results.xml
