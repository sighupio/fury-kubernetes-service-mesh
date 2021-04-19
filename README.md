# Fury Kubernetes Service Mesh

This repository contains all needed components to deploy service meshes. We started integrating
[istio](https://istio.io/) into this module. [istio](https://istio.io/) addresses the challenges developers and
operators face as monolithic applications transition towards a distributed microservice architecture.


## Service Mesh Packages

Following packages are included in Fury Kubernetes Service Mesh katalog.

- [istio](katalog/istio): Istio provides behavioral insights and operational control over the service mesh as a whole,
offering a complete solution to satisfy the diverse requirements of microservice applications. It needs a two phase
installation. First run: [istio/init](katalog/istio/init) package. Once completed, you are ready to deploy
[istio](katalog/istio) package. Version: **1.4.2**.


## Requirements

All packages in this repository have following dependencies, for package specific dependencies please visit the
single package's documentation:

- [Kubernetes](https://kubernetes.io) >= `v1.14.0`
- [Furyctl](https://github.com/sighup-io/furyctl) package manager to install Fury packages
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) = `v3.9.1`


## Compatibility

| Module Version / Kubernetes Version | 1.14.X             | 1.15.X             | 1.16.X             | 1.17.X             | 1.18.X             | 1.19.X             | 1.20.X             | 1.21.X             |
|-------------------------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| v0.1.0                              |                    |                    |                    |
| v0.2.0                              | :exclamation: | :exclamation: | :exclamation: |
| v1.0.0                              |  |  |  | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark:

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible
- :exclamation: Deprecated

###  Deprecation Note
We had to deprecate those versions because of there was a very huge architectural change from istio 1.4 to 1.5. For every further help regarding upgrade from module version `v0.x.0` to `v.1.x.x` please contact us.


## Deployment (Istio getting started)

To start using Fury Kubernetes Service Mesh, you need to use
[furyctl](https://github.com/sighup-io/furyctl/blob/master/README.md) and create a `Furyfile.yml` with the list of
all the packages that you want to download.

```yaml
bases:
  - name: service-mesh/istio
    version: v0.2.0
```

and execute

```bash
$ furyctl install
```

to download the packages under `./vendor/katalog/service-mesh`.

See `furyctl`
[documentation](https://github.com/sighup-io/furyctl/blob/master/README.md) for details about `Furyfile.yml` format.

To deploy the packages to your cluster, define a `kustomization.yaml` with the
following content:

```yaml
bases:
  - ./vendor/katalog/service-mesh/istio/init
```

and execute
```shell
$ kustomize build . | kubectl apply -f -
$ kubectl -n istio-system wait --for=condition=complete job --all
```

to deploy Istio Custom Resource Definitions needed by Istio.

Now you can add the other packages to `kustomization.yaml`, the final file will have the following content:

```yaml
bases:
- ./vendor/katalog/service-mesh/istio/init
- ./vendor/katalog/service-mesh/istio
```

See `kustomize` [documentation](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/README.md) for details
about `kustomization.yaml` format.

To deploy all the packages to your cluster, execute the following command:
```bash
$ kustomize build . | kubectl apply -f -
```

If you need to customize our packages you can do it with `kustomize`. It lets you create customized Kubernetes
resources based on other Kubernetes resource files, leaving the original YAML untouched and usable as is.
To learn how to create you customization layer with it please see the `kustomize`
[repository](https://github.com/kubernetes-sigs/kustomize).

For further details please refer to the single package directories in this repository.

## Examples

In this repository are present some examples:

- [minimal](./examples/istio/minimal/kustomization.yaml)
   - minimal
   - sidecar-injection
- [minimal-and-egress](./examples/istio/minimal-and-egress/kustomization.yaml)
   - minimal
   - sidecar-injection/configuration/minimal-and-egress
   - egress-gateway
- [citadel](./examples/istio/citadel/kustomization.yaml)
   - minimal
   - sidecar-injection/configuration/citadel
   - citadel
- [sidecar-injection](./examples/istio/sidecar-injection/kustomization.yaml)
   - minimal
   - sidecar-injection
   - sidecar-injection/configuration/sidecar-injection
   - citadel
- [full](./examples/istio/full/kustomization.yaml)
   - minimal
   - egress-gateway
   - citadel
   - sidecar-injection
   - telemetry/service-monitor
   - kiali
   - sidecar-injection/configuration/sidecar-injection-and-egress
 

## License

For license details please see [LICENSE](LICENSE)
