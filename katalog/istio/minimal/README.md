# Istio (Minimal)

As described [before](../../istio/README.md#modular), this [Istio](../../istio) package has been designed to make it
easy the Istio adoption.
This package is a good starting point to understand what Istio provides with a limited amount of features.
Once installed, the cluster will have a working Istio distribution.


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [istio/init](../init)


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
  **IMPORTANT NOTE** *(Only ingresss gateway is deployed with the minimal package)*
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


## Deployment

You can deploy istio by running following command in the root of the project:

```shell
$ kustomize build katalog/istio | kubectl apply -f -
```

or

```shell
$ kustomize build katalog/istio/minimal | kubectl apply -f -
$ kustomize build katalog/istio/sidecar-injection/configuration/minimal | kubectl apply -f -
```

## Additional configuration

- [Configure a TLS ingress gateway with a file mount-based approach](https://istio.io/docs/tasks/traffic-management/ingress/secure-ingress-mount/#configure-a-tls-ingress-gateway-with-a-file-mount-based-approach)


## License

For license details please see [LICENSE](../../../LICENSE)
