# Sample configurations for WSO2 MI Helm chart

This doc gives the sample configurations which can be used as values for the Helm chart for different use cases.

## Supported Cluster providers

Currently, the MI helm charts are tested with the following cluster providers,

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

When running in EKS, [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller) can be used as the ingress controller. To use it as the ingress controller for MI, update the `ingress` section as follows,

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
      alb.ingress.kubernetes.io/healthcheck-port: '9201'
      alb.ingress.kubernetes.io/healthcheck-path: /healthz
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

### Google Kubernetes Engine (GKE)

To use GKE, set the provider as `gcp` and define the necessary configurations under `gcp` sections as follows,

```yaml
provider: "gcp"
gcp:
  secretManager:
    secretProviderClass: "<secret_provider_class_name>"
    serviceAccountKeySecret: "<k8s_secret_for_service_account_key>"
    secretIdentifiers:
      internalKeystorePassword: "<>"
```

When we enable WSO2 secure vault, GCP [Secret Manager](https://cloud.google.com/secret-manager) will be used to store the Internal Keystore password. You will need to satisfy the following pre-requisites to use GCP Secret Manager.

1. Creating a Service account to access the secret manager. You can change `SA-INTERNAL-KEYSTORE-SECRET` to a different name, but if you do, make sure to change it in later steps too.

```
gcloud iam service-accounts create SA-INTERNAL-KEYSTORE-SECRET
```

2. Attaching the role to the Service account. Replace `<SECRET_NAME>` and `<PROJECT_ID>` with the actual values. `SECRET_NAME` is the name of the secret created in GCP Secret Manager to store the Internal Keystore password.

```
gcloud secrets add-iam-policy-binding <SECRET_NAME> --member="serviceAccount:SA-INTERNAL-KEYSTORE-SECRET@<PROJECT_ID>.iam.gserviceaccount.com" --role="roles/secretmanager.secretAccessor"
```

3. Download the JSON keyfile for the service account

```
gcloud iam service-accounts keys create key.json --iam-account=SA-INTERNAL-KEYSTORE-SECRET@<PROJECT_ID>.iam.gserviceaccount.com
```

4. Create a K8s secret with the key 'key.json' with a value of an exported GCP service account credential. Replace `<K8S_SECRET_NAME>` and `<NAMESPACE>` accordingly.
Note: You will need to use the same `K8S_SECRET_NAME` for the `serviceAccountKeySecret` values in the helm chart.

```
kubectl create secret generic <K8S_SECRET_NAME> --from-file=key.json -n <NAMESPACE>
```

5. Install the Secrets CSI driver 

```
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
```

6. Install the GCP provider

```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/secrets-store-csi-driver-provider-gcp/main/deploy/provider-gcp-plugin.yaml
```

## MI User store configurations

By default the file-based user store will be enabled. The following sample configuration shows how to use a RDBMS user store. It is recommended to include the JDBC driver in your Docker image so that MI can connect to the databases without any issues. If you are not adding the driver to the image itself, you might have to modify the helm charts and mount the driver to the deplyoments.

```yaml
wso2:
  config:
    userstore:
      file:
        # Disable file based userstore
        enabled: false
      rdbms:
        url: "jdbc:mysql://<DB_HOST>:<DB_PORT>/<USER_DB_NAME>"
        username: "root"
        password: "root"
        jdbc:
          driver: "com.mysql.jdbc.Driver"
          poolParameters:
            maxActive: 50
            maxWait: 60000
```

## Mounting CApps using a Persistent Volume

Incase the CApps are not burned into the docker image, We can use a persistent volume to mount the CApps. The following sample configuration shows how to mount the CApps using a persistent volume.

### Using EFS as the persistent volume when running in EKS

1. Set mountCapps to true in the deployment section.

```yaml
wso2:
  deployment:
    mountCapps: true
```

2. Define the necessary configurations under `aws.storage` sections as follows,

```yaml
aws:
  storage:
    provisioner: "efs.csi.aws.com"
    storageClass: "efs-sc"
    capacity: "5Gi"
    fileSystemId: "<replace_with_filesystem_id>"
    cAppAccessPoint: "<replace_with_accesspoint_id>"
    directoryPerms: "0777"
```

### Using GCP FileStore as the persistent volume when running in GKE

**Prerequisites**: Deploy the Filstore CSI driver following the [Deploying the Driver](https://github.com/kubernetes-sigs/gcp-filestore-csi-driver/blob/master/README.md#deploying-the-driver) section in the GCP documentation.

1. Set mountCapps to true in the deployment section.

```yaml
wso2:
  deployment:
    mountCapps: true
```

2. Define the necessary configurations under `aws.storage` sections as follows,

```yaml
gcp:
  storage:
    storageClass: "filestore-sc"
    capacity: "1Gi"
    volumeHandle: "modeInstance/<zone>/<filestore-instance-name>/<filestore-share-name>"
    volumeAttributes:
      ip: "<ip-address-of-the-filestore-instance>"
      volume: "<filestore-share-name>"
```

## Enabling MI Dashboard

Using the following sample configuration, the MI node will connect to the MI dashboard running with a service `private-cloud-mi-dash-1`.
By default, the groupId of the MI node will be the release name while the nodeId will be the pod name.

```yaml
wso2:
  config:
    dashboard:
      url: "https://private-cloud-mi-dash-1:9743/dashboard/api/"
```

## Enabling RabbitMQ Listener

Following sample configuration shows how to configure WSO2 Micro Integrator to connect with RabbitMQ listener. Similar configurations can be used to configure JMS transport listeners as well.

```yaml
wso2:
  config:
    transport:
      rabbitmq:
        listener:
        - name: "AMQPConnectionFactory"
          parameters:
            hostname: "<HOST_NAME>"
            port: 5672
            username: "<USERNAME>"
            password: "<PASSWORD>"
```

## Monitoring with OpenTelemetry

Below configurations can be used to enable and view traces through Jaeger.

```yaml
wso2:
  config:
    opentelemetry:
      enable: true
      type: "jaeger"
      host: "<hostname-of-jaeger>"
      port: 14250
    mediation:
      flow:
        statistics:
          captureAll: true
        tracer:
          collectPayloads: true
          collectMediationProperties: true
```

## Configuring a synapse handler

```yaml
wso2:
  config:
    synapseHandlers:
    - name: "TestHandler"
      class: "org.wso2.carbon.test.gateway.TestHandler"
    - name: "SecHandler"
      class: "org.wso2.carbon.test.gateway.SecHandler"
```

## Adding properties to configuration file.

You can use a configuration file to load the parameter values to the properties file stored in the <MI_HOME>/conf directory, which you can use to store the parameter values that should be injected to your synapse configuration.

```yaml
wso2:
  config:
    fileProperties:
      prop1: value1
      prop2: value2
```

## Defining synapse properties
For commonly used synapse properties you can use the properties under `wso2.config.mediation.synapse` in the Helm values. If you need to pass any other parameter to the `synapse.properties` file you need to define them under `wso2.config.synapseProperties` as follows,

```yaml
wso2:
  config:
    synapseProperties:
      synapse.json.to.xml.processing.instruction.enabled: true
      freemarker.template.base.path: '"/home/test"'
```

## Defining a custom message formatter

Similar configurations can be used to define a custom message builder as well. Refer `wso2.config.messageFormatters` and `wso2.config.messageBuilders` sections in [CONFIG](./CONFIG.md).

```yaml
wso2:
  config:
    messageFormatters:
      custom:
        nonBlocking:
        - contentType: "application/ld+json"
          class: "org.example.CustomJsonFormatter"
```

## Mounting Keystore and Truststore using a Kubernetes Secret

If you are not including the keystore and truststore into the docker image, you can mount them using a Kubernetes secret. The following sample configuration shows how to mount the keystore and truststore using a Kubernetes secret.

**Pre-requisites**

Create a Kubernetes secret with the keystore and truststore files. The secret should contain the primary keystore file, internal keystore file and  truststore file.

> [!IMPORTANT]
> 1. Make sure to use the same secret name when creating the secret and when configuring the helm chart.
> 2. If you are using a different keystore file name and alias, make sure to update the helm chart configurations accordingly.
> 3. In addition to the primary, internal keystores and truststore files, you can also include the keystores for HTTPS tranport as well. Refer [CONFIG](./CONFIG.md) and [Configuring Keystores for the Micro Integrator](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/mi-setup/security/configuring_keystores/) for more information.

Refer the following sample commands to create the secret and use it in the helm chart.

```
kubectl create secret generic mi-jks-secret --from-file=wso2carbon.jks --from-file=client-truststore.jks --from-file=wso2internal.jks -n mi-test
```

```yaml
wso2:
  deployment:
    JKSSecretName: "mi-jks-secret"
  config:
    keyStore:
      primary:
        fileName: "wso2carbon.jks"
        alias: "wso2carbon"
        password: ""
        keyPassword: ""
      internal:
        fileName: "wso2internal.jks"
        alias: "wso2carbon"
        password: ""
        keyPassword: ""
    trustStore:
      primary:
        fileName: "client-truststore.jks"
        password: ""
```
