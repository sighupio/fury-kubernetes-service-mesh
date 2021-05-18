# Fury Kubernetes Service Mesh

This repository contains all needed components to deploy service meshes. We started integrating
[istio](https://istio.io/) into this module. [istio](https://istio.io/) addresses the challenges developers and
operators face as monolithic applications transition towards a distributed microservice architecture.


## Service Mesh Packages

Following packages are included in Fury Kubernetes Service Mesh katalog.

- [istio](katalog/istio): Istio provides behavioral insights and operational control over the service mesh as a whole,
offering a complete solution to satisfy the diverse requirements of microservice applications. It needs a two phase
installation. First run: [istio/init](katalog/istio/init) package. Once completed, you are ready to deploy
[istio](katalog/istio) package. Version: **1.9.5**.


## Requirements

All packages in this repository have following dependencies, for package specific dependencies please visit the
single package's documentation:

- [Kubernetes](https://kubernetes.io) >= `v1.17.0`
- [Furyctl](https://github.com/sighup-io/furyctl) package manager to install Fury packages
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) = `v3.9.1`


## Compatibility

| Module Version / Kubernetes Version |    1.14.X     |    1.15.X     |    1.16.X     |       1.17.X       |       1.18.X       |       1.19.X       |       1.20.X       | 1.21.X |
| ----------------------------------- | :-----------: | :-----------: | :-----------: | :----------------: | :----------------: | :----------------: | :----------------: | :----: |
| v0.1.0                              |               |               |               |
| v0.2.0                              | :exclamation: | :exclamation: | :exclamation: |
| v1.0.0                              |               |               |               | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible
- :exclamation: Deprecated

###  Deprecation Note
We had to deprecate those versions because of there was a very huge architectural change from istio 1.4 to 1.5. 
For every further help regard upgrade from module version `v0.x.0` to `v1.x.x` please contact us.


## Deployment (Istio getting started)

To start using Fury Kubernetes Service Mesh, you need to use
[furyctl](https://github.com/sighup-io/furyctl/blob/master/README.md) and create a `Furyfile.yml` with the list of
all the packages that you want to download.

```yaml
bases:
  - name: service-mesh/istio
    version: v1.0.0
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
  - ./vendor/katalog/service-mesh/istio-operator/profiles/minimal
```

and execute
```shell
$ kustomize build . | kubectl apply -f -
```

For further details please refer to the single package directories in this repository.

## License

For license details please see [LICENSE](LICENSE)
