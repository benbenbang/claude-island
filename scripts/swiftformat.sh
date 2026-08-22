#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "SwiftFormat skipped: macOS is required."
    exit 0
fi

if [[ "$#" -eq 0 ]]; then
    echo "SwiftFormat skipped: no Swift files to format."
    exit 0
fi

repo_root="$(git rev-parse --show-toplevel)"
config_path="${repo_root}/.swiftformat"

if [[ ! -f "${config_path}" ]]; then
    echo "SwiftFormat configuration not found: ${config_path}" >&2
    exit 1
fi

swiftformat_bin="$(command -v swiftformat || true)"

if [[ -z "${swiftformat_bin}" ]]; then
    for candidate in /opt/homebrew/bin/swiftformat /usr/local/bin/swiftformat; do
        if [[ -x "${candidate}" ]]; then
            swiftformat_bin="${candidate}"
            break
        fi
    done
fi

if [[ -z "${swiftformat_bin}" ]]; then
    echo "SwiftFormat is required on macOS. Install it with: brew install swiftformat" >&2
    exit 1
fi

exec "${swiftformat_bin}" --config "${config_path}" "$@"
