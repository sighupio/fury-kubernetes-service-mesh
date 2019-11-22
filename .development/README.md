# Development notes

## Istio

The istio package inside this module has been created following the next guide:

### How we've got the manifests

TODO!

### Demos

### Simplest demo

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

```bash
$ kubectl create ns demo
$ kubectl label namespace demo istio-injection=enabled
$ kubectl apply -f  https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml -n demo
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/bookinfo-gateway.yaml -n demo
```

Check the app is accesible.

#### Define destination rules

Define the destination rules

```bash
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/destination-rule-all.yaml -n demo
```

#### Set V1 destination rules for every virtual service 

Test only the V1 of every component:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/virtual-service-all-v1.yaml -n demo
```

You should see no ratings in the web page `/productpage`

#### V3 and V2. 

```bash
$ https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/networking/virtual-service-reviews-jason-v2-v3.yaml -n demo
```

Then, all but jason will go to v3 version of the review service. This means:

All people: Red Starts
Jason: Black starts

