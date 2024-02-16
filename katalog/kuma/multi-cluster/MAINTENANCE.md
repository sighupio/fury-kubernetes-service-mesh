# Kuma

The manifests in the current folders were generated in this way:

## Kumactl download and alias

First of all, download the version you need for kumactl package and point to it for the next commands.
```bash
cd ../../tools/kuma

# In case, you need to change the VERSION variable in download.sh script
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
  --tls-kds-global-server-secret=kds-server-tls > resources/kuma-global.yml

```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by Sighup registry ones.

## Zone Control Plane

Move to the folder `zone-control-plane` and run the following commands:

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=zone \
  --zone=zone1 \
  --ingress-enabled \
  --kds-global-address=grpcs://localhost:1234 > resources/kuma-zone.yml

```

In `kustomization.yaml` and `patches/kuma-init-image.yaml` the default images are overridden by SIGHUP registry ones.