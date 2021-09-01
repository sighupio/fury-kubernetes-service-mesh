# Kong Mesh

## Global Control Plane

Have a look at [global-control-plane/kustomization.yaml](global-control-plane/kustomization.yaml) to see a full example of Global Control Plane.

Install `kumactl` on your local system to better interact with the system.

Ref: https://docs.konghq.com/mesh/1.4.x/install/

### (Optional) Mount license on control plane

> If you're not using a license, you will deploy Kuma, the open source version of Kong Mesh.

1. Copy your license in `secrets/license.json`

2. Add a secretGenerator for license, like in `kustomization.yaml`

3. Add `patches/kong-mesh-license-mount.yml` to your manifests

### (Optional) Use custom CA

> If you do not specify, Kong Mesh uses its builtin CA to generate certificates

1. Generate certificates

```bash
kumactl generate tls-certificate --type=server --cp-hostname=<CROSS_ZONE_KUMA_CP_DNS_NAME> --cert-file=secrets/tls.crt --key-file=secrets/tls.key
```

2. Add a secretGenerator for certs, like in `kustomization.yaml`

3. Add `patches/kong-mesh-tls-cert-mount.yml` to your manifests

## Zone Control Plane

Have a look at [zone-control-plane/kustomization.yaml](zone-control-plane/kustomization.yaml) to see a full example of Zone Control Plane.

### (Mandatory) Register the Zone Control Plane to the Global Control Plane

1. Generate token from Global CP

Expose the Global CP service locally:
```bash
kubectl port-forward svc/kong-mesh-control-plane -n kong-mesh-system 5681:5681
```

From another shell create the tokens for zone control planes:
```bash
kumactl generate control-plane-token --zone=<ZONE_NAME> secrets/token
```

2. Add a secretGenerator for cp-token, like in `kustomization.yaml`

3. Mount the secret to Zone CP, like in `patches/kong-mesh-secrets-mount.yml`

### (Mandatory) Set zone name and global cp address

1. Fill the corresponding fields in `patches/kong-mesh-zone.yml`

### (Optional) Use custom CA

1. Copy `tls.crt` from global control plane to `secrets/ca.crt`.

2. Add a secretGenerator for ca, like in `kustomization.yaml`

3. Mount the secret to Zone CP, like in `patches/kong-mesh-secrets-mount.yml`

### (Optional) Expose metrics for Prometheus Operator

Add the following files to your manifests:

- `patches/kong-mesh-metrics.yml`
- `resources/kong-mesh-scrape-config.yml`
- `patches/prometheus-kong-mesh-scrape.yml`
- `resource/service-monitor.yml`

### Add dashboards to Grafana

Add the following resources as configMaps, like in `kustomization.yaml`:

- `resources/dashboards/kmesh-controlplane.json`
- `resources/dashboards/kmesh-dataplane.json`
- `resources/dashboards/kmesh-mesh.json`
- `resources/dashboards/kmesh-service-to-service.json`

Remember to label all of them with `grafana-sighup-dashboard: kong-mesh`

## Demo application

Follow this: https://kuma.io/docs/1.3.0/quickstart/kubernetes/#_1-run-the-marketplace-application