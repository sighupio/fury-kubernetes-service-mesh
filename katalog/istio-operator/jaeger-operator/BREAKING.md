# Comprehensive Upgrade Guide for the Jaeger Operator from v1.22 to the Latest Release 🦮

## Introduction
<!-- markdownlint-disable MD033 -->
This guide provides detailed instructions for upgrading the Jaeger Operator component in a Service Mesh from version 1.22 to the latest release at the moment (1.56). The previous version is substantially outdated, and a direct upgrade path is unavailable. As a result, it is necessary to completely remove the old version before installing the new one. This document explains the reasons for this approach and outlines the steps to successfully transition to the latest version, which can be explored in detail [here](https://www.jaegertracing.io/docs/1.56/operator/).
<!-- markdownlint-enable MD033 -->
### Breaking Changes Notification 💔

- **Version Obsolescence:** The Jaeger Operator version 1.22 is no longer supported, and direct updates to the new version are not possible.
- **Impact on Cluster Operations:** The removal of the old version and installation of the new one may temporarily affect the stability and functionality of your Service Mesh.

#### Actions Required

- **Complete Resource Deletion:** All resources associated with the old version must be removed to prevent conflicts or lingering configurations that could impact the new installation.
- **Manual Reinstallation Needed:** After clearing the old resources, a fresh installation of the new version is required.

### Upgrade Guide 🦮

#### Preparing for the Upgrade

#### Current Configuration Snapshot

- **Perform a kustomize build:** Run `kustomize build .` on the current Jaeger Operator deployment and save the output. This step is crucial for identifying all the resources currently deployed under the old version. This information will be used to ensure a complete cleanup before installing the new version.

#### Backup and Risk Management

- **Backup Critical Data and Configurations:** Before proceeding with the update, make sure to backup all important configurations and data related to Jaeger. This precaution helps to safeguard your data in the event of an issue during the upgrade process.

#### Comprehensive Resource Removal
<!-- markdownlint-disable MD033 -->
- **Remove All Previous Resources:** To guarantee a successful update, it is essential to delete all resources associated with the previous version of the Jaeger Operator. This includes deployments, service accounts, roles, role bindings, and any custom resources defined by Jaeger. Removing these resources prevents any potential conflicts or leftover configurations that could interfere with the new version's operations.
<!-- markdownlint-enable MD033 -->
### Breaking Changes 💔

#### Key Points

- **Version Obsolescence:** The Jaeger Operator version 1.22 is no longer supported, and direct updates to the new version are not possible.
- **Impact on Cluster Operations:** The removal of the old version and installation of the new one may temporarily affect the stability and functionality of your Service Mesh.

### Important Notice

- **No Migration Path:** Upgrading from Jaeger Operator version 1.22 to the latest version does not have a direct migration path. The recommended approach is to completely remove the old version and then install the new operator.
- **Backup Critical Data and Configurations:** Before proceeding with the update, it is important to backup all important configurations and data related to Jaeger. This step ensures that your data is protected in case any issues arise during the upgrade process.
- **Prepare for Potential Disruptions:** Keep in mind that removing the Jaeger Operator and its associated resources may temporarily impact the services that depend on it. It is advisable to plan for possible service interruptions during this transition phase and communicate the expected downtime to relevant stakeholders.

## Installing the New Version

Following the cleanup of the old resources, proceed with the new version installation. Refer to the latest Jaeger Operator documentation provided [here](https://www.jaegertracing.io/docs/1.56/operator/) for detailed installation instructions. Ensure that you follow these guidelines closely to integrate the new version correctly into your environment.

## Conclusion

Upgrading to the latest version of the Jaeger Operator requires careful planning and execution due to the significant changes involved. By following this guide, you can ensure a smooth transition and minimize potential disruptions to your Service Mesh operations. Always be prepared for operational impacts and have appropriate recovery strategies in place.
