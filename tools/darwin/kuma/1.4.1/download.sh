#!/usr/bin/env bash

VERSION=$(basename "$PWD")

curl -L https://download.konghq.com/mesh-alpine/kuma-${VERSION}-darwin-amd64.tar.gz | tar xz

cp kuma-${VERSION}/bin/kumactl ./kumactl

rm -rf kuma-${VERSION}