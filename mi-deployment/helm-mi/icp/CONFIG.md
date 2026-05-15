# icp

![Version: 1.0.0-0](https://img.shields.io/badge/Version-1.0.0--0-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for the deployment of WSO2 Integration Control Plane

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.region | string | `""` | AWS region |
| aws.secretManager.secretIdentifiers.internalKeystorePassword.secretKey | string | `""` | Secret key for internal keystore password |
| aws.secretManager.secretIdentifiers.internalKeystorePassword.secretName | string | `""` | Secret name for internal keystore password |
| aws.secretManager.secretProviderClass | string | `""` | AWS Secret Manager secret provider class name |
| aws.serviceAccountName | string | `""` | AWS IAM serivce account name |
| azure.keyVault.activeDirectory.servicePrincipal | object | `{"appId":"","clientSecret":""}` | Service Principal created for transacting with the target Azure Key Vault For advanced details refer to official documentation (https://github.com/Azure/secrets-store-csi-driver-provider-azure/blob/master/docs/service-principal-mode.md) |
| azure.keyVault.activeDirectory.servicePrincipal.appId | string | `""` | Azure AD application name for fetching secrets via CSI secret store driver |
| azure.keyVault.activeDirectory.servicePrincipal.clientSecret | string | `""` | Client secret of Azure AD application client |
| azure.keyVault.activeDirectory.tenantId | string | `""` | Azure Active Directory tenant ID of the target Key Vault |
| azure.keyVault.name | string | `""` | Name of the target Azure Key Vault instance |
| azure.keyVault.resourceManager.resourceGroup | string | `""` | Name of the Azure Resource Group to which the target Azure Key Vault belongs |
| azure.keyVault.resourceManager.subscriptionId | string | `""` | Subscription ID of the target Azure Key Vault |
| azure.keyVault.secretIdentifiers.internalKeystorePassword | string | `""` | Secret name for internal keystore password |
| azure.keyVault.secretProviderClass | string | `""` | Azure Secret Manager secret provider class name |
| containerRegistry | string | `""` | Container registry |
| gcp.secretManager.secretIdentifiers.internalKeystorePassword | string | `""` | Secret name for internal keystore password. Expected format is `projects/<PROJECT_ID>/secrets/<SECRET_NAME>/versions/<VERSION>` |
| gcp.secretManager.secretProviderClass | string | `""` | GCP Secret Manager secret provider class name |
| gcp.secretManager.serviceAccountKeySecret | string | `""` | K8s secret name which contains the JSON keyfile for the service account used to access the GCP Secret Manager |
| provider | string | `""` | Kubernetes cluster provider. Supported values: azure, aws |
| wso2.config.heartbeatPoolSize | int | `15` | Number of threads used by the executor pool to handle incoming requests from Micro Integrator runtimes |
| wso2.config.keyStore.alias | string | `"wso2carbon"` | The keystore alias |
| wso2.config.keyStore.fileName | string | `"dashboard.jks"` |  |
| wso2.config.keyStore.keyPassword | string | `""` | The keystore key password |
| wso2.config.keyStore.password | string | `""` | The keystore password |
| wso2.config.miUserstore.password | string | `""` | The user password for signing in to the Micro Integrator runtimes. |
| wso2.config.miUserstore.username | string | `""` | The user name for signing in to the Micro Integrator runtimes |
| wso2.config.secureVault.enabled | bool | `false` | Enable/Disable secure vault |
| wso2.config.serverPort | int | `9743` | ICP server port |
| wso2.config.trustStore.fileName | string | `"client-trustore.jks"` | The truststore file name |
| wso2.config.trustStore.password | string | `""` | The truststore password |
| wso2.deployment.BuildVersion | string | `"1.0.0"` | Build version of the ICP |
| wso2.deployment.JKSSecretName | string | `""` | K8s secret name which contains JKS files |
| wso2.deployment.configMaps | object | `{"entryPoint":{"defaultMode":"0407"}}` | Set UNIX permissions over the startup scripts |
| wso2.deployment.cpuUtilizationPercentage | int | `75` | Average CPU utilization percentage for HPA |
| wso2.deployment.envs | string | `nil` | Environment variables for the ICP deployment |
| wso2.deployment.hostname | string | `""` | Hostname of the ICP deployment |
| wso2.deployment.image.digest | string | `""` | Container image digest |
| wso2.deployment.image.pullPolicy | string | `"Always"` | Container image pull policy. Refer (https://kubernetes.io/docs/concepts/containers/images/#updating-images) |
| wso2.deployment.image.repository | string | `""` | Container image repository name |
| wso2.deployment.maxReplicas | int | `2` | Max replica count for HPA (https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| wso2.deployment.memoryUtilizationPercentage | int | `75` | Average memory utilization percentage for HPA |
| wso2.deployment.minAvailable | int | `1` | Pod disruption budget configurations (https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| wso2.deployment.minReplicas | int | `1` | Min replica count for HPA (https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| wso2.deployment.probes | object | `{"liveness":{"periodSeconds":10},"readiness":{"initialDelaySeconds":60,"periodSeconds":1},"startup":{"failureThreshold":40,"initialDelaySeconds":5,"periodSeconds":3}}` | Kubernetes Probes (https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| wso2.deployment.probes.liveness | object | `{"periodSeconds":10}` | Indicates whether the container is running |
| wso2.deployment.probes.liveness.periodSeconds | int | `10` | How often (in seconds) to perform the probe |
| wso2.deployment.probes.readiness.initialDelaySeconds | int | `60` | Number of seconds after the container has started before readiness probes are initiated |
| wso2.deployment.probes.readiness.periodSeconds | int | `1` | How often (in seconds) to perform the probe |
| wso2.deployment.probes.startup | object | `{"failureThreshold":40,"initialDelaySeconds":5,"periodSeconds":3}` | Startup probe executed prior to Liveness Probe taking over |
| wso2.deployment.probes.startup.failureThreshold | int | `40` | Number of attempts |
| wso2.deployment.probes.startup.initialDelaySeconds | int | `5` | Number of seconds after the container has started before startup probes are initiated |
| wso2.deployment.probes.startup.periodSeconds | int | `3` | How often (in seconds) to perform the probe |
| wso2.deployment.replicas | int | `1` | Number of deployment replicas |
| wso2.deployment.resources.jvm.memory.xms | string | `"512m"` | The minimum amount of memory that should be allocated for the JVM |
| wso2.deployment.resources.jvm.memory.xmx | string | `"1024m"` | The maximum amount of memory that should be allocated for the JVM |
| wso2.deployment.resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU that should be allocated for a Pod |
| wso2.deployment.resources.limits.memory | string | `"1Gi"` | The maximum amount of memory that should be allocated for a Pod |
| wso2.deployment.resources.requests.cpu | string | `"500m"` | The minimum amount of CPU that should be allocated for a Pod |
| wso2.deployment.resources.requests.memory | string | `"512Mi"` | The minimum amount of memory that should be allocated for a Pod |
| wso2.deployment.securityContext.apparmor | bool | `true` | Enable/Disable AppArmor (https://kubernetes.io/docs/tutorials/security/apparmor/) |
| wso2.deployment.securityContext.enableRunAsUser | bool | `true` |  |
| wso2.deployment.securityContext.runAsUser | string | `"802"` | The UID to run the entrypoint of the container process |
| wso2.deployment.securityContext.seLinux.enabled | bool | `false` |  |
| wso2.deployment.securityContext.seLinux.level | string | `"s0:c26,c0"` |  |
| wso2.deployment.securityContext.seccompProfile | object | `{"enabled":true,"type":"RuntimeDefault"}` | Enable/Disable seccomp profile (https://kubernetes.io/docs/tutorials/security/seccomp/) |
| wso2.deployment.securityContext.seccompProfile.enabled | bool | `true` | Enable/Disable seccomp profile |
| wso2.deployment.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Seccomp profile type |
| wso2.deployment.strategy.rollingUpdate.maxSurge | int | `1` | The maximum number of pods that can be scheduled above the desired number of pods. |
| wso2.deployment.strategy.rollingUpdate.maxUnavailable | int | `0` | The maximum number of pods that can be unavailable during the update. |
| wso2.ingress.annotations | list | `nil` | Ingress annotations |
| wso2.ingress.enabled | bool | `true` | Enable Ingress for ICP |
| wso2.ingress.ingressClassName | string | `""` | Ingress class name |
| wso2.ingress.ratelimit.burstLimit | string | `""` | Ingress ratelimit burst limit |
| wso2.ingress.ratelimit.enabled | bool | `false` | Ingress rate limit |
| wso2.ingress.ratelimit.zoneName | string | `""` | Ingress ratelimit zone name |
| wso2.ingress.tlsSecret | string | `""` | K8s TLS secret for configured hostname |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
