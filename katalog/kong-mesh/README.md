# Kong Mesh

The manifests in the current folders were generated in this way:

## Global Control Plane

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=global \
  --cp-auth=cpToken > kuma-global.yml

# Using a tool to split the giant yaml
go get -v github.com/mogensen/kubernetes-split-yaml

kubernetes-split-yaml --outdir $PWD/resources kuma-global.yml

rm kuma-global.yaml

# Remove auto-generated secret, we will override it with a custom one
rm resources/kong-mesh-tls-cert-secret.yaml

# Remove caBundle, we will override it with a custom one
grep -v "caBundle" kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml > tmp
mv -f tmp kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml

grep -v "caBundle" kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml > tmp
mv -f tmp kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml
```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by Sighup registry ones.

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
rm resources/kong-mesh-tls-cert-secret.yaml

# Remove caBundle, we will override it with a custom one
grep -v "caBundle" kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml > tmp
mv -f tmp kong-mesh-validating-webhook-configuration-validatingwebhookconfiguration.yaml

grep -v "caBundle" kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml > tmp
mv -f tmp kong-mesh-admission-mutating-webhook-configuration-mutatingwebhookconfiguration.yaml
```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by Sighup registry ones.