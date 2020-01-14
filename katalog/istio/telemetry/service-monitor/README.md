# Istio Telemetry - Service Monitors

Istio generates detailed telemetry for all service communications within a mesh. If the cluster has a `prometheus` 
server deployed with `prometheus-operator`, this package will configure `service-monitor` objects to gather telemetry metrics information storing it in `prometheus`.


## Requirements

- Kubernetes >= `1.14.0`
- [Prometheus Operator](https://github.com/sighupio/fury-kubernetes-monitoring/tree/v1.3.0/katalog/prometheus-operator)
- Kustomize = `v3.0.0`
- [istio/init](../../init)
- [istio/minimal](../../minimal)


## Included monitors

- istio-mesh-monitor
- istio-component-monitor
- envoy-stats-monitor
- kubernetes-pods-monitor
- kubernetes-services-monitor
- kubelet


## Deployment

You can deploy serive-monitor + telemetry by running following command in the root of the project:

```shell
$ kustomize build katalog/istio/telemetry/service-monitor | kubectl apply -f -
```


### Note

If you have already deployed [telemetry](../../telemetry):
Replace it in the `kustomization.yaml` base list with  `katalog/istio/telemetry/service-monitor`.

```yaml
bases:
  - ../vendor/katalog/service-mesh/istio/init
  - ../vendor/katalog/service-mesh/istio
  - ../vendor/katalog/monitoring/prometheus-operator
# Replace telemetry
#  - ../vendor/katalog/service-mesh/istio/telemetry
# with the telemetry+service-monitor package
  - ../vendor/katalog/service-mesh/istio/telemetry/service-monitor
```


## License

For license details please see [LICENSE](../../../../LICENSE)
