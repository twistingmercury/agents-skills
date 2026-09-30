#!/usr/bin/env bash

set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SCRIPTS}/.." && pwd)}"

# shellcheck source=../lib/print.sh disable=SC1091
. "${PROJ_ROOT}/lib/print.sh"

main(){
    print::info "Starting agent installation from ${PROJ_ROOT}"

    print::info "Step 1/3: Installing agent definitions..."
    if ! "${SCRIPTS}/01_install_agents.sh"; then
        print::error "Failed to install agent definitions"
        return 1
    fi

    print::info "Step 2/3: Installing rules..."
    if ! "${SCRIPTS}/02_install_rules.sh"; then
        print::error "Failed to install rules"
        return 2
    fi

    print::info "Step 3/3: Installing skills..."
    if ! "${SCRIPTS}/03_install_skills.sh"; then
        print::error "Failed to install skills"
        return 3
    fi

    print::success "Installation completed"
    return 0
}

main
