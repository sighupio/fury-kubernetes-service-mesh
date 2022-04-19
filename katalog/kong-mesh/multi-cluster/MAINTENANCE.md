# Kong Mesh

The manifests in the current folders were generated in this way:

## Kumactl download and alias

First of all, download the version you need for kumactl package and point to it for the next commands.
```bash
cd ../../tools/$OS/kong-mesh/$VERSION
./download.sh
alias kumactl=$PWD/kumactl

# Test if you get the version you expect
kumactl version

```

## Global Control Plane

Move to the folder `global-control-plane` and run the following commands:

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=global \
  --cp-auth=cpToken > kong-mesh-global.yml

# Using a tool to split the giant yaml
go get -v github.com/mogensen/kubernetes-split-yaml

kubernetes-split-yaml --outdir $PWD/resources kong-mesh-global.yml

rm kong-mesh-global.yaml

# Remove auto-generated secret, we will override it with a custom one
rm resources/kong-mesh-tls-cert-secret.yaml

# Remove caBundle, we will override it with a custom one
grep -v "caBundle" resources/kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml

grep -v "caBundle" resources/kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml
```

In `kustomization.yaml` and `patches/kong-mesh-init-image.yaml` the default images are overridden by Sighup registry ones.

## Zone Control Plane

Move to the folder `zone-control-plane` and run the following commands:

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=zone \
  --zone=zone1 \
  --ingress-enabled \
  --kds-global-address=grpcs://localhost:1234 > kong-mesh-zone-1.yml

kubernetes-split-yaml --outdir $PWD/resources kong-mesh-zone-1.yml

rm kong-mesh-zone-1.yml

# Remove auto-generated secret, we will override it with a custom one
rm resources/kong-mesh-tls-cert-secret.yaml

# Remove caBundle, we will inject it using cert-manager
grep -v "caBundle" resources/kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml

grep -v "caBundle" resources/kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml
```

In `kustomization.yaml` and `patches/kong-mesh-init-image.yaml` the default images are overridden by SIGHUP registry ones.