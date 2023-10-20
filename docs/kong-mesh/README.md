# Kong Mesh

The following is an imperative flow to understand the operations order.
Have a look to the declarative example with kustomize [here](../../examples/kong-mesh/README.md).

Kuma (open source Kong Mesh): <https://kuma.io/docs/1.3.0/>
Kong Mesh: <https://docs.konghq.com/mesh/>

## Install kumactl
```bash
# If you do not set version, the latest will be downloaded
export VERSION=1.4.1
curl -L https://docs.konghq.com/mesh/installer.sh | sh -
cd kong-mesh-1.4.1/bin
cp kumactl /usr/local/bin/
kumactl version
```

## Global Control Plane

### Global Control Plane - Installation

#### Global Control Plane - Use builtin certificates

Supposing to have your license at `secrets/license.json`:

```bash
kumactl install control-plane \
  --license-path=secrets/license.json \
  --mode=global \
  --cp-auth=cpToken > kuma-global.yml

kubectl apply -f kuma-global.yml
```

#### Global Control Plane - Generate custom certificates for your DNS domain

```bash
kumactl generate tls-certificate \
  --type=server \
  --cp-hostname=<CROSS_ZONE_KUMA_CP_DNS_NAME> \
  --cert-file=/tmp/tls.crt \
  --key-file=/tmp/tls.key

cp /tmp/tls.crt /tmp/ca.crt # since this is self-signed cert, the cert is also a CA

kubectl create secret tls kds-server-tls -n kong-mesh-system \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key

kumactl install control-plane \
  --license-path=secrets/license.json \
  --mode=global \
  --cp-auth=cpToken \
  --tls-kds-global-server-secret=kds-server-tls > kuma-global.yml

kubectl apply -f kuma-global.yml
```

### Global Control Plane - Generate tokens for Zone Control Planes
Expose the service locally:
```bash
kubectl port-forward svc/kong-mesh-control-plane -n kong-mesh-system 5681:5681
```

From another shell create the tokens for zone control planes:
```bash
kumactl generate control-plane-token --zone=<ZONE_NAME_1> /tmp/token-1
kumactl generate control-plane-token --zone=<ZONE_NAME_2> /tmp/token-2
```

### Global Control Plane - Enable mTLS and metrics
Use the following as default Mesh:

```yaml
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  metrics:
    backends:
    - conf:
        skipMTLS: true
        path: /metrics
        port: 5670
        tags:
          kuma.io/service: dataplane-metrics
      name: prometheus-1
      type: prometheus
    enabledBackend: prometheus-1
  mtls:
    backends:
    - name: default-mtls
      type: builtin
    enabledBackend: default-mtls
  routing:
    localityAwareLoadBalancing: true
```

## Zone Control Plane

### Zone Control Plane - Installation

Warning! Zone Control Plane cannot be installed in the same cluster the Global Control Plane is located in.

#### Zone Control Plane - Use builtin certificates

```bash
kumactl install control-plane \  
  --license-path=secrets/license.json \
  --cp-token-path=/tmp/token-1 \
  --mode=zone \
  --zone=<ZONE_NAME_1> \
  --ingress-enabled \
  --kds-global-address=grpcs://<GLOBAL_CP_ADDRESS>:<GLOBAL_CP_PORT> > kuma-zone-1.yml

kubectl apply -f kuma-zone-1.yml
```

#### Zone Control Plane - Generate custom certificates for your DNS domain

If you generated custom certificates in Global Control Plane, you have to create a secret with the CA:

```bash
kubectl create secret generic kds-ca-certs -n kong-mesh-system \
  --from-file=ca.crt=/tmp/ca.crt
```

Then point to the secret when installing:
```bash
kumactl install control-plane \  
  --license-path=secrets/license.json \
  --cp-token-path=/tmp/token-1 \
  --mode=zone \
  --zone=<ZONE_NAME_1> \
  --ingress-enabled \
  --tls-kds-zone-client-secret=kds-ca-certs \
  --kds-global-address=grpcs://<GLOBAL_CP_ADDRESS>:<GLOBAL_CP_PORT> > kuma-zone-1.yml

kubectl apply -f kuma-zone-1.yml
```

The following patch is needed for the Zone to work, if the Load Balancer is not attached or you use a NodePort:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kong-mesh-ingress
  namespace: kong-mesh-system
spec:
  template:
    metadata:
      annotations:
        kuma.io/ingress-public-address: <NODE_IP>
        kuma.io/ingress-public-port: <NODE_PORT>
```

### Zone Control Plane - Expose metrics for Prometheus Operator

To expose metrics the following patch is needed:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: kong-mesh-control-plane
  namespace: kong-mesh-system
  labels:
    app: kuma-control-plane
spec:
  ports:
    - port: 5680
      name: metrics
      protocol: TCP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kong-mesh-control-plane
  namespace: kong-mesh-system
spec:
  template:
    spec:
      containers:
        - name: control-plane
          ports:
            - containerPort: 5680
```

Add Kuma scraping configuration as a secret:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kuma-scrape-config
  namespace: monitoring
stringData:
  additional-scrape-configs.yml: |
    - job_name: 'kuma-dataplanes'
      scrape_interval: "5s"
      relabel_configs:
      - source_labels:
        - k8s_kuma_io_name
        regex: "(.*)"
        target_label: pod
      - source_labels:
        - k8s_kuma_io_namespace
        regex: "(.*)"
        target_label: namespace
      file_sd_configs:
      - files:
        - /etc/prometheus/config_out/kuma.file_sd.json
```

Then you have to patch Prometheus Operator CRD to collect kuma metrics:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: k8s
  namespace: monitoring
spec:
  additionalScrapeConfigs:
    key: additional-scrape-configs.yml
    name: kuma-scrape-config
  containers:
    - name: kuma-prometheus-sd
      image: kong/kuma-prometheus-sd:1.3.3
      imagePullPolicy: IfNotPresent
      args:
        - run
        - --name=kuma-prometheus-sd
        - --cp-address=grpc://kong-mesh-control-plane.kong-mesh-system:5676
        - --output-file=/etc/prometheus/config_out/kuma.file_sd.json
      resources:
        limits:
          cpu: 100m
          memory: 25Mi
      volumeMounts:
        - mountPath: /etc/prometheus/config_out
          name: config-out
  securityContext:
    runAsNonRoot: false
```

Finally you can configure the ServiceMonitor like this:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kong-mesh
  namespace: kong-mesh-system
spec:
  endpoints:
  - interval: 30s
    port: metrics
  selector:
    matchLabels:
      app: kuma-control-plane
```