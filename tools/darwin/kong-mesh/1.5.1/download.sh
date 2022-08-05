#!/usr/bin/env bash

VERSION=$(basename "$PWD")

curl -L https://download.konghq.com/mesh-alpine/kong-mesh-${VERSION}-darwin-amd64.tar.gz | tar xz

cp kong-mesh-${VERSION}/bin/kumactl ./kumactl

rm -rf kong-mesh-${VERSION}