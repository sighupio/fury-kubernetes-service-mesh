#!/bin/bash

# This script installs the kapp CLI into the local-bin/ directory.

echo "Preparing to install kapp CLI..."

# Define the kapp version
KAPP_VERSION="v0.62.0"
echo "kapp version set to: ${KAPP_VERSION}"

# Ensure the local-bin directory exists
mkdir -p local-bin/
echo "Ensured local-bin/ directory exists for installation."

# Check if kapp is already installed
if [ -f "local-bin/kapp" ]; then
    echo "kapp is already installed."
    exit 0
fi

# Determine OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)
echo "Detected operating system: ${OS}"
echo "Detected architecture: ${ARCH}"

# Prepare the download URL based on OS and architecture
URL=""
case "${OS}" in
    Linux|Darwin)
        case "${ARCH}" in
            x86_64|amd64) SUFFIX="amd64" ;;
            arm|arm64) SUFFIX="arm64" ;;
            *) echo "Architecture ${ARCH} is not supported."; exit 1 ;;
        esac
        URL="https://github.com/carvel-dev/kapp/releases/download/${KAPP_VERSION}/kapp-${OS}-${SUFFIX}"
        ;;
    *)
        echo "Operating system ${OS} is not supported."; exit 1 ;;
esac

# Download and setup kapp
echo "Downloading kapp from ${URL}..."
wget -q ${URL} -O local-bin/kapp
if [ $? -eq 0 ]; then
    chmod +x local-bin/kapp
    echo "kapp has been successfully installed to local-bin/kapp."
else
    echo "Failed to download kapp."
    exit 1
fi
