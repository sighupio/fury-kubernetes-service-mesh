#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load ./../helper

@test "deploy bookinfo demo application" {
  info
  deploy(){
    kubectl create ns demo
    kubectl label namespace demo istio-injection=enabled
    if [ "$(kubectl apply -f katalog/tests/istio-operator/bookinfo/bookinfo.yaml -n demo)" -ne 0 ]
    then
        return 1
    fi
    if [ "$(kubectl apply -f katalog/tests/istio-operator/bookinfo/bookinfo-gateway.yaml -n demo)" -ne 0 ]
    then
        return 1
    fi
    if [ "$(kubectl apply -f katalog/tests/istio-operator/bookinfo/destination-rule-all.yaml -n demo)" -ne 0 ]
    then
        return 1
    fi
    if [ "$(kubectl apply -f katalog/tests/istio-operator/bookinfo/virtual-service-all-v1.yaml -n demo)" -ne 0 ]
    then
        return 1
    fi
  }
  wait_for_it() {
    retry_counter=0
    max_retry=50
    while kubectl get pods -n demo | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\|PodInitializing\|Init:\)" >&2
    do
      [ $retry_counter -lt $max_retry ] || ( kubectl describe all -n demo >&2 && return 1 )
      sleep 2 && echo "# waiting..." $retry_counter >&3
      retry_counter=$(( retry_counter + 1 ))
    done
    # Wait for productpage review endpoint
    retry_counter=0
    max_retry=10
    while curl -s localhost:${HTTP_PORT}/productpage |grep "Error fetching product reviews!"  >&2
    do
      [ $retry_counter -lt $max_retry ] || ( kubectl describe all -n demo >&2 && return 1 )
      sleep 2 && echo "# waiting..." $retry_counter >&3
      retry_counter=$(( retry_counter + 1 ))
    done
  }
  run deploy
  [ "$status" -eq 0 ]
  run wait_for_it
  [ "$status" -eq 0 ]
}

@test "test v1 bookinfo demo application" {
  info
  test_back_stars(){
    curl -s localhost:${HTTP_PORT}/productpage |grep -q 'color="black"'
  }
  run test_back_stars
  back_stars_result=$status
  test_red_stars(){
    curl -s localhost:${HTTP_PORT}/productpage |grep -q 'color="red"'
  }
  run test_red_stars
  red_stars_result=$status
  [ "$back_stars_result" -eq 1 ] && [ "$red_stars_result" -eq 1 ]
}

@test "deploy v2 for jason and v3 for the rest in bookinfo demo application" {
  info
  test(){
    kubectl apply -f katalog/tests/istio-operator/bookinfo/virtual-service-reviews-jason-v2-v3.yaml -n demo
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v2 for jason in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=50
    ko=1
    while [[ ko -eq 1 ]]
    do
        echo -n ">>>>>>>>>>>>>> INSTANCE_IP is: localhost:${HTTP_PORT}" >&3
        if [ $retry_counter -ge $max_retry ]; then echo -n "Timeout waiting a condition" >&3; curl -s localhost:${HTTP_PORT}/productpage >&2; return 1; fi
        rm -rf ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt
        curl -s -L -c ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt -d "username=jason" -d "passwd=jason" http://localhost:${HTTP_PORT}/login
        output=$(curl -s -b ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt localhost:${HTTP_PORT}/productpage )
        curl -s -b ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt localhost:${HTTP_PORT}/productpage |grep -q 'color="black"'
        ko=$?
        sleep 3 && echo -n "# waiting..." $retry_counter >&3
        kubectl_output=$(kubectl get po -A; kubectl get svc -A; kubectl get gateway -A; kubectl describe po -l app=istio-ingressgateway -n istio-system)
        echo -n "current resources are: $kubectl_output" >&3
        retry_counter=$((retry_counter + 1))
        echo -n ">>> Current response is: $output " >&3
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v3 for all but jason in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=50
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s localhost:${HTTP_PORT}/productpage >&2; return 1; fi
        curl -s localhost:${HTTP_PORT}/productpage |grep -q 'color="red"'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "delete demo app test" {
  info
  test(){
    kubectl delete ns demo
  }
  run test
  [ "$status" -eq 0 ]
}
