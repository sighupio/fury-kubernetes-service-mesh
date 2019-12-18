# Sidecar Injector

Sidecars can be automatically added to applicable Kubernetes pods using a mutating webhook admission controller
provided by Istio.
When the injection webhook is enabled, any new pods that are created will automatically have a sidecar added to them.

> While admission controllers are enabled by default, some Kubernetes distributions may disable them. If this is the
case, follow the instructions to turn on admission controllers.

*Source: [https://istio.io/docs](https://istio.io/docs/setup/additional-setup/sidecar-injection/#automatic-sidecar-injection)*


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [init istio](../init/)
- [minimal istio](../minimal/)
- [citadel](../citadel/)
- [citadel istio sidecar injector configuration](../sidecar-injection/configuration/sidecar-injection)


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-sidecar-injector` | :white_check_mark: |


## Image repository and tag

All istio container images are currently available at dockerhub: [docker.io/istio](https://hub.docker.com/u/istio)

* istio container images: `docker.io/istio/*`

Includes:

- docker.io/istio/citadel

## Deployment

You can deploy citadel by running following command in the root of this project:

```shell
$ kustomize build katalog/istio/sidecar-injection | kubectl apply -f -
$ kustomize build katalog/istio/sidecar-injection/configuration/sidecar-injection-and-egress | kubectl apply -f -
```

### Configuration

As this is a core part of any istio deployment, the istio configuration has to be modified. You can find the new
configuration values in the
[sidecar configuration patch](../sidecar-injection/configuration/sidecar-injection/patch.yaml).

You have to apply it using:

```shell
$ kustomize build ../sidecar-injection/configuration/sidecar-injection | kubectl apply -f -
```

Be sure to choose the correct sidecar-injection configuration.


## License

For license details please see [LICENSE](../../../LICENSE)
