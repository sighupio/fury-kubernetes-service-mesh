#!/usr/bin/env bash

# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# You can change this variable to download a different version

VERSION='2.6.5'

# Run the following script to automatically detect the operating system and download Kuma:

curl -L https://kuma.io/installer.sh | VERSION=$VERSION sh -

# You can omit the VERSION variable to install the latest version.

# Add the kumactl executable to your path and cleanup:

cp kuma-${VERSION}/bin/kumactl ./kumactl

rm -rf kuma-${VERSION}
