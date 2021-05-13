#!/usr/bin/env bats

load ./../helper

@test "Install istio minimal profile" {
  info
  test(){
    apply katalog/istio-operator/profiles/minimal
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Wait for istio package to be running" {
  info
  test(){
    retry_counter=0
    max_retry=30
    while [ "$(kubectl get istiooperator -n istio-system istio -o jsonpath='{.status.status}')" != "HEALTHY" ]
    do
      describe_output=$(kubectl get istiooperator -n istio-system istio -o json)
      echo -n " current status is :$(kubectl get istiooperator -n istio-system istio -o jsonpath='{.status.status}'), expected is : HEALTHY" >&3
      echo -n " Istio Operator resource is: $describe_output" >&3
      [ $retry_counter -lt $max_retry ] || ( kubectl describe all -n istio-system >&2 && return 1 )
      sleep 20 && echo "# waiting..." $retry_counter >&3
      retry_counter=$[ $retry_counter + 1 ]
    done
  }
  run test
  [ "$status" -eq 0 ]
}
