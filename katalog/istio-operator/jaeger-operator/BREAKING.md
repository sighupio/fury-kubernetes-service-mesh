## Draft: Comprehensive Upgrade Guide for the Jaeger Operator from v1.22 to the Latest Release 🦮

### Introduction
This guide provides detailed instructions for upgrading the Jaeger Operator component in a Service Mesh from version 1.22 to the latest release. The previous version is substantially outdated, and a direct upgrade path is unavailable. As a result, it is necessary to completely remove the old version before installing the new one. This document explains the reasons for this approach and outlines the steps to successfully transition to the latest version, which can be explored in detail [here](https://www.jaegertracing.io/docs/1.57/operator/).

### Breaking Changes Notification 💔

#### Key Points
- **Version Obsolescence:** The Jaeger Operator version 1.22 is no longer supported, and direct updates to the new version are not possible.
- **Impact on Cluster Operations:** The removal of the old version and installation of the new one may temporarily affect the stability and functionality of your Service Mesh.

#### Actions Required
- **Complete Resource Deletion:** All resources associated with the old version must be removed to prevent conflicts or lingering configurations that could impact the new installation.
- **Manual Reinstallation Needed:** After clearing the old resources, a fresh installation of the new version is required.

### Update Guide 🦮

#### Preparing for the Upgrade


#### Current Configuration Snapshot:
- **Perform a kustomize build:** Run `kustomize build .` on the current Jaeger Operator deployment and save the output. This step is crucial for identifying all the resources currently deployed under the old version. This information will be used to ensure a complete cleanup before installing the new version.

#### Comprehensive Resource Removal:
- **Remove All Previous Resources:** To guarantee a successful update, it is essential to delete all resources associated with the previous version of the Jaeger Operator. This includes deployments, service accounts, roles, role bindings, and any custom resources defined by Jaeger. Removing these resources prevents any potential conflicts or leftover configurations that could interfere with the new version's operations.

#### Backup and Risk Management:
- **Backup Critical Data and Configurations:** Before proceeding with the update, make sure to backup all important configurations and data related to Jaeger. This precaution helps to safeguard your data in the event of an issue during the upgrade process.
- **Prepare for Potential Disruptions:** Be aware that removing the Jaeger Operator and its associated resources may temporarily impact the services depending on it. Plan for possible service interruptions during this transition phase and inform relevant stakeholders of the expected downtime.

#### Deleting the Outdated Version

Execute the following commands to remove the Jaeger Operator version 1.22. This step is critical to ensure a clean environment for the new installation:

```bash
kubectl delete clusterrolebinding jaeger jaeger-operator jaegers.jaegertracing.io --ignore-not-found
kubectl delete clusterrole jaeger jaeger-operator jaegers.jaegertracing.io --ignore-not-found
kubectl delete crd jaegers.jaegertracing.io --ignore-not-found
kubectl delete deployment jaeger jaeger-operator jaegers.jaegertracing.io --ignore-not-found
kubectl delete namespace jaeger jaeger-operator jaegers.jaegertracing.io observability --ignore-not-found
kubectl delete sa jaeger jaeger-operator jaegers.jaegertracing.io --ignore-not-found
kubectl delete certificate jaeger-operator-serving-cert --ignore-not-found
kubectl delete mutatingwebhookconfiguration jaeger-operator-mutating-webhook-configuration --ignore-not-found
kubectl delete clusterrolebinding jaeger-operator-proxy-rolebinding --ignore-not-found
kubectl delete rolebinding leader-election-rolebinding prometheus --ignore-not-found
kubectl delete role leader-election-role prometheus --ignore-not-found
kubectl delete issuer jaeger-operator-selfsigned-issuer --ignore-not-found
kubectl delete validatingwebhookconfiguration jaeger-operator-validating-webhook-configuration --ignore-not-found
kubectl delete service jaeger-operator-metrics jaeger-operator-webhook-service --ignore-not-found
```

#### Installing the New Version

Following the cleanup of the old resources, proceed with the new version installation. Refer to the latest Jaeger Operator documentation provided [here](https://www.jaegertracing.io/docs/1.57/operator/) for detailed installation instructions. Ensure that you follow these guidelines closely to integrate the new version correctly into your environment.

### Conclusion

Upgrading to the latest version of the Jaeger Operator requires careful planning and execution due to the significant changes involved. By following this guide, you can ensure a smooth transition and minimize potential disruptions to your Service Mesh operations. Always be prepared for operational impacts and have appropriate recovery strategies in place.