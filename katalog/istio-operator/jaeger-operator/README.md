## Jaeger setup

For any further documentation, please look [here](https://www.jaegertracing.io/docs/1.22/operator/)

### Jaeger Agent

You can inject the Jaeger Agent as sidecar by adding the annotation `"sidecar.jaegertracing.io/inject": "true"`. This is currently supported only in Deployment ([here](https://www.jaegertracing.io/docs/1.22/operator/#auto-injecting-jaeger-agent-sidecars) for further details)