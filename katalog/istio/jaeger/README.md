# Jaeger (Tracing)

This package enables jaeger (Tracing) in your current Istio setup. Take a look at the [Warning](#warning) information
to enable it.

## Warning

To enable `jaeger` in your current Istio setup, replace your `minimal` package with the `jaeger` one.
Then, replace your sidecar configuration package with the right one, choose the same one you already use
but with the `jaeger` string on it.

As an example, if you were using:

- `katalog/istio/sidecar-injection/configuration/citadel-and-egress`

move to:

- `katalog/istio/sidecar-injection/configuration/citadel-jaeger-and-egress`

Finally, apply both packages:

```bash
$ kustomize build katalog/istio/jaeger
$ katalog/istio/sidecar-injection/configuration/citadel-jaeger-and-egress
```

## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.3.0`
- [istio/init](../init)

## Included features

|                     | Installed          |
| ------------------- | ------------------ |
| **Core components** |                    |
| `istio-tracing`     | :white_check_mark: |

This component enables:

- *** Tracing:*** Distributed Tracing enables users to track a request through mesh that is distributed across 
multiple services. This allows a deeper understanding about request latency, serialization and parallelism via
visualization.


## Image repository and tag

* jaeger container image: `docker.io/jaegertracing/*`

Includes:

- docker.io/jaegertracing/all-in-one


## Deployment

You can deploy jaeger tracing by running the following command at the root of the project:

```shell
$ kustomize build katalog/istio/jaeger | kubectl apply -f -
$ katalog/istio/sidecar-injection/configuration/citadel-jaeger-and-egress | kubectl apply -f -
```

## License

For license details please see [LICENSE](../../../LICENSE)
