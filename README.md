<h1>
    <img src="https://github.com/sighupio/fury-distribution/blob/master/docs/assets/fury-epta-white.png?raw=true" align="left" width="90" style="margin-right: 15px"/>
    Kubernetes Fury Service Mesh
</h1>

![Release](https://img.shields.io/github/v/release/sighupio/fury-kubernetes-service-mesh?label=Latest%20Release)
![License](https://img.shields.io/github/license/sighupio/fury-kubernetes-service-mesh?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <KFD-DOCS> -->

**Kubernetes Fury Service Mesh** add-on module for the [Kubernetes Fury Distribution (KFD)][kfd-repo] allows to transparently add capabilities like observability, traffic management, and security to applications, without modifying their source code.

If you are new to KFD please refer to the [official documentation][kfd-docs] on how to get started with KFD.

## Overview

**Kubernetes Fury Service Mesh** add-on module deploys a service mesh into a Kubernetes cluster. A service mesh, such as Istio, allows to transparently add capabilities like observability, traffic management, and security to applications, without modifying their source code. These capabilities are of great value when running microservices at scale or under strict security requirements.

This module is based on the Istio Project. Istio provides behavioral insights and operational control over the service mesh as a whole, offering a complete solution to satisfy the diverse requirements of microservice applications.

Read more on [Istio's documentation site][istio-docs-site].

## Packages

Kubernetes Fury Service Mesh provides the following packages:

| Package                                    | Version   | Description                                                                                                                   |
|--------------------------------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| [Istio Operator](katalog/istio-operator) | `v1.9.5` | Istio Service Mesh Operator package. Including the Istio Operator itself, the Jeager Operator, and Kiali. Includes 3 different profiles: `minimal`, `tracing` and `full`.|

## Compatibility

| Kubernetes Version |   Compatibility    |                        Notes                        |
| ------------------ | :----------------: | --------------------------------------------------- |
| `1.18.x`           | :white_check_mark: | No known issues                                     |
| `1.19.x`           | :white_check_mark: | No known issues                                     |
| `1.20.x`           | :white_check_mark: | No known issues                                     |

Check the [compatibility matrix][compatibility-matrix] for additional information about previous releases of the modules.

## Usage

### Prerequisites

| Tool                                    | Version    | Description                                                                                                                                                    |
|-----------------------------------------|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [furyctl][furyctl-repo]                 | `>=0.6.0`  | The recommended tool to download and manage KFD modules and their packages. To learn more about `furyctl` read the [official documentation][furyctl-repo].     |
| [kustomize][kustomize-repo]             | `>=3.9.1`  | Packages are customized using `kustomize`. To learn how to create your customization layer with `kustomize`, please refer to the [repository][kustomize-repo]. |

### Deployment

1. To start using Kubernetes Fury Service Mesh, add to your `Furyfile.yml` the module as a base, you can also specify the single package:

```yaml
bases:
    - name: service-mesh/istio-operator
      version: v1.0.1
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

<!-- links -->
[kfd-repo]: https://github.com/sighupio/fury-distribution
[istio-docs-site]: https://istio.io/latest/about/service-mesh/

[furyctl-repo]: https://github.com/sighupio/furyctl
[sighup-page]: https://sighup.io
[kustomize-repo]: https://github.com/kubernetes-sigs/kustomize
[kfd-docs]: https://docs.kubernetesfury.com/docs/distribution/
[compatibility-matrix]: https://github.com/sighupio/fury-kubernetes-service-mesh/blob/master/docs/COMPATIBILITY_MATRIX.md
<!-- </KFD-DOCS> -->

<!-- <FOOTER> -->
## Contributing

Before contributing, please read first the [Contributing Guidelines](docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/fury-kubernetes-service-mesh/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)
<!-- </FOOTER> -->
