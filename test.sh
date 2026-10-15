#!/usr/bin/env bash

# DevOps Assignment 2
# Automated tests for the Dockerized Diagnostic CLI

set -uo pipefail

IMAGE="assignment2-diagnostic-test:local"
PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

run_test() {
    local name="$1"
    local expected="$2"
    shift 2

    local output
    local actual

    output=$("$@" 2>&1)
    actual=$?

    if [[ "$actual" -eq "$expected" ]]; then
        pass "$name (exit $actual)"
    else
        fail "$name (expected $expected, got $actual)"
        echo "$output"
    fi
}

echo "======================================"
echo " Assignment 2 - Automated Test Suite"
echo "======================================"

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon unavailable" >&2
    exit 1
fi

echo "Building test image..."

if ! docker build -t "$IMAGE" .; then
    echo "ERROR: Docker image build failed" >&2
    exit 1
fi

echo
echo "Running container tests..."

run_test "Help command" 0 \
    docker run --rm "$IMAGE" help

run_test "System information" 0 \
    docker run --rm "$IMAGE" system

run_test "Disk information" 0 \
    docker run --rm "$IMAGE" disk

run_test "Invalid command" 2 \
    docker run --rm "$IMAGE" invalid-command

run_test "Missing command" 2 \
    docker run --rm --entrypoint /bin/bash \
    "$IMAGE" /opt/diagnostic/diagnostic.sh

run_test "Network missing host" 2 \
    docker run --rm "$IMAGE" network

run_test "Network invalid hostname" 2 \
    docker run --rm "$IMAGE" network "invalid host"

run_test "Network localhost" 0 \
    docker run --rm "$IMAGE" network localhost

run_test "Application health check" 0 \
    docker run --rm \
    --entrypoint /opt/diagnostic/health-check.sh \
    "$IMAGE"

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

if (( FAIL == 0 )); then
    exit 0
else
    exit 1
fi
