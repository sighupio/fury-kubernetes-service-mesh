#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load ./../helper

@test "Globally enabling Istio mutual TLS" {
  info
  set_mtls(){
    kubectl apply -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n istio-system
  }
  run set_mtls
  [ "$status" -eq 0 ]
}

@test "All requests between Istio-services are now completed successfully" {
  info
  test(){
    for from in "foo" "bar"
    do
      for to in "foo" "bar"
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

@test "Request from non-Istio services to Istio services" {
  # https://istio.io/docs/tasks/security/authentication/authn-policy/#request-from-non-istio-services-to-istio-services
  info
  test(){
    from="legacy"
    for to in "foo" "bar"
    do
      pod_name=$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})
      http_code=$(kubectl exec ${pod_name} -c sleep -n ${from} -- curl "http://httpbin.${to}:8000/ip" -s -o /dev/null -w "%{http_code}")
      if [ "${http_code}" -ne "000" ]; then return 1; fi
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "Back to default citadel behavior" {
  info
  setup_environment(){
    kubectl delete -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n istio-system
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
