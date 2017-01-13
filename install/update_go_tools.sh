#!/bin/bash

function install_tool {
    local TOOL="${1}"
    local VERSION="${2}"
    local URL="https://releases.hashicorp.com/${TOOL}/${VERSION}/${TOOL}_${VERSION}_linux_amd64.zip"
    echo "${URL}"
    curl "${URL}" > "${TMPDIR}/${TOOL}.zip" 2> /dev/null
    unzip "${TMPDIR}/${TOOL}.zip" -d "${TMPDIR}"
    mv "${TMPDIR}/${TOOL}" "${BINDIR}/${TOOL}_${VERSION}"
    cd "${BINDIR}"
    ln -sf "${TOOL}_${VERSION}" "${TOOL}"
    #rm "${TMPDIR}/${TOOL}.zip"
}

function get_last {
    local REPO="${1}"
    echo VERSION "$(git ls-remote --tags "${REPO}" | sort -t '/' -k 3 -V | tail -n 1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"
    return 
}

TMPDIR=$(mktemp -d)

if [ ! -d "bin" ]; then
    mkdir bin
fi
BINDIR="$(pwd)/bin"
OLD_PATH="${PATH}"
PATH="${PATH}:$(pwd)/bin"

if [ ! -f "${BINDIR}/packer" ]; then
    VERSION="$(git ls-remote --tags https://github.com/mitchellh/packer/ | sort -t '/' -k 3 -V | tail -n 1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"
    install_tool packer "${VERSION}" 
else 
    VERSION_PATTERN="[0-9]\.[0-9]+\.[0-9]+"
    packer --version | grep "You can update"
    if [ $? == "0" ]; then
        VERSION=$(packer --version | egrep "${VERSION_PATTERN}" -o | tail -n 1)
        echo "Update to ${VERSION} [Y|n]?"
        read should_update
        if [ "$should_update" == "y" ]; then
            install_tool packer "${VERSION}"
        fi
    else
        echo "packer is already the latest version"
    fi
fi

if [ ! -f "${BINDIR}/terraform" ]; then
    VERSION="$(git ls-remote --tags https://github.com/hashicorp/terraform/ | sort -t '/' -k 3 -V | tail -n 1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"
    install_tool terraform "${VERSION}"
else 
    VERSION_PATTERN="[0-9]\.[0-9]+\.[0-9]+"
    terraform --version | grep "You can update"
    if [ ! -f "${BINDIR}/terraform" ] || [ $? == "0" ]; then
        VERSION=$(terraform --version | egrep "${VERSION_PATTERN}" -o | tail -n 1)
        echo "Update to ${VERSION} [Y|n]?"
        read should_update
        if [ "$should_update" == "y" ]; then
            install_tool terraform "${VERSION}"
        fi
    else
        echo "Terraform is already the latest version"
    fi
fi

#rmdir "${TMPDIR}"
PATH="${OLD_PATH}"
