# Sample configurations for WSO2 Integration Control Plane (ICP) Helm chart

This doc gives the sample configurations which can be used as values for the Helm chart.

## Supported Cluster providers

Currently, the ICP helm charts are tested with the following cluster providers,

### Amazon Elastic Kubernetes Service (EKS)

To use EKS, set the provider as `aws` and define the necessary configurations under `aws` sections as follows,
```yaml
# -- Kubernetes cluster provider. Supported values: azure, aws
provider: "aws"
# AWS service configurations
aws:
  serviceAccountName: "<service_account_name>"
  secretManager:
    secretProviderClass: "<secret_provider_class_name>"
    secretIdentifiers:
      internalKeystorePassword:
        secretName: "<secret_name>"
        secretKey: "<secret_key>"
```

When running in EKS, [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller) can be used as the ingress controller. To use it as the ingress controller for ICP, update the `ingress` section as follows,

**Note**: The current tested version of the controller is 2.6.x.

> [!IMPORTANT]
> 1. Create a SSL certificate using the AWS Certificate Manager (ACM) and replace the `<CERT_ARN>` with the certificate ARN.
> 2. If the AWS Load Balancer Controller is not installed in the cluster, install it using the [installation guide](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/installation.md).
> 3. Following annotations are required to be added to enable the AWS Load Balancer Controller. Depending on the use case, additional annotations might be required. Refer [AWS Load Balancer Controller annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/) for more information.

```yaml
wso2:
  ingress:
    # -- Enable Ingress for MI
    enabled: true
    # -- Ingress class name
    ingressClassName: "alb"
    # -- Ingress annotations
    annotations:
      alb.ingress.kubernetes.io/group.name: mi-dev-alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
      alb.ingress.kubernetes.io/certificate-arn: <CERT_ARN>
      alb.ingress.kubernetes.io/backend-protocol: HTTPS
      alb.ingress.kubernetes.io/healthcheck-protocol: 'HTTP'
      alb.ingress.kubernetes.io/healthcheck-port: '9743'
      alb.ingress.kubernetes.io/healthcheck-path: /dashboard/api/healthz
```

### Azure Kubernetes Service (AKS)

To use EKS, set the provider as `azure` and define the necessary configurations under `azure` sections as follows,

```yaml
# -- Kubernetes cluster provider. Supported values: azure, aws
provider: "azure"
# Azure service configurations
azure:
  keyVault:
    # -- Name of the target Azure Key Vault instance
    name: "<>"
    secretProviderClass: "<secret_provider_class_name>"
    secretIdentifiers:
      internalKeystorePassword: "<secret_name>"
    activeDirectory:
      # -- Service Principal created for transacting with the target Azure Key Vault
      servicePrincipal:
        # -- Azure AD application name for fetching secrets via CSI secret store driver
        appId: "<>"
        # -- Client secret of Azure AD application client
        clientSecret: "<>"
      # -- Azure Active Directory tenant ID of the target Key Vault
      tenantId: "<>"
    resourceManager:
      # -- Subscription ID of the target Azure Key Vault
      subscriptionId: "<>"
      # -- Name of the Azure Resource Group to which the target Azure Key Vault belongs
      resourceGroup: "<>"
```
