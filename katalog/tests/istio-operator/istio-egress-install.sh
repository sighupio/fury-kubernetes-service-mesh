#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load ./../helper

@test "Install istio egress-gateway (minimal) package" {
  info
  test(){
    apply examples/istio-operator/enable-egress-gateway
  }
  run test
  [ "$status" -eq 0 ]
}
