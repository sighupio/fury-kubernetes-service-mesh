# Istio

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


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-citadel`          |                    |
| `istio-egressgateway`    |                    |
| `istio-galley`           |                    |
| `istio-ingressgateway`   | :white_check_mark: |
| `istio-nodeagent`        |                    |
| `istio-pilot`            | :white_check_mark: |
| `istio-policy`           | :white_check_mark: |
| `istio-sidecar-injector` |                    |
| `istio-telemetry`        |                    |
| **Addons**               |                    |
| `grafana`                |                    |
| `istio-tracing`          |                    |
| `kiali`                  |                    |
| `prometheus`             |                    |


## Image repository and tag

All istio container images are currently available at dockerhub. docker.io/istio

* istio container images: `docker.io/istio/*`

Includes:

- docker.io/istio/citadel
- docker.io/istio/kubectl
- docker.io/istio/galley
- docker.io/istio/proxyv2
- docker.io/istio/mixer
- docker.io/istio/pilot
- docker.io/istio/sidecar_injector

## Deployment

You can deploy istio by running following command in the root of the project:

```shell
$ kustomize build | kubectl apply -f -
```

## License

For license details please see [LICENSE](../../LICENSE)
