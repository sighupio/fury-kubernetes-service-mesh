#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

# Check if kustomization.yaml already exists
if [ -f "kustomization.yaml" ]; then
    echo "kustomization.yaml already exists. Skipping generation."
    exit 0
fi

# Read the environment variable or use 'main' as the default if it's not set
CERT_MANAGER_VERSION=${CERT_MANAGER_VERSION:-main}

echo "Generating kustomization.yaml for cert-manager version: ${CERT_MANAGER_VERSION}"

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: cert-manager
resources:
  - https://github.com/sighupio/fury-kubernetes-ingress.git//katalog/cert-manager?ref=${CERT_MANAGER_VERSION}

patchesStrategicMerge:
  - |
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: cert-manager
      namespace: cert-manager
    \$patch: delete

EOF

echo "kustomization.yaml has been generated."
