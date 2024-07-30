#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2086,SC2154,SC2034

load '../helper/bats-support/load'
load '../helper/bats-assert/load'

setup() {
    if [ -z "${SETUP_DONE}" ]; then
        echo "Starting setup..."

        # Call the script to install kapp
        ./scripts/install_kapp.sh
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
            echo "kapp installation failed."
            return 1
        fi

        # Generate kustomization.yaml
        echo "Generating kustomization.yaml..."
        ./scripts/generate_kustomization.sh

        export SETUP_DONE=true
        echo "Setup completed."
    else
        echo "Setup already completed. Skipping..."
    fi
}

@test "Verify kapp CLI is available" {
    run which kapp
    assert_success
}

@test "Deploy cert-manager using kapp" {
    run kapp deploy -y -a cert-manager -f <(kustomize build .)
    assert_success
}

@test "Deploy jaeger-operator using kapp" {
    run kapp deploy -y -a jaeger-operator -f <(kustomize build ../../istio-operator/jaeger-operator)
    assert_success
}
@test "Deploy jaeger Operated using kapp" {
    run kapp deploy -y -a jaeger -f <(cat ../../istio-operator/jaeger/jaeger.yml ../../istio-operator/jaeger/svc.yml)
    assert_success
}
@test "Verify cert-manager is installed" {
    # Checks that Cert Manager is installed by verifying the existence of its primary CRD
    run kubectl get crd certificates.cert-manager.io
    assert_success
}

@test "Namespace 'observability' should exist" {
    # Verifies that the 'observability' namespace has been created successfully
    run kubectl get namespace observability
    assert_success
    assert_output --partial "observability"
}
 ### operated test

 @test "Deployment of collector-monitoring service should be correctly configured" {
    # Verifies that the collector-monitoring service has been created successfully in the correct namespace
    run kubectl get service collector-monitoring -n observability
    assert_success
    # Check if the service is correctly configured by checking for its expected output
    assert_output --partial "collector-monitoring"
}

@test "Deployment of query-monitoring service should be correctly configured" {
    # Verifies that the query-monitoring service has been created successfully in the correct namespace
    run kubectl get service query-monitoring -n observability
    assert_success
    # Check if the service is correctly configured by checking for its expected output
    assert_output --partial "query-monitoring"
}

@test "Deployment of Jaeger resource should be correctly updated" {
    # Verifies that the Jaeger resource has been updated successfully in the observability namespace
    run kubectl get jaeger jaeger -n observability
    assert_success
    
    # Check for the status part of the Jaeger resource to confirm it is 'ok'
    run kubectl get jaeger jaeger -n observability -o jsonpath='{.status.phase}'
    assert_output --partial "Running"  # Adjust the exact output as per your deployment's status output
}
## end of operated test
@test "ValidatingWebhookConfiguration should exist" {
    # Checks that the ValidatingWebhookConfiguration for Jaeger is properly applied and exists
    run kubectl get validatingwebhookconfiguration jaeger-operator-validating-webhook-configuration
    assert_success
}

@test "Services for the Jaeger operator should be correctly configured" {
    # Verifies the existence of necessary services for the Jaeger operator
    run kubectl get service -n observability jaeger-operator-webhook-service
    assert_success

    run kubectl get service -n observability jaeger-operator-metrics
    assert_success
}

@test "ServiceAccount 'jaeger-operator' should exist" {
    # Verifies that the ServiceAccount 'jaeger-operator' exists in the 'observability' namespace
    run kubectl get serviceaccount -n observability jaeger-operator
    assert_success
}

@test "Roles and RoleBindings should be correctly configured" {
    # Verifies the existence and configuration of Roles and RoleBindings
    run kubectl get role -n observability prometheus
    assert_success

    run kubectl get role -n observability leader-election-role
    assert_success

    run kubectl get rolebinding -n observability prometheus
    assert_success

    run kubectl get rolebinding -n observability leader-election-rolebinding
    assert_success
}

@test "MutatingWebhookConfiguration should be configured" {
    # Checks for the existence of the MutatingWebhookConfiguration for Jaeger
    run kubectl get mutatingwebhookconfiguration jaeger-operator-mutating-webhook-configuration
    assert_success
}

@test "Issuer should be configured" {
    # Verifies that the Issuer from cert-manager is configured to issue certificates
    run kubectl get issuer -n observability jaeger-operator-selfsigned-issuer
    assert_success
}

@test "Deployment of the Jaeger Operator should be correctly configured" {
    # Verifies that the Deployment of the Jaeger Operator is correctly configured and the pods are running
    run kubectl get deployment -n observability jaeger-operator
    assert_success
    # Ensures that at least one pod is in 'Ready' state
    assert_output --partial "1/1"
}

@test "CustomResourceDefinitions should be installed" {
    # Verifies the existence of the CRD for Jaegers
    run kubectl get crd jaegers.jaegertracing.io
    assert_success
}

@test "ClusterRoles and ClusterRoleBindings should be correctly configured" {
    # Verifies the existence and configuration of ClusterRoles and ClusterRoleBindings
    run kubectl get clusterrole jaeger-operator-metrics-reader
    assert_success

    run kubectl get clusterrolebinding manager-rolebinding
    assert_success

    run kubectl get clusterrolebinding jaeger-operator-proxy-rolebinding
    assert_success
}

@test "Certificate should be configured" {
    # Verifies the existence and correct configuration of the certificate issued for the Jaeger Operator
    run kubectl get certificate -n observability jaeger-operator-serving-cert
    assert_success
}
