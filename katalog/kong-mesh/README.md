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

kubernetes-split-yaml --outdir $PWD kuma-global.yml

rm kuma-global.yaml

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

kubernetes-split-yaml --outdir $PWD kuma-zone-1.yml

rm kuma-zone-1.yml
```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by Sighup registry ones.