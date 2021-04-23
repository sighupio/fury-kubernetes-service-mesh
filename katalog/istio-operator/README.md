## For mTLS with nginx

### Ingress Controller Nginx

1. label the ingress-nginx with the `istio-injection=enabled`
2. crete the following crd:

```yaml
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
spec:
  mtls:
    mode: PERMISSIVE
```

3. put the following annotation in the Daemonset in `/spec/template`:

```yaml
annotations:
        traffic.sidecar.istio.io/excludeInboundPorts: 80,443
        traffic.sidecar.istio.io/includeInboundPorts: ""
```

### Microservice with mTLS strict

1. in the namespace of your applications just put this crd: 

```yaml
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
spec:
  mtls:
    mode: STRICT
```

2. For each ingress you create for exposing your service, remember to add those 2 annotations in it: 

```yaml
    # this is the way: 1 service, 1 ingress for making Mtls working with the annotation above
    nginx.ingress.kubernetes.io/service-upstream: "true"
    nginx.ingress.kubernetes.io/upstream-vhost: productpage.test.svc.cluster.local
```

This will enable the traffic from the ingress to a service deployed in a namespace with a mTLS in STRICT mode