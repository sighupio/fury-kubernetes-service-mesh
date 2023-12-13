#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load ./../helper

@test "Install istio requirements" {
  info
  test(){
    cd katalog/tests/istio-operator/requirements
    kustomize build . | kubectl apply -f - --server-side
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Wait for istio requirements to be running" {
  info
  test(){
    status=$(kubectl -n monitoring get pods -o jsonpath='{range .items[*].status.conditions[?(@.type=="Ready")]}{.status}{"\n"}{end}' | uniq)
    if [ "${status}" != "True" ]; then return 1; fi
  }
  loop_it test 30 3
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}
