# Istio (Minimal)

Istio addresses the challenges developers and operators face as monolithic applications transition towards a
distributed microservice architecture. To see how, it helps to take a more detailed look at Istio’s service mesh.

The term service mesh is used to describe the network of microservices that make up such applications and the
interactions between them. As a service mesh grows in size and complexity, it can become harder to understand and
manage. Its requirements can include discovery, load balancing, failure recovery, metrics, and monitoring. A
service mesh also often has more complex operational requirements, like A/B testing, canary rollouts, rate limiting,
access control, and end-to-end authentication.

Istio provides behavioral insights and operational control over the service mesh as a whole, offering a complete
solution to satisfy the diverse requirements of microservice applications.

Source: [https://istio.io/docs](https://istio.io/docs/concepts/what-is-istio/#what-is-a-service-mesh)


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [init-istio](../init-istio/)
- [`prometheus-operator`](https://github.com/sighupio/fury-kubernetes-monitoring/tree/v1.3.0/katalog/prometheus-operator)
- [`prometheus-operated`](https://github.com/sighupio/fury-kubernetes-monitoring/tree/v1.3.0/katalog/prometheus-operated)


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-ingressgateway`   | :white_check_mark: |
| `istio-pilot`            | :white_check_mark: |
| `istio-policy`           | :white_check_mark: |


This components enables:

- ***Traffic Management:*** Istio’s traffic routing rules let you easily control the flow of traffic and API calls
between services:
  - **Virtual services:** Virtual services, along with destination rules, are the key building blocks of Istio’s
  traffic routing functionality. A virtual service lets you configure how requests are routed to a service within an
  Istio service mesh, building on the basic connectivity and discovery provided by Istio and your platform.
  - **Destination rules:** Along with virtual services, destination rules are a key part of Istio’s traffic routing
  functionality. You can think of virtual services as how you route your traffic to a given destination, and then you
  use destination rules to configure what happens to traffic for that destination.
  - **Gateways:** You use a gateway to manage inbound and outbound traffic for your mesh, letting you specify which
  traffic you want to enter or leave the mesh.
  **IMPORTANT NOTE** *(Only ingresss gateway is deployed with the current version)*
  - **Service entries:** You use a service entry to add an entry to the service registry that Istio maintains
  internally
  - **Sidecars:** You can use a sidecar configuration to do the following:
    - Fine-tune the set of ports and protocols that an Envoy proxy accepts.
    - Limit the set of services that the Envoy proxy can reach.
- ***Network resilience and testing:*** Istio provides opt-in failure recovery and fault injection features that you
can configure dynamically at runtime.
  - **Timeouts:** A timeout is the amount of time that an Envoy proxy should wait for replies from a given service,
  ensuring that services don’t hang around waiting for replies indefinitely and that calls succeed or fail within a
  predictable timeframe.
  - **Retries:** A retry setting specifies the maximum number of times an Envoy proxy attempts to connect to a service
  if the initial call fails.
  - **Circuit breakers:** In a circuit breaker, you set limits for calls to individual hosts within a service, such
  as the number of concurrent connections or how many times calls to this host have failed.
  - **Fault injection:** Fault injection is a testing method that introduces errors into a system to ensure that it
  can withstand and recover from error conditions.
- ***Policies:*** Istio lets you configure custom policies for your application to enforce rules at runtime such as:
  - Rate limiting to dynamically limit the traffic to a service
  - Denials, whitelists, and blacklists, to restrict access to services
  - Header rewrites and redirects

## Image repository and tag

All istio container images are currently available at dockerhub: [docker.io/istio](https://hub.docker.com/u/istio)

* istio container images: `docker.io/istio/*`

Includes:

- docker.io/istio/proxyv2
- docker.io/istio/mixer
- docker.io/istio/pilot

* addons container images:

- Kiali: quay.io/kiali/kiali:v1.9

## Deployment

You can deploy istio by running following command in the root of the project:

```shell
$ kustomize build | kubectl apply -f -
```

### Configuration

#### Kiali

##### Admin user

We provide an administrator user *(admin:admin)* to access the kiali dashboard. Please change the default password
editing the `kiali` secret inside the `istio-system` namespace.

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

##### Prometheus URL

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

For license details please see [LICENSE](../../LICENSE)
