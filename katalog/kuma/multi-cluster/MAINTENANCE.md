# Kuma

The manifests in the current folders were generated in this way:

## Global Control Plane

Move to the folder `global-control-plane` and run the following commands:

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=global > kuma-global.yml

# Using a tool to split the giant yaml
go get -v github.com/mogensen/kubernetes-split-yaml

kubernetes-split-yaml --outdir $PWD/resources kuma-global.yml

rm kuma-global.yml

# Remove auto-generated secret, we will override it with a custom one
rm resources/kuma-tls-cert-secret.yaml

# Remove caBundle, we will override it with a custom one
grep -v "caBundle" resources/kuma-validating-webhook-configuration-validatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kuma-validating-webhook-configuration-validatingwebhookconfiguration.yaml

grep -v "caBundle" resources/kuma-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kuma-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml
```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by Sighup registry ones.

## Zone Control Plane

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=zone \
  --zone=zone1 \
  --ingress-enabled \
  --kds-global-address=grpcs://localhost:1234 > kuma-zone-1.yml

kubernetes-split-yaml --outdir $PWD/resources kuma-zone-1.yml

rm kuma-zone-1.yml
rm resources/kuma-tls-cert-secret.yaml

# Remove caBundle, we will override it with a custom one
grep -v "caBundle" resources/kuma-validating-webhook-configuration-validatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kuma-validating-webhook-configuration-validatingwebhookconfiguration.yaml

grep -v "caBundle" resources/kuma-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml > tmp
mv -f tmp resources/kuma-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml
```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by Sighup registry ones.