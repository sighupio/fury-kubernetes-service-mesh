# Init Istio package

Package containing Istio CRDs. This is required to run istio in your cluster.


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize = `v3.0.0`


## Included features

This package enables the deployment of Istio creating needed Istio CRDs.


## Deployment

You can deploy this package by running following command in the root of the project:

```shell
$ kustomize build katalog/istio/init | kubectl apply -f -
```


### Check

You can check the installation status executing:

```bash
$ kubectl -n istio-system wait --for=condition=complete job --all
job.batch/istio-init-crd-10-1.4.2 condition met
job.batch/istio-init-crd-11-1.4.2 condition met
job.batch/istio-init-crd-14-1.4.2 condition met
```


## License

For license details please see [LICENSE](../../../LICENSE)
