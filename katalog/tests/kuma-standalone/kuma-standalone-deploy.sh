#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load ../helper

@test "Install Kuma in standalone mode" {
  info
  deploy(){
    apply katalog/kuma/standalone
  }
  wait_for_it(){
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kuma -n kuma-system --timeout=2m
  }
  run deploy
  run wait_for_it
}
