#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load ./../helper

@test "Setup the required namespace and workloads" {
  info
  setup_environment(){
    kubectl create ns foo
    kubectl create ns bar
    kubectl label namespace foo istio-injection=enabled
    kubectl label namespace bar istio-injection=enabled
    kubectl create ns legacy
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin.yaml -n foo
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin.yaml -n bar
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin.yaml -n legacy
    kubectl apply -f katalog/tests/istio-operator/citadel/sleep.yaml -n foo
    kubectl apply -f katalog/tests/istio-operator/citadel/sleep.yaml -n bar
    kubectl apply -f katalog/tests/istio-operator/citadel/sleep.yaml -n legacy
  }
  run setup_environment
  [ "$status" -eq 0 ]
}

@test "Verify setup by sending an HTTP request" {
  info
  test(){
    for from in "foo" "bar" "legacy"
    do
      for to in "foo" "bar" "legacy"
      do
        pod_name=$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})
        http_code=$(kubectl exec ${pod_name} -c sleep -n ${from} -- curl "http://httpbin.${to}:8000/ip" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "200" ]; then return 1; fi
      done
    done
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}
