<!-- markdownlint-disable MD033 -->
<h1>
    <img src="https://github.com/sighupio/fury-distribution/blob/main/docs/assets/fury-epta-white.png?raw=true" align="left" width="90" style="margin-right: 15px"/>
    Kubernetes Fury Service Mesh
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/badge/Latest%20Release-v1.2.0-blue)
![License](https://img.shields.io/github/license/sighupio/fury-kubernetes-service-mesh?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <KFD-DOCS> -->

**Kubernetes Fury Service Mesh** add-on module for the [Kubernetes Fury Distribution (KFD)][kfd-repo] allows to transparently add capabilities like observability, traffic management, and security to applications, without modifying their source code.

If you are new to KFD please refer to the [official documentation][kfd-docs] on how to get started with KFD.

## Overview

**Kubernetes Fury Service Mesh** add-on module deploys a service mesh into a Kubernetes cluster. A service mesh, such as Istio, allows to transparently add capabilities like observability, traffic management, and security to applications, without modifying their source code. These capabilities are of great value when running microservices at scale or under strict security requirements.

### Istio

This module features the Istio Project. Istio provides behavioral insights and operational control over the service mesh as a whole, offering a complete solution to satisfy the diverse requirements of microservice applications.

Read more on [Istio's documentation site][istio-docs-site].

### Kuma

This module features Kuma Service Mesh. It's a modern control plane for microservices and service mesh for Kubernetes and VMs, with support for multiple meshes in one cluster.

Read more on [Kuma docs][kuma-docs-site].

### Kong Mesh

Kong Mesh is an enterprise-grade service mesh built on top of Kuma. 

Read more on [Kong Mesh docs][kong-mesh-docs-site].

## Packages

Kubernetes Fury Service Mesh provides the following packages:

| Package                                  | Version   | Description                                                                                                                                                               |
| ---------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Istio Operator](katalog/istio-operator) | `v1.19.6` | Istio Service Mesh Operator package. Including the Istio Operator itself, the Jeager Operator, and Kiali. Includes 3 different profiles: `minimal`, `tracing` and `full`. |
| [Kong Mesh](katalog/kong-mesh) | `v2.4.3` | Kong Mesh package. Includes `standalone` and `multi-cluster` setup. |
| [Kuma](katalog/kuma) | `v2.4.3` | Kuma package. Includes `standalone` and `multi-cluster` setup. |

## Compatibility

| Kubernetes Version |   Compatibility    | Notes           |
| ------------------ | :----------------: | --------------- |
| `1.24.x`           | :white_check_mark: | No known issues |
| `1.25.x`           | :white_check_mark: | No known issues |
| `1.26.x`           | :white_check_mark: | No known issues |
| `1.27.x`           | :white_check_mark: | No known issues |

Check the [compatibility matrix][compatibility-matrix] for additional information about previous releases of the modules.

## Usage

### Prerequisites

| Tool                                    | Version    | Description                                                                                                                                                    |
| --------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [furyctl][furyctl-repo]                 | `>=0.6.0`  | The recommended tool to download and manage KFD modules and their packages. To learn more about `furyctl` read the [official documentation][furyctl-repo].     |
| [kustomize][kustomize-repo]             | `>=3.9.1`  | Packages are customized using `kustomize`. To learn how to create your customization layer with `kustomize`, please refer to the [repository][kustomize-repo]. |
| [KFD Monitoring Module][kfd-monitoring] | `>=1.11.1` | To have functioning metrics, dashboards and alerts. Prometheus Operator is also required by Kiali.                                                             |
| [KFD Logging Module][kfd-logging]       | `>=1.7.1`  | When using tracing, ElasticSearch / OpenSearch is used as storage.                                                                                             |

### Istio deployment

1. To start using Kubernetes Fury Service Mesh, add to your `Furyfile.yml` the module as a base, you can also specify the single package:

```yaml
bases:
    - name: service-mesh/istio-operator
      version: v2.0.0
```

> See `furyctl` [documentation][furyctl-repo] for additional details about `Furyfile.yml` format.

2. Execute the following command to download the packages to your machine:

```bash
furyctl vendor -H
```

3. Inspect the downloaded packages under `./vendor/katalog/service-mesh` to get familiar with the content.

4. Define a `kustomization.yaml` with that includes the `./vendor/katalog/service-mesh` directory as a resource:

```yaml
resources:
    - ./vendor/katalog/service-mesh/istio-operator/profiles/minimal
```

> You can point to one of the predefined profiles (`minimal`, `tracing` or `full`) here.

5. Finally, to deploy the selected profile to your cluster, execute:

```shell
kustomize build . | kubectl apply -f -
```

For further details please refer to each package's directory in this repository.

### Istio Monitoring

The Service Mesh Module not only provides you with Kiali to visualize the status of the service mesh from a UI, but also includes metrics, dashboards and alerts for Istio's components out-of-the-box.

You can monitor the status of Istio, the service-mesh itself and its components from the provided Grafana Dashboards. Here are some screenshots:

<!-- markdownlint-disable MD033 -->
<a href="docs/images/screenshots/kiali.png"><img src="docs/images/screenshots/kiali.png" width="250"/></a>
<a href="docs/images/screenshots/istio-control-plane-dashboard.png"><img src="docs/images/screenshots/istio-control-plane-dashboard.png" width="250"/></a>
<a href="docs/images/screenshots/istio-mesh-darshboard.png"><img src="docs/images/screenshots/istio-mesh-darshboard.png" width="250"/></a>
<a href="docs/images/screenshots/istio-service-dashboard.png"><img src="docs/images/screenshots/istio-service-dashboard.png" width="250"/></a>
<a href="docs/images/screenshots/istio-workload-dashboard.png"><img src="docs/images/screenshots/istio-workload-dashboard.png" width="250"/></a>
<!-- markdownlint-enable MD033 -->

> click on each screenshot for the full screen version

The following set of alerts is included:

| Alert Name                         | Summary                                                                                                                                             | Description                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| IstioMetricsMissing                | Istio Metrics missing                                                                                                                               | [Critical]: Check prometheus deployment or whether the prometheus filters are applied correctly |
| HTTP5xxRateHigh                    | 5xx rate too high                                                                                                                                   | The HTTP 5xx errors rate higher than 0.05 in 5 mins                                             |
| WorkloadLatencyP99High             | -                                                                                                                                                   | The workload request latency P99 > 160ms                                                        |
| IngressLatencyP99High              | -                                                                                                                                                   | The ingress latency P99 > 250ms                                                                 |
| ProxyContainerCPUUsageHigh         | Proxy Container CPU usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }})  VALUE = {{ $value }}.    | Proxy Container CPU usage is above 80%                                                          |
| ProxyContainerMemoryUsageHigh      | Proxy Container Memory usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }})  VALUE = {{ $value }}. | Proxy Container Memory usage is above 80%                                                       |
| IngressMemoryUsageIncreaseRateHigh | Ingress proxy Memory change rate, VALUE = {{ $value }}.                                                                                             | Ingress proxy Memory Usage increases more than 200 Bytes/sec                                    |
| IstiodContainerCPUUsageHigh        | Istiod Container CPU usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }}) VALUE = {{ $value }}.    | Isitod Container CPU usage is above 80%                                                         |
| IstiodMemoryUsageHigh              | Istiod Container Memory usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }}) VALUE = {{ $value }}. | Istiod Container Memory usage is above 80%                                                      |
| IstiodMemoryUsageIncreaseRateHigh  | Istiod Container Memory usage increase rate high, VALUE = {{ $value }}.                                                                             | Istiod Container Memory usage increases more than 1k Bytes/sec                                  |
| IstiodxdsPushErrorsHigh            | istiod push errors is too high                                                                                                                      | istiod push error rate is higher than 0.05                                                      |
| IstiodxdsRejectHigh                | istiod rejects rate is too high                                                                                                                     | istiod rejects rate is higher than 0.05                                                         |
| IstiodContainerNotReady            | istiod container not ready                                                                                                                          | container: discovery not running                                                                |
| IstiodUnavailableReplica           | Istiod unavailable pod                                                                                                                              | Istiod unavailable replica > 0                                                                  |
| Ingress200RateLow                  | ingress gateway 200 rate drops                                                                                                                      | The expected rate is 100 per ns, the limit is set based on 15ns                                 |

### Kuma deployment

1. To start using Kubernetes Fury Service Mesh, add to your `Furyfile.yml` the module as a base, you can also specify the single package:

```yaml
bases:
    - name: service-mesh/kuma
      version: v2.0.0
```

> See `furyctl` [documentation][furyctl-repo] for additional details about `Furyfile.yml` format.

2. Execute the following command to download the packages to your machine:

```bash
furyctl vendor -H
```

3. Inspect the downloaded packages under `./vendor/katalog/service-mesh` to get familiar with the content.

4. Define a `kustomization.yaml` with that includes the `./vendor/katalog/service-mesh` directory as a resource:

```yaml
resources:
    - ./vendor/katalog/service-mesh/kuma/standalone
```

> You can point to one of the predefined setups (`standalone`, `multi-cluster/global-control-plane` or `multi-cluster/zone-control-plane`) here.

> For additional details follow the [examples](examples/kuma/multi-cluster/README.md).

### Kong Mesh deployment

1. To start using Kubernetes Fury Service Mesh, add to your `Furyfile.yml` the module as a base, you can also specify the single package:

```yaml
bases:
    - name: service-mesh/kong-mesh
      version: v2.0.0
```

> See `furyctl` [documentation][furyctl-repo] for additional details about `Furyfile.yml` format.

2. Execute the following command to download the packages to your machine:

```bash
furyctl vendor -H
```

3. Inspect the downloaded packages under `./vendor/katalog/service-mesh` to get familiar with the content.

4. Define a `kustomization.yaml` with that includes the `./vendor/katalog/service-mesh` directory as a resource:

```yaml
resources:
    - ./vendor/katalog/service-mesh/kuma/standalone
```

> You can point to one of the predefined setups (`standalone`, `multi-cluster/global-control-plane` or `multi-cluster/zone-control-plane`) here.

> For additional details follow the [examples](examples/kong-mesh/multi-cluster/README.md).

> :warning: You will need a valid license to use Kong Mesh. If you don't have it, please use Kuma instead.

<!-- links -->
[kfd-repo]: https://github.com/sighupio/fury-distribution
[istio-docs-site]: https://istio.io/latest/about/service-mesh/
[kuma-docs-site]: https://kuma.io/docs
[kong-mesh-docs-site]: https://docs.konghq.com/mesh/latest/
[furyctl-repo]: https://github.com/sighupio/furyctl
[kustomize-repo]: https://github.com/kubernetes-sigs/kustomize
[kfd-docs]: https://docs.kubernetesfury.com/docs/distribution/
[compatibility-matrix]: https://github.com/sighupio/fury-kubernetes-service-mesh/blob/master/docs/COMPATIBILITY_MATRIX.md

[kfd-monitoring]: https://github.com/sighupio/fury-kubernetes-monitoring
[kfd-logging]: https://github.com/sighupio/fury-kubernetes-logging
<!-- </KFD-DOCS> -->

<!-- <FOOTER> -->
## Contributing

Before contributing, please read first the [Contributing Guidelines](docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problems with the module, please [open a new issue](https://github.com/sighupio/fury-kubernetes-service-mesh/issues/new/choose).

### Kong Mesh

Refer to [./docs/kong-mesh/README.md](./docs/kong-mesh/README.md)

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)
<!-- </FOOTER> -->
