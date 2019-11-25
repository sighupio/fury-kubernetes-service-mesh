# Development notes

## Istio

Here is explained how we develop the Istio package inside the service-mesh SIGHUP module. It's very important to
maintain this document updated. So, any new/modified action has to be written here.

### How we've got the manifests

First add istio to your helm repositories:

```bash
$ helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.4.0/charts/
$ helm update
```

Then, download the charts:

```bash
$ helm fetch istio.io/istio-init --untar --untardir install/kubernetes/helm
$ helm fetch istio.io/istio --untar --untardir install/kubernetes/helm
$ ls install/kubernetes/helm
istio		istio-init
```

And let's start rendering the `istio-init` helm chart:

```bash
$ helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system > rendered/istio-init.yml
```

Now, you can find inside the rendered directory a *(big)* file named `istio-init.yml`. This file contains:

- configmaps
- jobs
- rbac

So, i have splited it into some more granular files based on its content. You can find the resulting files inside the
[katalog/init-istio directory](../katalog/init-istio).

Now, we are ready to render the `istio` chart, but first, let's review the [`values.yml`](values.yml) file.

This file was configured using the 
[official istio chart documentation](https://istio.io/docs/reference/config/installation-options/).

This values makes possible the following configuration:

|                          | Installed          |
|--------------------------|--------------------|
| **Core components**      |                    |
| `istio-citadel`          |                    |
| `istio-egressgateway`    |                    |
| `istio-galley`           |                    |
| `istio-ingressgateway`   | :white_check_mark: |
| `istio-nodeagent`        |                    |
| `istio-pilot`            | :white_check_mark: |
| `istio-policy`           | :white_check_mark: |
| `istio-sidecar-injector` |                    |
| `istio-telemetry`        |                    |
| **Addons**               |                    |
| `grafana`                |                    |
| `istio-tracing`          |                    |
| `kiali`                  |                    |
| `prometheus`             |                    |

Take care about the ingressgateway configuration. We have changed the default behaviour of having a loadbalancer to only
use nodeports.

So, let's render the `istio` chart:

```
helm template install/kubernetes/helm/istio --name istio --namespace istio-system \
--values values.yml > rendered/istio.yml
```

Once rendered, you can find the istio.yml file inside the rendered directory. This file is a very very big one, so we
spllited it in components. You can find the final result inside the [katalog/istio](../katalog/istio) directory.

So, we have created:

- rbac.yml
- mixer.yml
- pilot.yml
- gateway.yml
- config.yml

This way is going to be easy to debug future problems. We splitted it by chart names.

### Demos / Testing

### Simplest demo (Requires sidecar-injector)

```bash
$ kubectl create ns demo
$ kubectl label namespace demo istio-injection=enabled
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/httpbin/httpbin.yaml -n demo
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/httpbin/httpbin-gateway.yaml -n demo
$ kubectl get pods -n demo
NAME                       READY   STATUS    RESTARTS   AGE
httpbin-64776bf78d-qfww6   2/2     Running   0          4m58s
$ kubectl get gateway -n demo
NAME              AGE
httpbin-gateway   4m15s
$ kubectl get virtualservice -n demo
NAME      GATEWAYS            HOSTS   AGE
httpbin   [httpbin-gateway]   [*]     4m27s
```

Clean up:

```bash
$ kubectl delete ns demo
```

### Bookinfo

With sidecar auto-inject

```bash
$ kubectl create ns demo
$ kubectl label namespace demo istio-injection=enabled
$ kubectl apply -f  https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml -n demo
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/bookinfo-gateway.yaml -n demo
```


Without it

```bash
$ kubectl create ns demo
$ curl -LOs https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml
$ kubectl apply -f <(istioctl kube-inject -f bookinfo.yaml) -n demo
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/bookinfo-gateway.yaml -n demo
```

Check the app is accesible: `/productpage`.
You should see 3 diferent versions running:

- Without stars
- With red stars
- With black stars

#### Define destination rules

Define the destination rules

```bash
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/destination-rule-all.yaml -n demo
```

#### Set V1 destination rules for every virtual service

Test only the V1 of every component:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/virtual-service-all-v1.yaml -n demo
```

You should see no ratings in the web page `/productpage`

#### V3 and V2.

```bash
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/virtual-service-reviews-jason-v2-v3.yaml -n demo
```

Then, all but jason will go to v3 version of the review service. This means:

- All people: Red Starts
- Jason (jason:jason): Black starts

## Links

- [Helm chart values](https://istio.io/docs/reference/config/installation-options/)
- [Istio helm chart guide](https://istio.io/docs/setup/install/helm/)
- [istio-the-easy-way](https://medium.com/solo-io/istio-the-easy-way-de66e6eba4a1)
- [istio in action @ GITHUB](https://github.com/istioinaction/book-source-code)