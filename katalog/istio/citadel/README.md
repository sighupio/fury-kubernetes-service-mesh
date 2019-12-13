# Citadel

Citadel features provide strong identity, powerful policy, transparent TLS encryption, and authentication,
authorization and audit (AAA) tools to protect your services and data. The goals of Istio security are:

- Security by default: no changes needed for application code and infrastructure
- Defense in depth: integrate with existing security systems to provide multiple layers of defense
- Zero-trust network: build security solutions on untrusted networks

Source: [https://istio.io/docs](https://istio.io/docs/concepts/security/)


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`
- [init istio](../init/)
- [minimal istio](../minimal/)
- [citadel istio sidecar injector configuration](../sidecar-injector-config/citadel)


## Included features

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-citadel`          | :white_check_mark: |


This component enable:

- ***Authentication:*** Istio provides two types of authentication:
  - **Transport authentication:** also known as service-to-service authentication: verifies the direct client making
  the connection. Istio offers mutual TLS as a full stack solution for transport authentication. You can easily turn
  on this feature without requiring service code changes.
  - **Origin authentication:** also known as end-user authentication: verifies the original client making the request
  as an end-user or device. Istio enables request-level authentication with JSON Web Token (JWT) validation.
- ***Authorization:*** Istio’s authorization feature provides mesh-level, namespace-level, and workload-level access
  control on workloads in an Istio Mesh. It provides:
  - Workload-to-workload and end-user-to-workload authorization.
  - A Simple API, it includes a single AuthorizationPolicy CRD, which is easy to use and maintain.
  - Flexible semantics, operators can define custom conditions on Istio attributes.
  - High performance, as Istio authorization is enforced natively on Envoy.
  - High compatibility, supports HTTP, HTTPS and HTTP2 natively, as well as any plain TCP protocols.


## Image repository and tag

All istio container images are currently available at dockerhub: [docker.io/istio](https://hub.docker.com/u/istio)

* istio container images: `docker.io/istio/*`

Includes:

- docker.io/istio/citadel

## Deployment

You can deploy citadel by running following command in the root of this project:

```shell
$ kustomize build | kubectl apply -f -
$ kustomize build ../sidecar-injector-config/citadel | kubectl apply -f -
```

### Configuration

As this is a core part of any istio deployment, the istio configuration has to be modified. You can find the new
configuration values in the [sidecar configuration patch](../sidecar-injector-config/citadel/patch.yaml).

You have to apply it using:

```shell
$ kustomize build ../sidecar-injector-config/citadel | kubectl apply -f -
```


## License

For license details please see [LICENSE](../../../LICENSE)
