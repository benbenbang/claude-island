#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "SwiftLint skipped: macOS is required."
    exit 0
fi

if [[ "$#" -eq 0 ]]; then
    echo "SwiftLint skipped: no Swift files to lint."
    exit 0
fi

swiftlint_bin="$(command -v swiftlint || true)"

if [[ -z "${swiftlint_bin}" ]]; then
    for candidate in /opt/homebrew/bin/swiftlint /usr/local/bin/swiftlint; do
        if [[ -x "${candidate}" ]]; then
            swiftlint_bin="${candidate}"
            break
        fi
    done
fi

if [[ -z "${swiftlint_bin}" ]]; then
    echo "SwiftLint is required on macOS. Install it with: brew install swiftlint" >&2
    exit 1
fi

exec "${swiftlint_bin}" lint --force-exclude --no-cache "$@"
