# Istio

- [Istio](#istio)
  - [Requirements](#requirements)
  - [Modular design](#modular-design)
    - [Minimal installation](#minimal-installation)
    - [Telemetry](#telemetry)
      - [Service Monitors](#service-monitors)
        - [Note](#note)
    - [Egress Gateway](#egress-gateway)
    - [Citadel](#citadel)
        - [Note](#note-1)
    - [Sidecar injector](#sidecar-injector)
        - [Note](#note-2)
    - [Kiali](#kiali)
      - [Configuration](#configuration)

___

Istio addresses the challenges developers and operators face as monolithic applications transition towards a
distributed microservice architecture, in the following sections we got deeper into Istio service mesh's details to
see how this is achieved.

The term service mesh is used to describe the network of microservices that make up such applications and the
interactions between them. As a service mesh grows in size and complexity, it can become harder to understand and
manage. Its requirements can include discovery, load balancing, failure recovery, metrics, and monitoring. A
service mesh also often has more complex operational requirements, like A/B testing, canary rollouts, rate limiting,
access control, and end-to-end authentication.

Istio provides behavioral insights and operational control over the service mesh as a whole, offering a complete
solution to satisfy the diverse requirements of microservice applications.

Source: [https://istio.io/docs](https://istio.io/docs/concepts/what-is-istio/#what-is-a-service-mesh)


## Requirements

In order to install the Istio package, it's required to have installed the [init](./init/README.md) package.
This is the one involved in the Istio CRDs creation.

```bash
$ kustomize build katalog/istio/init | kubectl apply -f -
$ kubectl -n istio-system wait --for=condition=complete job --all
job.batch/istio-init-crd-10-1.4.2 condition met
job.batch/istio-init-crd-11-1.4.2 condition met
job.batch/istio-init-crd-14-1.4.2 condition met
```

Once installed, the cluster will be ready to install the [minimal](#minimal-installation) Istio deployment.


## Modular design

Istio has a lot of features powered by a high number of pieces. This package has been designed to be installed from the
minimal installation providing basic features like traffic routing to a more complex deployment including
more features.


### Minimal installation

The [minimal](minimal/README.md) deployment is a perfect starting point to to get familiar with Istio. It deploys the
basic components that empowers features like traffic management, network resilience and testing and policies.

This package is the base where different components will be plugged.

[Example kustomize installation file](../../examples/istio/minimal/kustomization.yaml):

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio
```

### Telemetry

[Telemetry](telemetry/README.md) is the istio component involved in the process of metric recollection.

Example kustomize installation file:

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio
  - katalog/istio/telemetry
```

#### Service Monitors

As telemetry exposes metrics in prometheus format, this package provides [service-monitor](telemetry/service-monitor) definition for prometheus operator.

Example kustomize installation file:

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio
  - katalog/istio/telemetry/service-monitor
```

##### Note

This package will deploy telemetry + service monitors. If telemetry it's already deployed, replace the telemetry base
with the `katalog/istio/telemetry/service-monitor` base.


### Egress Gateway

This package deploys on top of the [minimal installation](#minimal-installation),
[the egress gateway component](egress-gateway/README.md).

Once deployed this package, don't forget to deploy the new Istio configuration based on the components installed:

[Example kustomize installation file](../../examples/istio/minimal-and-egress/kustomization.yaml):

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio/minimal
  - katalog/istio/egress-gateway
  - katalog/istio/sidecar-injection/configuration/minimal-and-egress
```

### Citadel

[Citadel](citadel/README.md) is the Istio component in charge of provide security features *(key and certificate management)*.
If you are looking for mTLS, this is the component you should install.

As the other components, this one should be installed on top of the minimal istio deployment.

Example kustomize installation file:

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio/minimal
  - katalog/istio/citadel
  - katalog/istio/egress-gateway
  - katalog/istio/sidecar-injection/configuration/citadel-and-egress
```

With the previous example snippet you will get `istio` with `citadel`, `egress gateway` and `sidecar injector`
packages installed.

##### Note

Make sure to deploy the correct `sidecar-injection/configuration` kustomize project. In this example the correct
configuration is the one with [citadel + egress](sidecar-injection/configuration/citadel-and-egress).


### Sidecar injector

[Sidecar injector](sidecar-injection/README.md) is the component responsible of injecting the envoy proxy on every
required pod. This is the alternative of executing `istioctl inject` comamnds.

Sidecar injector package requires [citadel](citadel/README.md) installed.

Example kustomize installation file:

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio/minimal
  - katalog/istio/citadel
  - katalog/istio/egress-gateway
  - katalog/istio/sidecar-injection
  - katalog/istio/sidecar-injection/configuration/sidecar-injection-and-egress
```

With the previous example snippet you will get istio with citadel, egress gateway, sidecar injector packages installed.

##### Note

Make sure to deploy the correct `sidecar-injection/configuration` kustomize project. In this example the correct
configuration is the one with [sidecar-injector + egress](sidecar-injection/configuration/sidecar-injection-and-egress).

### Kiali

[Kiali](kiali/README) is a project that implements an observability console for Istio. It helps you to understand the
structure of your service mesh by inferring the topology, the health of your mesh and see detailed metrics. Distributed
tracing is provided by integrating Jaeger.

In order to run Kiali the telemetry package must be installed previously and optionally the service-monitor subpackage
to enable.

Example kustomize installation file:

```yaml
namespace: istio-system

bases:
  - katalog/istio/init
  - katalog/istio/minimal
  # - katalog/istio/telemetry
  # Will help if you have prometheus-operator deployed
  - katalog/istio/telemetry/service-monitor
  - katalog/istio/kiali
  - katalog/istio/sidecar-injection/configuration/minimal
```

#### Configuration

Kiali is configured with some default *(unsecure)* configuration. Please go to the [Kiali package documentation](kiali/README.md#configuration) to know how to change it.
