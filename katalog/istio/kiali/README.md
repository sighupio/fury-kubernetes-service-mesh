# Kiali

## Image repository and tag

Kiali container image are currently available at quay: [quay.io/kiali/kiali](https://quay.io/repository/kiali/kiali)

- **Kiali**: quay.io/kiali/kiali:v1.9

## Configuration

### Admin user

This package provides an administrator user *(admin:admin)* to access the kiali dashboard. Please change the default
password editing the `kiali` secret inside the `istio-system` namespace.

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

You can generate a new one with the following commands:

```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
stringData:
  username: YOUR_USERNAME
  passphrase: YOUR_PASSWORD
EOF
```

Then, **restart the kiali pod** to take effect.

### Prometheus URL

There is a minor configuration to be made if you don't have the default
[`prometheus-operated`](https://github.com/sighupio/fury-kubernetes-monitoring/tree/v1.3.0/katalog/prometheus-operated)
server deployed in the `monitoring` namespace.

As Kiali needs to read metrics from a prometheus server, you have to define the prometheus server url.

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

Change the `external_services.prometheus.url` value with the correct prometheus server url.


## License

For license details please see [LICENSE](../../../LICENSE)
