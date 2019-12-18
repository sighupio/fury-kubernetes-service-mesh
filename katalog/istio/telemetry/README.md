# Istio Telemetry

Istio generates detailed telemetry for all service communications within a mesh. This telemetry
provides observability of service behavior, empowering operators to troubleshoot, maintain, and optimize their
applications – without imposing any additional burdens on service developers.


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [istio/init](../init)
- [istio/minimal](../minimal)


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-telemetry`        | :white_check_mark: |

This component enables:

***Observability:*** This telemetry provides observability of service behavior, empowering operators to troubleshoot,
maintain, and optimize their applications – without imposing any additional burdens on service developers.
  - **Metrics:** Metrics provide a way of monitoring and understanding behavior in aggregate.
  - **Logs:** Access logs provide a way to monitor and understand behavior from the perspective of an individual
  workload instance.
  - **Tracing:** Distributed tracing provides a way to monitor and understand behavior by monitoring individual
  requests as they flow through a mesh.


## Image repository and tag

All istio container images are currently available at dockerhub: [docker.io/istio](https://hub.docker.com/u/istio)

* istio container images: `docker.io/istio/*`

Includes:

- docker.io/istio/proxyv2
- docker.io/istio/mixer


## Deployment

You can deploy telemetry by running following command in the root of the project:

```shell
$ kustomize build katalog/istio/telemetry | kubectl apply -f -
```


## License

For license details please see [LICENSE](../../../LICENSE)
