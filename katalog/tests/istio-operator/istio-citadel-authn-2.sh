#!/usr/bin/env bats

load ./../helper

@test "Namespace-wide policy" {
  info
  setup_environment(){
    kubectl apply -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n foo
    kubectl apply -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n bar
  }
  run setup_environment
  [ "$status" -eq 0 ]
}

@test "Namespace-wide policy - Requests from client-without-sidecar to httpbin.foo start to fail" {
  info
  test(){
    for from in "legacy"
    do
      for to in "foo"
      do
        pod_name=$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})
        http_code=$(kubectl exec ${pod_name} -c sleep -n ${from} -- curl "http://httpbin.${to}:8000/ip" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "000" ]; then return 1; fi
      done
    done
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Namespace-wide policy - Requests from client-with-sidecar to httpbin.foo works" {
  info
  test(){
    for from in "foo" "bar"
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

@test "Service-specific policy - request from sleep.legacy to httpbin.bar starts failing" {
  info
  test(){
    for from in "legacy"
    do
      for to in "bar"
      do
        pod_name=$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})
        http_code=$(kubectl exec ${pod_name} -c sleep -n ${from} -- curl "http://httpbin.${to}:8000/ip" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "000" ]; then return 1; fi
      done
    done
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Namespace-wide policy - Cleanup" {
  info
  setup_environment(){
    kubectl delete -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n foo
    kubectl delete -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n bar
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
