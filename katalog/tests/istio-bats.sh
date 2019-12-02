#!/usr/bin/env bats

apply (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl apply -f - 2>&3
}

info(){
  echo -e "${BATS_TEST_NUMBER}: ${BATS_TEST_DESCRIPTION}" >&3
}

@test "testing init-istio package" {
  info
  test(){
    apply katalog/init-istio
    kubectl -n istio-system wait --for=condition=complete job --all
  }
  run test
  [ "$status" -eq 0 ]
}

@test "testing istio package installation" {
  info
  test(){
    apply katalog/istio
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

@test "deploy bookinfo demo application" {
  info
  deploy(){
    kubectl create ns demo
    kubectl apply -f <(istioctl kube-inject -f katalog/tests/bookinfo/bookinfo.yaml) -n demo
    kubectl apply -f katalog/tests/bookinfo/bookinfo-gateway.yaml -n demo
    kubectl apply -f katalog/tests/bookinfo/destination-rule-all.yaml -n demo
    kubectl apply -f katalog/tests/bookinfo/virtual-service-all-v1.yaml -n demo
  }
  wait_for_it() {
    retry_counter=0
    max_retry=30
    while kubectl get pods -n demo | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\|PodInitializing\|Init:\)" >&2
    do
      [ $retry_counter -lt $max_retry ] || ( kubectl describe all -n demo >&2 && return 1 )
      sleep 2 && echo "# waiting..." $retry_counter >&3
      retry_counter=$[ $retry_counter + 1 ]
    done
    # Wait for productpage review endpoint
    retry_counter=0
    max_retry=10
    while curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep "Error fetching product reviews!"  >&2
    do
      [ $retry_counter -lt $max_retry ] || ( kubectl describe all -n demo >&2 && return 1 )
      sleep 2 && echo "# waiting..." $retry_counter >&3
      retry_counter=$[ $retry_counter + 1 ]
    done
  }
  run deploy
  [ "$status" -eq 0 ]
  run wait_for_it
  [ "$status" -eq 0 ]
}

@test "test v1 bookinfo demo application" {
  info
  test_back_stars(){
    curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="black"'
  }
  run test_back_stars
  back_stars_result=$status
  test_red_stars(){
    curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="red"'
  }
  run test_red_stars
  red_stars_result=$status
  [ "$back_stars_result" -eq 1 ] && [ "$red_stars_result" -eq 1 ]
}

@test "deploy v2 for jason and v3 for the rest in bookinfo demo application" {
  info
  test(){
    kubectl apply -f katalog/tests/bookinfo/virtual-service-reviews-jason-v2-v3.yaml -n demo
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v2 for jason in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        rm -rf ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt
        curl -s -L -c ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt -d "username=jason" -d "passwd=jason" http://${INSTANCE_IP}:${CLUSTER_NAME}81/login
        curl -s -b ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="black"'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v3 for all but jason in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="red"'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "deploy v2 for jason and deny access to v3 in bookinfo demo application" {
  info
  test(){
    kubectl apply -f katalog/tests/bookinfo/mixer-rule-deny-label.yaml -n demo
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v2 for jason (again) in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        rm -rf ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt
        curl -s -L -c ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt -d "username=jason" -d "passwd=jason" http://${INSTANCE_IP}:${CLUSTER_NAME}81/login
        curl -s -b ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="black"'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v3 denied for all in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'Ratings service is currently unavailable'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "destroy v2 for jason and deny access to v3 in bookinfo demo application" {
  info
  test(){
    kubectl delete -f katalog/tests/bookinfo/mixer-rule-deny-label.yaml -n demo
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v3 back normal again in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="red"'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}


@test "deploy whitelist by attribute scenario in bookinfo demo application" {
  info
  test(){
    kubectl apply -f katalog/tests/bookinfo/mixer-rule-deny-whitelist.yaml -n demo
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v2 for jason (again and again) in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        rm -rf ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt
        curl -s -L -c ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt -d "username=jason" -d "passwd=jason" http://${INSTANCE_IP}:${CLUSTER_NAME}81/login
        curl -s -b ${BATS_TMPDIR}/test-cookie-${CLUSTER_NAME}.txt ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'color="black"'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "test v3 denied by whitelist for all in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        curl -s ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q 'Ratings service is currently unavailable'
        ko=$?
        sleep 3 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "deploy rate limit in bookinfo demo application" {
  info
  test(){
    kubectl apply -f katalog/tests/bookinfo/mixer-rule-productpage-ratelimit.yaml -n istio-system
  }
  run test
  [ "$status" -eq 0 ]
}

@test "verify rate limit object in bookinfo demo application" {
  info
  test(){
    kubectl get QuotaSpecBinding request-count -n istio-system -o yaml |grep -q "namespace: demo"
  }
  run test
  [ "$status" -eq 0 ]
}

@test "Verify rate limit in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=30
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -I ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        curl -sI ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q "429 Too Many Requests"
        ko=$?
        sleep 1 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "Verify rate limit back to normal again in bookinfo demo application" {
  info
  test(){
    retry_counter=0
    max_retry=5
    ko=1
    while [[ ko -eq 1 ]]
    do
        if [ $retry_counter -ge $max_retry ]; then echo "Timeout waiting a condition"; curl -I ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage >&2; return 1; fi
        curl -sI ${INSTANCE_IP}:${CLUSTER_NAME}81/productpage |grep -q "200 OK"
        ko=$?
        sleep 30 && echo "# waiting..." $retry_counter >&3
        retry_counter=$((retry_counter + 1))
    done
  }
  run test
  [ "$status" -eq 0 ]
}

@test "delete rate limit in bookinfo demo application" {
  info
  test(){
    kubectl delete -f katalog/tests/bookinfo/mixer-rule-productpage-ratelimit.yaml -n istio-system
  }
  run test
  [ "$status" -eq 0 ]
}

@test "delete demo app test" {
  info
  test(){
    kubectl delete ns demo
  }
  run test
  [ "$status" -eq 0 ]
}
