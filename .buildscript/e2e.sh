#!/bin/sh

set -ex

if [ "$RUN_E2E_TESTS" != "true" ]; then
  echo "Skipping end to end tests."
else
  echo "Running end to end tests..."
  wget -q https://github.com/segmentio/library-e2e-tester/releases/download/0.4.0/tester_linux_amd64 -O tester
  chmod +x tester
  ./tester -path='./bin/analytics'
  echo "End to end tests completed!"
fi
