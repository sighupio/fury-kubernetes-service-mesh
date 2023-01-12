# Development notes

## Istio

Here is explained how we develop the Istio package inside the service-mesh SIGHUP module. It's essential to
maintain this document updated. So, any new/modified action has to be written here.

## Runbooks

- [`custom-ca`](../../docs/development/custom-ca/): If you need to configure Istio to run with a specific CA
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

### Dashboard and Rules

#### Grafana Dashboards

This manifest has been templated from the `katalog/istio-operator/istio/dashboards` and uses the following dashboards:
- [Istio Mesh Dashboard](https://grafana.com/grafana/dashboards/7639-istio-mesh-dashboard)
- [Istio Control Plane Dashboard](https://grafana.com/grafana/dashboards/7645-istio-control-plane-dashboard/)
- [Istio Service Dashboard](https://grafana.com/grafana/dashboards/7636-istio-service-dashboard)
- [Istio Workload Dashboard](https://grafana.com/grafana/dashboards/7630-istio-workload-dashboard)

#### Prometheus Rules

This manifest has been templated from the [katalog/istio-operator/istio/rules.yml](https://github.com/istio/tools/blob/1.12.6/perf/stability/alertmanager/prometheusrule.yaml)

Once deployed, you will be able to find some `Alert` on prometheus dashboard.

## Links

- [istio in action @ GITHUB](https://github.com/istioinaction/book-source-code)
