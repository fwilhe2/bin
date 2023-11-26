#!/bin/bash
set -o nounset
set -o errexit

# Based on ideas described in
# https://jmmv.dev/series.html#Shell%20readability

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

hello() {
    local name="${1}"; shift
    local location="${1}"; shift
    echo Hello "$name" greetings to "$location"
}

fail_expected_parameters() {
    echo "Usage: $SCRIPT_NAME Name Location"
    exit 1
}

main() {
    [ ${#} -ne 2 ] && fail_expected_parameters
    local name="${1}"; shift
    local location="${1}"; shift

    hello "$name" "$location"
}

main "${@}"