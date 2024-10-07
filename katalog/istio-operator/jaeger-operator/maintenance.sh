#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

# Initial setup: Specify the version of Jaeger Operator you wish to download
JAEGER_VERSION="v1.61.0"  # Update this according to the version you need

# Create the main directory for Jaeger Operator
mkdir -p jaeger-operator/resources
cd jaeger-operator || exit  # Exit if change directory fails

echo "Downloading Jaeger Operator version $JAEGER_VERSION..."
curl -L "https://github.com/jaegertracing/jaeger-operator/releases/download/${JAEGER_VERSION}/jaeger-operator.yaml" -o jaeger-operator.yaml
echo "Download completed."

# Check if kubectl-slice is installed
if ! command -v kubectl-slice &> /dev/null
then
    echo "kubectl-slice is not installed. Please install it from https://github.com/patrickdappollonio/kubectl-slice"
    echo "Installation can be done via Go with: GO111MODULE=on go get github.com/patrickdappollonio/kubectl-slice@latest"
    exit 1  # Exit if kubectl-slice is not installed
fi

# Split the YAML file into individual documents
echo "Splitting the YAML file..."
kubectl-slice -f jaeger-operator.yaml --output-dir ./resources
echo "Files split and stored in ./resources folder."

# Creating kustomization.yaml file
echo "Creating kustomization.yaml file..."
cat <<EOF >kustomization.yaml
resources:
$(find resources -type f | sed 's/^/- /')
EOF

# Final build with Kustomize
echo "Building final configuration with Kustomize..."
kustomize build . > ../upstream.yaml
echo "Build completed. The 'upstream.yaml' file is ready for use and located in the parent directory."

# Delete the downloaded Jaeger Operator YAML file
echo "Deleting the downloaded Jaeger Operator YAML file..."
rm jaeger-operator.yaml
echo "File deleted."

# Navigate back to the original directory
cd .. || exit  # Handle cd failure
