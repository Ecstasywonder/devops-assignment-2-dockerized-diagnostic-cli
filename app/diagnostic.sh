#!/usr/bin/env bash

# DevOps Assignment 2
# Dockerized Linux Diagnostic CLI

set -uo pipefail

show_help() {
    cat <<'HELP'
========================================
       LINUX DIAGNOSTIC CLI
========================================

Usage:
  diagnostic <command> [arguments]

Commands:
  system           Display Linux system information
  network <host>   Check host resolution and connectivity
  disk             Display filesystem disk information
  help             Display this help message

Exit Codes:
  0   Success
  1   Operational failure
  2   Invalid command or input

Examples:
  diagnostic system
  diagnostic network localhost
  diagnostic disk
  diagnostic help
HELP
}

show_system() {
    echo "========================================"
    echo "          SYSTEM INFORMATION"
    echo "========================================"

    printf 'Hostname         : %s\n' "$(hostname)"
    printf 'Current User     : %s\n' "$(id -un)"
    printf 'Date/Time        : %s\n' "$(date)"
    printf 'Kernel Version   : %s\n' "$(uname -r)"
    printf 'Uptime           : %s\n' "$(uptime -p 2>/dev/null || uptime)"

    if [[ -r /etc/os-release ]]; then
        (
            . /etc/os-release
            printf 'Operating System : %s\n' "${PRETTY_NAME:-Unknown}"
        )
    fi

    echo
    echo "CPU Information:"
    if command -v nproc >/dev/null 2>&1; then
        printf 'CPU Cores: %s\n' "$(nproc)"
    else
        echo "CPU information unavailable"
    fi

    echo
    echo "Memory Information:"
    free -h || return 1

    echo "========================================"
}

show_disk() {
    echo "========================================"
    echo "           DISK INFORMATION"
    echo "========================================"

    df -h || {
        echo "ERROR: Unable to retrieve disk usage." >&2
        return 1
    }

    echo "========================================"
}

check_network() {
    local host="$1"
    local resolved=""

    if [[ -z "$host" ||
          "$host" == -* ||
          "$host" =~ [[:space:]] ||
          ! "$host" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
        echo "ERROR: Invalid hostname or IP address." >&2
        return 2
    fi

    echo "========================================"
    echo "           NETWORK CHECK"
    echo "========================================"

    echo "Target Host: $host"

    resolved=$(timeout 5 getent ahosts "$host" |
        awk 'NR==1 {print $1}')

    if [[ -z "$resolved" ]]; then
        echo "ERROR: Unable to resolve host: $host" >&2
        return 1
    fi

    echo "Resolved IP: $resolved"

    if timeout 5 ping -c 1 -W 2 "$resolved" >/dev/null 2>&1; then
        echo "Connectivity: SUCCESS"
        return 0
    else
        echo "Connectivity: FAILED or ICMP blocked"
        return 1
    fi
}

main() {
    if (( $# == 0 )); then
        echo "ERROR: No command supplied." >&2
        show_help >&2
        return 2
    fi

    local command="$1"
    shift

    case "$command" in
        help)
            if (( $# != 0 )); then
                echo "ERROR: help accepts no arguments." >&2
                return 2
            fi
            show_help
            ;;
        system)
            if (( $# != 0 )); then
                echo "ERROR: system accepts no arguments." >&2
                return 2
            fi
            show_system
            ;;
        disk)
            if (( $# != 0 )); then
                echo "ERROR: disk accepts no arguments." >&2
                return 2
            fi
            show_disk
            ;;
        network)
            if (( $# != 1 )); then
                echo "ERROR: network requires one hostname or IP." >&2
                return 2
            fi
            check_network "$1"
            ;;
        *)
            echo "ERROR: Unknown command: $command" >&2
            show_help >&2
            return 2
            ;;
    esac
}

main "$@"
