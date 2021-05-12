#!/usr/bin/env bats

load ./../helper

@test "End-user authentication" {
  info
  setup_environment(){
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin-at-foo-gateway.yaml
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin-at-foo-virtual-service.yaml
  }
  run setup_environment
  [ "$status" -eq 0 ]
}

@test "End-user authentication - Test" {
  info
  test(){
    TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.9/security/tools/jwt/samples/demo.jwt -s)
    http_code=$(kubectl exec "$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -w "%{http_code}\n")

    if [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "End-user authentication - Add a policy that requires end-user JWT for httpbin.foo" {
  info
  setup_environment(){
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin-at-foo-jwt-policy.yaml
  }
  run setup_environment
  [ "$status" -eq 0 ]
}

@test "End-user authentication - Test without token" {
  info
  test(){
    TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.9/security/tools/jwt/samples/demo.jwt -s)
    http_code=$(kubectl exec "$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null  -w "%{http_code}\n")
    if [ "${http_code}" -ne "403" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "End-user authentication - Test with token" {
  info
  test(){
    TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.9/security/tools/jwt/samples/demo.jwt -s)
    http_code=$(kubectl exec "$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer $TOKEN" -w "%{http_code}\n")
    if [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "End-user authentication with mutual TLS" {
info
  setup_environment(){
    kubectl apply -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n foo
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin-at-foo-jwt-mtls-policy.yaml
    kubectl apply -f katalog/tests/istio-operator/citadel/httpbin-at-foo-jwt-mtls-destination-rule.yaml
  }
  run setup_environment
  [ "$status" -eq 0 ]
}

@test "End-user authentication with mutual TLS - Test with token" {
  info
  test(){
    TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.4/security/tools/jwt/samples/demo.jwt -s)
    pod_name=$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})
    http_code=$(kubectl exec ${pod_name} -c sleep -n foo -- curl http://httpbin.foo:8000/ip -s -o /dev/null -w "%{http_code}\n" --header "Authorization: Bearer $TOKEN")
    if [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "End-user authentication with mTLS - Requests from client-without-sidecar to httpbin.foo start to fail" {
  info
  test(){
    TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.4/security/tools/jwt/samples/demo.jwt -s)
    pod_name=$(kubectl get pod -l app=sleep -n legacy -o jsonpath={.items..metadata.name})
    http_code=$(kubectl exec ${pod_name} -c sleep -n legacy -- curl http://httpbin.foo:8000/ip -s -o /dev/null -w "%{http_code}\n" --header "Authorization: Bearer $TOKEN")
    if [ "${http_code}" -ne "000" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "End-user authentication with mTLS and End-user authentication - Cleanup" {
  info
  setup_environment(){
    kubectl delete -f katalog/tests/istio-operator/citadel/httpbin-at-foo-jwt-mtls-policy.yaml
    kubectl delete -f katalog/tests/istio-operator/citadel/httpbin-at-foo-jwt-mtls-destination-rule.yaml
    kubectl delete -f katalog/tests/istio-operator/citadel/httpbin-at-foo-gateway.yaml
    kubectl delete -f katalog/tests/istio-operator/citadel/httpbin-at-foo-virtual-service.yaml
    kubectl delete -f katalog/tests/istio-operator/mtls-enabled-wide.yml -n foo
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
