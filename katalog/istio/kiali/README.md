# Kiali

Kiali is a project that implements an observability console for Istio. It helps you to understand the
structure of your service mesh by inferring the topology, the health of your mesh and see detailed metrics. Distributed
tracing is provided by integrating Jaeger.

## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [init istio](../init/)
- [minimal istio](../minimal/)
- [telemetry](../telemetry)
- [prometheus](https://github.com/sighupio/fury-kubernetes-monitoring/tree/v1.3.0/katalog/prometheus-operated)


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Addons**               |                    |
| `kiali`                  | :white_check_mark: |


## Image repository and tag

Kiali container image are currently available at quay: [quay.io/kiali/kiali](https://quay.io/repository/kiali/kiali)

- **Kiali**: quay.io/kiali/kiali:v1.9

## Configuration

### Admin user

This package provides an administrator user *(admin:admin)* to access the kiali dashboard. Please change the default
password editing the [kiali-auth.config](configuration/kiali-auth.config) before deploy it. 

Otherwise, edit the kiali secret inside the istio-system namespace.

```bash
$ kubectl get secret kiali -o yaml -n istio-system
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  passphrase: YWRtaW4=
  username: YWRtaW4=
```

Then, **restart the kiali pod** to take effect.

### Prometheus URL

There is a minor configuration to be made if you don't have the default
[`prometheus-operated`](https://github.com/sighupio/fury-kubernetes-monitoring/tree/v1.3.0/katalog/prometheus-operated)
server deployed in the `monitoring` namespace.

As Kiali needs to read metrics from a prometheus server, you have to define the prometheus server url in the
[config.yaml](configuration/config.yaml) file.

Otherwise, you can modify directly in the cluster modifying the kiali configmap inside the istio-system namespace.

```bash
$ kubectl get cm kiali -o yaml -n istio-system
kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    app: kiali
  name: kiali
  namespace: istio-system
data:
  config.yaml: |
    istio_namespace: istio-system
    deployment:
      accessible_namespaces: ['**']
    auth:
      strategy: login
    server:
      port: 20001
      web_root: /kiali
    external_services:
      tracing:
        url:
      grafana:
        url:
      prometheus:
        url: http://prometheus-k8s.monitoring:9090
```

Change the `external_services.prometheus.url` value with the correct prometheus server url and restart the kiali pod.


## License

For license details please see [LICENSE](../../../LICENSE)
