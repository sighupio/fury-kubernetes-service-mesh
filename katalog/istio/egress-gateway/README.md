# Istio Egress Gateway

An egress gateway lets you configure a dedicated exit node for the traffic leaving the mesh, letting you limit which
services can or should access external networks, or to enable secure control of egress traffic to add security to your
mesh, for example.

*source: [https://istio.io/docs/concepts/traffic-management/#gateways](https://istio.io/docs/concepts/traffic-management/#gateways)*


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [istio/init](../init)
- [istio/minimal](../minimal)


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-egressgateway`    | :white_check_mark: |

This component enables:

- ***Traffic Management:*** Istio’s traffic routing rules let you easily control the flow of traffic and API calls
between services:
  - **Gateways:** You use a gateway to manage inbound and outbound traffic for your mesh, letting you specify which
  traffic you want to enter or leave the mesh.


## Image repository and tag

All istio container images are currently available at dockerhub: [docker.io/istio](https://hub.docker.com/u/istio)

* istio container images: `docker.io/istio/*`

Includes:

- docker.io/istio/proxyv2


## Deployment

You can deploy istio egress-gateway by running following command in the root of the project:

```shell
$ kustomize build katalog/istio/egress-gateway | kubectl apply -f -
$ kustomize build katalog/istio/sidecar-injection/configuration/minimal-and-egress | kubectl apply -f -
```


### Note

If you have already deployed [istio](../../istio):
Replace it in the `kustomization.yaml` base list with  `katalog/istio/istio/minimal`.

```yaml
bases:
  - ../vendor/katalog/service-mesh/istio/init
# Replace Istio
#   - ../vendor/katalog/service-mesh/istio
# with the istio minimal package
  - ../vendor/katalog/service-mesh/istio/minimal
  - ../vendor/katalog/monitoring/prometheus-operator
  - ../vendor/katalog/service-mesh/istio/telemetry/service-monitor
  - ../vendor/katalog/service-mesh/istio/egress-gateway
  - ../vendor/katalog/service-mesh/istio/sidecar-injection/configuration/minimal-and-egress
```


## License

For license details please see [LICENSE](../../../LICENSE)
