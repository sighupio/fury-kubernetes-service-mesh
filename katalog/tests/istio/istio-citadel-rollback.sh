#!/usr/bin/env bats

load ./../helper

@test "back to default citadel behavior" {
  info
  setup_environment(){
    kubectl apply -f katalog/tests/istio/citadel/no-mtls.yaml
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
