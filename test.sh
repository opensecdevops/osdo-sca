#!/bin/bash
# Test script for osdo-sca action
# Tests dependency scanning with various scenarios

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Testing osdo-sca Action"
echo "================================"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name=$1
    local expected_result=$2
    TESTS_RUN=$((TESTS_RUN + 1))
    
    echo ""
    echo "Test $TESTS_RUN: $test_name"
    echo "----------------------------"
    
    if [ "$expected_result" = "fail" ]; then
        if ! eval "$3"; then
            echo -e "${GREEN}✓ Test passed (expected vulnerabilities)${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ Test failed${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if eval "$3"; then
            echo -e "${GREEN}✓ Test passed${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ Test failed${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test 1: Clean npm project
mkdir -p "$TEST_DIR/clean-npm"
cat > "$TEST_DIR/clean-npm/package.json" << 'EOF'
{
  "name": "clean-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

run_test "Clean npm project should pass" "pass" "
    cd $TEST_DIR/clean-npm && \
    npm install --silent 2>&1 > /dev/null && \
    npm audit --json > audit.json && \
    [ \$(jq '.metadata.vulnerabilities.total' audit.json) -eq 0 ]
"

# Test 2: Vulnerable Python dependencies
mkdir -p "$TEST_DIR/vuln-python"
cat > "$TEST_DIR/vuln-python/requirements.txt" << 'EOF'
Django==2.2.0
requests==2.20.0
EOF

run_test "Vulnerable Python deps should be detected" "fail" "
    cd $TEST_DIR/vuln-python && \
    pip-audit --disable-pip -r requirements.txt --format json > audit.json 2>&1 && \
    [ \$(jq '.vulnerabilities | length' audit.json 2>/dev/null || echo 0) -eq 0 ]
"

# Test 3: Go module with vulnerabilities
mkdir -p "$TEST_DIR/vuln-go"
cat > "$TEST_DIR/vuln-go/go.mod" << 'EOF'
module example.com/app

go 1.20

require (
    github.com/gin-gonic/gin v1.6.0
)
EOF

run_test "Vulnerable Go modules should be detected" "fail" "
    cd $TEST_DIR/vuln-go && \
    govulncheck -json ./... > vulns.json 2>&1 && \
    [ \$(jq '.Vulns | length' vulns.json 2>/dev/null || echo 0) -eq 0 ]
"

# Summary
echo ""
echo "================================"
echo "Test Summary"
echo "================================"
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
