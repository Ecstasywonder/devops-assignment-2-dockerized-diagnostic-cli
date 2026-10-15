#!/usr/bin/env bash

# DevOps Assignment 2
# Health check for the diagnostic CLI

set -uo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTIC="${APP_DIR}/diagnostic.sh"

if [[ ! -x "$DIAGNOSTIC" ]]; then
    echo "UNHEALTHY: diagnostic CLI is missing or not executable" >&2
    exit 1
fi

if "$DIAGNOSTIC" help >/dev/null 2>&1; then
    echo "HEALTHY: diagnostic CLI is operational"
    exit 0
else
    echo "UNHEALTHY: diagnostic CLI health check failed" >&2
    exit 1
fi
