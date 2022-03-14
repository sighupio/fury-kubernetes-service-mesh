## Istio operator

The current manifests were generated using:
```bash
wget https://raw.githubusercontent.com/istio/istio/1.9.5/manifests/charts/istio-operator/crds/crd-operator.yaml
mv crd-operator.yaml crds/
wget https://raw.githubusercontent.com/istio/istio/1.9.5/manifests/charts/istio-operator/files/gen-operator.yaml
kubernetes-split-yaml --outdir . gen-operator.yaml
rm gen-operator.yaml
```