# Init Istio package

## Check

```bash
$ kubectl -n istio-system wait --for=condition=complete job --all
job.batch/istio-init-crd-10-1.4.2 condition met
job.batch/istio-init-crd-11-1.4.2 condition met
job.batch/istio-init-crd-14-1.4.2 condition met
```
