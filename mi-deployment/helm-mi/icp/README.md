# Helm chart for the deployment of WSO2 Micro Integration Control Plane (ICP) v1.0.0

This module contains the Helm resources required to deploy WSO2 Integration Control Plane (ICP) in a Kubernetes environment.

## Prerequisites

- WSO2 Product Docker images required for the deployment.
- It is recommended to push your own images to the cloud provider's container registry (ACR, ECR, etc.) as a best practice. Refer [U2 documentation](https://updates.docs.wso2.com/en/latest/updates/how-to-use-docker-images-to-receive-updates/) for any additional information. 

**Note** that you need a valid WSO2 subscription to obtain the U2 updated docker images from the WSO2 private registry.

- A running Kubernetes cluster (AKS, EKS, etc.)

- Ingress controller for routing traffic. The recommendation is to use [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) suitable for your cloud environment. Basic configurations for the NGINX Ingress Controller are as follows. Other supported ingress controllers specific to provider can be fount at [Supported Cluster providers](./EXAMPLES.md#supported-cluster-providers).

```yaml
wso2:
  ingress:
    enabled: true
    ingressClassName: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
```

- If you are enabling secure vault configurations for the product, you need to configure the secret manager service of the respective cloud provider. Since the secrets are encrypted using the internal keystore password, that password should be included in the key vault so that it can be resolved using a CSI driver when the helm charts are deployed.

    For AWS, you need to deploy the `secrets-store-csi-driver-provider` and create the necessary IAM policies, OIDC providers, and IAM service accounts. Please refer the [documentation](https://github.com/aws/secrets-store-csi-driver-provider-aws) for more information and steps to follow.

## Supported Cluster providers

Currently, the MI helm charts are tested with the following cluster providers,

* [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/)

    Refer [EKS Configs](./EXAMPLES.md#amazon-elastic-kubernetes-service-eks) section to configure the required parameters to run MI in EKS.

* [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/)

    Refer [AKS Configs](./EXAMPLES.md#azure-kubernetes-service-aks) section to configure the required parameters to run MI in AKS.

## Helm chart configurations

The [values.yaml](./values.yaml) file contains the basic required parameters to deploy MI in a Kubernetes environment. You may refer [CONFIG](./CONFIG.md) for full chart configurations. 

The [EXAMPLES](./EXAMPLES.md) file contains sample configurations which can be used as values for the Helm chart.

## Contributing

1. Update the necessary k8s template file in [templates](./templates/) or the configuration file in [confs](./confs/). If the new paramter is optional, make sure to add the necessary check conditions.

2. Update the [values.yaml](./values.yaml) accordingly.

3. Run the following command to generate the docs.

**Note**: If `helm-docs` is not installed, refer [Installation](https://github.com/norwoodj/helm-docs#installation) first.

```
helm-docs -f values.yaml -o CONFIG.md
```
