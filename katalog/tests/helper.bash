#!/usr/bin/env bats

apply (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl apply -f - 2>&3
}

delete (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl delete -f - 2>&3
}

info(){
  echo -e "${BATS_TEST_NUMBER}: ${BATS_TEST_DESCRIPTION}" >&3
}
