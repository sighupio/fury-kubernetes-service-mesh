#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load ../helper

@test "Install Kuma demo" {
  info
  deploy(){
    kubectl apply -f katalog/tests/kuma-standalone/demo.yaml
  }
  wait_for_it(){
    kubectl wait --for=condition=ready pod -l app=demo-app -n kuma-demo --timeout=2m
    kubectl wait --for=condition=ready pod -l app=redis -n kuma-demo --timeout=2m
  }
  run deploy
  run wait_for_it
}

@test "Verify that exactly two Dataplanes are attached" {
  info
  test() {
    [ "$(kubectl get dataplanes -n kuma-demo --no-headers | wc -l)" = "2" ] && exit 0 || exit 1
  }
  run test
}
