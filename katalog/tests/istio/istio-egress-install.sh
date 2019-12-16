#!/usr/bin/env bats

load ./../helper

@test "Install istio egress-gateway (minimal) package" {
  info
  test(){
    apply katalog/istio/egress-gateway
    apply katalog/istio/sidecar-injector-config/minimal-and-egress
  }
  run test
  [ "$status" -eq 0 ]
}

@test "Verify default mesh outbound traffic policy" {
  info
  test(){
    mode=$(kubectl get configmap istio -n istio-system -o jsonpath={.data.mesh} |yq r - outboundTrafficPolicy.mode)
    if [ "${mode}" != "ALLOW_ANY" ]; then echo "${mode} is not ALLOW_ANY" >&2; return 1; fi
  }
  run test
  [ "$status" -eq 0 ]
}
