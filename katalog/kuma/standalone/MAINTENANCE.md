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

## Control Plane

Run the following command:

```bash
kumactl install control-plane \
  --without-kubernetes-connection \
  --mode=standalone > resources/kuma-standalone.yml

```

In `kustomization.yaml` and `patches/kong-mesh-init-image.yaml` the default images are overridden by Sighup registry ones.
