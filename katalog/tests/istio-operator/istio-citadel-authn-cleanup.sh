#!/usr/bin/env bats

load ./../helper

@test "Authentication - Cleanup" {
  info
  setup_environment(){
    kubectl delete ns foo bar legacy
  }
  run setup_environment
  [ "$status" -eq 0 ]
}
