# Kuma Multi-Cluster

## Global Control Plane

Have a look at [global-control-plane/kustomization.yaml](global-control-plane/kustomization.yaml) to see a full example of Global Control Plane.

Install `kumactl` on your local system to better interact with the system.

Ref: <https://kuma.io/docs/1.4.x/installation/kubernetes/>

### Global Control Plane - (Mandatory) Use custom CA

1. Generate certificates for internal communication

```bash
kumactl generate tls-certificate --type=server \
  --cp-hostname=kuma-control-plane.kuma-system \
  --cp-hostname=kuma-control-plane.kuma-system.svc \
  --cert-file=secrets/internal.crt \
  --key-file=secrets/internal.key

```

2. Generate certificates for external communication

```bash
kumactl generate tls-certificate --type=server \
  --cp-hostname=<CROSS_ZONE_KUMA_CP_DNS_NAME> \
  --cert-file=secrets/external.crt \
  --key-file=secrets/external.key
```

3. Add the following patches to your manifests to mount certificates:
- `patches/kuma-tls-cert-mount.yml`

## Zone Control Plane

Have a look at [zone-control-plane/kustomization.yaml](zone-control-plane/kustomization.yaml) to see a full example of Zone Control Plane.

### Zone Control Plane - (Mandatory) Set zone name and global cp address

1. Fill the corresponding fields in `patches/kuma-zone.yml`

### Zone Control Plane - (Mandatory) Use custom CA

1. Copy `external.crt` from global control plane to `secrets/ca.crt`.

2. Generate a new certificate for internal communication

```bash
kumactl generate tls-certificate --type=server \
  --cp-hostname=kuma-control-plane.kuma-system \
  --cp-hostname=kuma-control-plane.kuma-system.svc \
  --cert-file=secrets/internal.crt \
  --key-file=secrets/internal.key

```

3. Add the following patches to your manifests to mount certificates:
- `patches/kuma-tls-cert-mount.yml`

### Zone Control Plane - (Optional) Expose kuma ingress using NodePort

1. Fill the corresponding fields in `patches/kuma-public-ingress.yml` and add it to your manifests.

### Zone Control Plane - (Optional) Expose metrics for Prometheus Operator

Add the following files to your manifests:

- `patches/kuma-metrics.yml`
- `resources/kuma-scrape-config.yml`
- `patches/prometheus-kuma-scrape.yml`
- `resources/service-monitor.yml`

### Zone Control Plane - (Optional) Add dashboards to Grafana

Add the following resources as configMaps, like in `kustomization.yaml`:

- `resources/dashboards/kmesh-controlplane.json`
- `resources/dashboards/kmesh-dataplane.json`
- `resources/dashboards/kmesh-mesh.json`
- `resources/dashboards/kmesh-service-to-service.json`

Remember to label all of them with `grafana-sighup-dashboard: kuma`

Ref: <https://grafana.com/orgs/konghq/dashboards>

## Demo application

Follow this: <https://kuma.io/docs/1.4.x/quickstart/kubernetes/#_1-run-the-marketplace-application>