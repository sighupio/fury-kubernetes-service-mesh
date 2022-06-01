#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load ./../helper

@test "back to default citadel behavior" {
  info
  setup_environment(){
    kubectl apply -f katalog/tests/istio-operator/citadel/no-mtls.yaml
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
