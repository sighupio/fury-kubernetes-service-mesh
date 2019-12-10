#!/usr/bin/env bats

load ./../helper

@test "Install istio citadel package" {
  info
  test(){
    apply katalog/istio/citadel
    kubectl -n istio-system wait --for=condition=complete job --all
  }
  run test
  [ "$status" -eq 0 ]
}

@test "Setup the required namespace and workloads" {
  info
  setup_environment(){
    kubectl create ns foo
    kubectl create ns bar
    kubectl create ns legacy
    kubectl apply -f <(istioctl kube-inject -f katalog/tests/istio/citadel/httpbin.yaml) -n foo
    kubectl apply -f <(istioctl kube-inject -f katalog/tests/istio/citadel/httpbin.yaml) -n bar
    kubectl apply -f katalog/tests/istio/citadel/httpbin.yaml -n legacy
    kubectl apply -f <(istioctl kube-inject -f katalog/tests/istio/citadel/sleep.yaml) -n foo
    kubectl apply -f <(istioctl kube-inject -f katalog/tests/istio/citadel/sleep.yaml) -n bar
    kubectl apply -f katalog/tests/istio/citadel/sleep.yaml -n legacy
  }
  run setup_environment
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

@test "Verify setup by sending an HTTP request" {
  info
  test(){
    for from in "foo" "bar" "legacy"
    do
      for to in "foo" "bar" "legacy"
      do
        pod_name=$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})
        http_code=$(kubectl exec ${pod_name} -c sleep -n ${from} -- curl "http://httpbin.${to}:8000/ip" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "200" ]; then return 1; fi
      done
    done
  }
  retry_counter=0
  max_retry=30
  ko=1
  while [[ ko -eq 1 ]]
  do
    if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; exit 1; fi
    sleep 2 && echo "# waiting..." $retry_counter >&3
    run test
    ko=${status}
    retry_counter=$((retry_counter + 1))
  done
  [ "$status" -eq 0 ]
}