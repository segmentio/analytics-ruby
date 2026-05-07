#!/bin/bash
#
# Run E2E tests for analytics-ruby
#
# Prerequisites: Node.js 18+ and Ruby 2.6+
#
# Usage:
#   ./run-e2e.sh [extra args passed to run-tests.sh]
#
# Override sdk-e2e-tests location:
#   E2E_TESTS_DIR=../my-e2e-tests ./run-e2e.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$SCRIPT_DIR/.."
E2E_DIR="${E2E_TESTS_DIR:-$SDK_ROOT/../sdk-e2e-tests}"

# Resolve ruby — prefer RUBY env var, then system ruby
RUBY="${RUBY:-$(command -v ruby)}"

if [[ -z "$RUBY" ]]; then
    echo "Error: Ruby not found. Install Ruby 2.6+ and ensure it is on PATH."
    exit 1
fi

echo "=== analytics-ruby e2e-cli ==="
echo "Using Ruby: $($RUBY --version)"
echo "SDK root:   $SDK_ROOT"
echo "E2E dir:    $E2E_DIR"
echo ""

# Run tests — the CLI script adds the SDK lib dir to LOAD_PATH itself,
# so no gem build/install step is required.
cd "$E2E_DIR"
./scripts/run-tests.sh \
    --sdk-dir "$SCRIPT_DIR" \
    --cli "$RUBY $SCRIPT_DIR/main.rb" \
    "$@"
