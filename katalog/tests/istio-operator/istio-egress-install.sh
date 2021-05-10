#!/usr/bin/env bats

load ./../helper

@test "Install istio egress-gateway (minimal) package" {
  info
  test(){
    apply examples/istio-operator/enable-egress-gateway
  }
  run test
  [ "$status" -eq 0 ]
}
