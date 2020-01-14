#!/usr/bin/env bats

load ./../helper

@test "Install istio citadel package" {
  info
  test(){
    apply katalog/istio/citadel
    apply katalog/istio/sidecar-injection/configuration/citadel
    kubectl -n istio-system wait --for=condition=complete job --all
  }
  run test
  [ "$status" -eq 0 ]
}

@test "Verify default mesh authentication policy" {
  info
  test(){
    mode=$(kubectl get meshpolicies.authentication.istio.io default -o jsonpath={.spec.peers..mtls.mode})
    if [ "${mode}" != "PERMISSIVE" ]; then echo "${mode} is not PERMISSIVE" >&2; return 1; fi
  }
  run test
  [ "$status" -eq 0 ]
}
