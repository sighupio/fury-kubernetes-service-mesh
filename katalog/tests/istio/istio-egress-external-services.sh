#!/usr/bin/env bats

load ./../helper

@test "Accessing External Services - setup environment" {
  info
  setup_environment(){
    kubectl create ns egress-tests
    kubectl apply -f <(istioctl kube-inject -f katalog/tests/istio/egress/sleep.yaml) -n egress-tests
    kubectl apply -f katalog/tests/istio/egress/sleep-no-mesh.yaml -n egress-tests
  }
  wait_pod(){
    kubectl get pods -n egress-tests | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\|PodInitializing\|Init:\)"
  }
  run setup_environment
  loop_it wait_pod 30 2
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - Verify ALLOW_ANY" {
  info
  test(){
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "https://www.google.com" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - Change to the blocking-by-default policy" {
  info
  setup_environment(){
    kubectl get configmap istio -n istio-system -o yaml | sed 's/mode: ALLOW_ANY/mode: REGISTRY_ONLY/g' | kubectl replace -n istio-system -f -
  }
  run setup_environment
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - Verify REGISTRY_ONLY" {
  info
  test(){
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "https://www.google.com" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "000" ]; then return 1; fi
  }
  loop_it test 50 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - REGISTRY_ONLY - Access an external HTTP service" {
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/httpbin-ext.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "http://httpbin.org/headers" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - REGISTRY_ONLY - Access an external HTTPS service (without ServiceEntry)" {
  info
  test(){
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "https://www.google.com" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "000" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - REGISTRY_ONLY - Access an external HTTPS service" {
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/google-ext.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "https://www.google.com" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 50 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Accessing External Services - REGISTRY_ONLY - Manage traffic to external services" {
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/httpbin-virtual-service-ext.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "http://httpbin.org/delay/5" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "504" ]; then return 1; fi
  }
  loop_it test 50 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Egress TLS Origination - Configuring access to an external service" {
  # https://istio.io/docs/tasks/traffic-management/egress/egress-tls-origination/#configuring-access-to-an-external-service
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/cnn-ext.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "http://edition.cnn.com/politics" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "301" ]; then return 1; fi
  }
  loop_it test 50 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Egress TLS Origination - TLS origination for egress traffic" {
  # https://istio.io/docs/tasks/traffic-management/egress/egress-tls-origination/#configuring-access-to-an-external-service
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/cnn-origin-tls-ext.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    http_code=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "http://edition.cnn.com/politics" -s -o /dev/null -w "%{http_code}")
    if [ -z "${http_code}" ] || [ "${http_code}" -ne "200" ]; then return 1; fi
  }
  loop_it test 50 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Kubernetes Services for Egress Traffic - Access httpbin.org via the Kubernetes service’s hostname from the source pod without Istio sidecar" {
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/httpbin-externalName.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep-no-mesh -o jsonpath={.items..metadata.name} -n egress-tests)
    istio_header=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "http://my-httpbin/headers" -s |jq '.headers["X-Istio-Attributes"]' -rc) 
    if [ -z "${istio_header}" ] || [ "${istio_header}" != "null" ]; then return 1; fi
  }
  loop_it test 50 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Kubernetes Services for Egress Traffic - Access httpbin.org via the Kubernetes service’s hostname from the source pod with Istio sidecar." {
  info
  test(){
    kubectl apply -f katalog/tests/istio/egress/httpbin-externalName-destination-rule.yaml -n egress-tests
    pod_name=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name} -n egress-tests)
    istio_header=$(kubectl exec ${pod_name} -c sleep -n egress-tests -- curl "http://my-httpbin/headers" -s |jq '.headers["X-Istio-Attributes"]' -rc) 
    if [ -z "${istio_header}" ] || [ "${istio_header}" == "null" ]; then return 1; fi
  }
  loop_it test 50 2
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Rollback" {
  info
  setup_environment(){
    kubectl get configmap istio -n istio-system -o yaml | sed 's/mode: REGISTRY_ONLY/mode: ALLOW_ANY/g' | kubectl replace -n istio-system -f -
    kubectl delete ns egress-tests
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
