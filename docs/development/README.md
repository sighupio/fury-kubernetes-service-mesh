# Development notes

## Istio

Here is explained how we develop the Istio package inside the service-mesh SIGHUP module. It's essential to
maintain this document updated. So, any new/modified action has to be written here.

## Runbooks

- [`custom-ca`](custom-ca/): If you need to configure Istio to run with a specific CA
  instead of the self-signed one.

### Service monitor manifests

This manifests has been templated from the [katalog/istio-operator/istio/sm.yml](https://github.com/istio/istio/blob/1.9.5/samples/addons/extras/prometheus-operator.yaml)

Once deployed, you will be able to find some `serviceMonitor` Prometheus Operator resources. It is required by Kiali dashboard.

### Demos / Testing

All the following examples are tested in the pipeline

### e2e tests

[minimal-test](../../katalog/tests/istio-operator/istio-minimal.sh)
[egress-test](../../katalog/tests/istio-operator/istio-egress-external-services.sh)
[mtls-test-1](../../katalog/tests/istio-operator/istio-citadel-authn-1.sh)
[mtls-test-2](../../katalog/tests/istio-operator/istio-citadel-authn-2.sh)
[mtls-test-3](../../katalog/tests/istio-operator/istio-citadel-authn-3.sh)

## Links

- [istio in action @ GITHUB](https://github.com/istioinaction/book-source-code)
