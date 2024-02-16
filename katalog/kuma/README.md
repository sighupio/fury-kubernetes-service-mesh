# Kuma

Kuma is a platform agnostic open-source control plane for service mesh and microservices management, with support for Kubernetes, VM, and bare metal environments.

## Requirements

- Kubernetes >= `1.14.0`
- Kustomize >= `v3.6.1`
- [cert-manager](https://github.com/sighupio/fury-kubernetes-ingress/tree/master/katalog/cert-manager)

> Cert Manager is required since we need TLS certificates to be injected in data planes

## Image repository and tag

* Kuma Control Plane: `docker.io/kumahq/kuma-cp`
* Kuma Data Plane: `docker.io/kumahq/kuma-dp`
* Kuma Prometheus Service Discovery: `docker.io/kumahq/kuma-prometheus-sd`
* Kuma Init: `docker.io/kumahq/kuma-init`

## Deployment

Before deploy, you have to create some resources: follow the [example](../../examples/kuma/multi-cluster/README.md) to learn how.

