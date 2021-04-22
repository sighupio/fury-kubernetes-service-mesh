#!/usr/bin/env bats

load ./../helper

@test "testing init-istio package" {
  info
  test(){
    apply katalog/istio/init
    kubectl -n istio-system wait --for=condition=complete job --all
  }
  run test
  [ "$status" -eq 0 ]
}

@test "testing istio package installation" {
  info
  test(){
    apply katalog/istio
    apply katalog/istio/sidecar-injection/configuration/minimal
  }
  run test
  [ "$status" -eq 0 ]
}

@test "wait for istio package to be running" {
  info
  test(){
    retry_counter=0
    max_retry=30
    while kubectl get pods -n istio-system | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\|PodInitializing\|Init:\)" >&2
    do
      [ $retry_counter -lt $max_retry ] || ( kubectl describe all -n istio-system >&2 && return 1 )
      sleep 2 && echo "# waiting..." $retry_counter >&3
      retry_counter=$[ $retry_counter + 1 ]
    done
  }
  run test
  [ "$status" -eq 0 ]
}