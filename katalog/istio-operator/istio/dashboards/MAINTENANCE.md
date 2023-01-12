# Dashboard and Rules

## Grafana Dashboards

- [Istio Mesh Dashboard](https://grafana.com/grafana/dashboards/7639-istio-mesh-dashboard)
- [Istio Control Plane Dashboard](https://grafana.com/grafana/dashboards/7645-istio-control-plane-dashboard/)
- [Istio Service Dashboard](https://grafana.com/grafana/dashboards/7636-istio-service-dashboard)
- [Istio Workload Dashboard](https://grafana.com/grafana/dashboards/7630-istio-workload-dashboard)

Compared to the official dashboards, the following changes have been made:

- renamed the variable from "DS_PROMETHEUS" to "datasource"
- added tag "istio" on each dashboard

## Prometheus Rules

This manifest has been templated from the [katalog/istio-operator/istio/rules.yml](https://github.com/istio/tools/blob/1.12.6/perf/stability/alertmanager/prometheusrule.yaml)