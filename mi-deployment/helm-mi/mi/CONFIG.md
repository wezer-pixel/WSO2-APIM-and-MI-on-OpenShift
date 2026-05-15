# mi

![Version: 4.4.0-0](https://img.shields.io/badge/Version-4.4.0--0-informational?style=flat-square) ![AppVersion: 4.4.0](https://img.shields.io/badge/AppVersion-4.4.0-informational?style=flat-square)

A Helm chart for the deployment of WSO2 Micro Integrator

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.region | string | `""` | AWS region |
| aws.secretManager.secretIdentifiers.internalKeystorePassword.secretKey | string | `""` | Secret key for internal keystore password |
| aws.secretManager.secretIdentifiers.internalKeystorePassword.secretName | string | `""` | Secret name for internal keystore password |
| aws.secretManager.secretProviderClass | string | `""` | AWS Secret Manager secret provider class name |
| aws.serviceAccountName | string | `""` | AWS IAM serivce account name |
| aws.storage.cAppAccessPoint | string | `""` | EFS file system access point ID for mounting the CApps |
| aws.storage.capacity | string | `""` | Persistent volume storage capacity |
| aws.storage.directoryPerms | string | `"0777"` | Directory permissions for access point root directory creation |
| aws.storage.fileSystemId | string | `""` | EFS file system ID |
| aws.storage.provisioner | string | `"efs.csi.aws.com"` | Storage provisioner |
| aws.storage.storageClass | string | `""` | Persistent volume storage class name |
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
| gcp.storage.capacity | string | `""` | Persistent volume storage capacity |
| gcp.storage.storageClass | string | `""` | Persistent volume storage class name |
| gcp.storage.volumeAttributes.ip | string | `""` | Pre-provisioned Filestore instance IP |
| gcp.storage.volumeAttributes.volume | string | `""` | Pre-provisioned Filestore instance share name |
| gcp.storage.volumeHandle | string | `""` | Volume handle of the GCP Filestore instance. Format `modeInstance/<zone>/<filestore-instance-name>/<filestore-share-name>` |
| provider | string | `""` | Kubernetes cluster provider. Supported values: azure, aws |
| wso2.config.admin.createAdminAccount | bool | `false` | Create super admin account |
| wso2.config.admin.password | string | `""` | Super admin password |
| wso2.config.admin.username | string | `""` | Super admin username |
| wso2.config.analytics.apiAnalytics | bool | `true` | Enable/Disable publishing API analytics data |
| wso2.config.analytics.enabled | bool | `false` | Enable/Disable analytics |
| wso2.config.analytics.endpointAnalytics | bool | `true` | Enable/Disable publishing endpoint analytics data |
| wso2.config.analytics.id | string | `""` | An identifier that will be published with the analytic |
| wso2.config.analytics.prefix | string | `"SYNAPSE_ANALYTICS_DATA"` | Prefix added when Elasticsearch analytics are being published |
| wso2.config.analytics.proxyServiceAnalytics | bool | `true` | Enable/Disable publishing proxy service analytics data |
| wso2.config.analytics.publisher | string | `"log"` | Analytics publisher (Publisher types supported are log and databridge) |
| wso2.config.analytics.sequenceAnalytics | bool | `true` | Enable/Disable publishing sequence analytics data |
| wso2.config.coordination | object | `{"nodeId":"","rdbms":{"jdbc":{"driver":"","poolParameters":null},"password":"","url":"","username":""}}` | Enable/Disable coordination |
| wso2.config.coordination.nodeId | string | `""` | Node ID for coordination |
| wso2.config.coordination.rdbms.jdbc.driver | string | `""` | JDBC driver class name of the Coordination Database |
| wso2.config.coordination.rdbms.jdbc.poolParameters | list | `nil` | JDBC connection pool parameters of the Coordination Database |
| wso2.config.coordination.rdbms.password | string | `""` | Coordination Database password |
| wso2.config.coordination.rdbms.url | string | `""` | Coordination Database URL |
| wso2.config.coordination.rdbms.username | string | `""` | Coordination Database username |
| wso2.config.dashboard.groupId | string | release name | The group ID of the Micro Integrator deployment |
| wso2.config.dashboard.heartbeatInterval | int | `5` | The time interval (in seconds) between two heartbeats sent from the Micro Integrator to the dashboard server |
| wso2.config.dashboard.nodeId | string | pod name | The node ID of the Micro Integrator deployment |
| wso2.config.dashboard.url | string | `""` | MI Dashboard URL |
| wso2.config.fileProperties | list | `nil` | List of properties |
| wso2.config.keyStore.internal.alias | string | `"wso2carbon"` | Internal keystore alias |
| wso2.config.keyStore.internal.fileName | string | `"wso2carbon.jks"` | Internal keystore file name |
| wso2.config.keyStore.internal.keyPassword | string | `""` | Internal keystore key password |
| wso2.config.keyStore.internal.password | string | `""` | Internal keystore password |
| wso2.config.keyStore.primary.alias | string | `"wso2carbon"` | Primary keystore alias |
| wso2.config.keyStore.primary.fileName | string | `"wso2carbon.jks"` | Primary keystore file name |
| wso2.config.keyStore.primary.keyPassword | string | `""` | Primary keystore key password |
| wso2.config.keyStore.primary.password | string | `""` | Primary keystore password |
| wso2.config.managementApi | object | `{"authorizationHandler":{"enable":true,"resources":["/users"]},"cors":{"allowedHeaders":"Authorization, Content-Type","allowedOrigins":"*","enabled":true},"jwtTokenSecurityHandler":{"enable":true,"tokenConfig":{"expiry":3600,"size":2048},"tokenStoreConfig":{"cleanUpInterval":600,"maxSize":200,"removeOldestTokenOnOverflow":true}}}` | ManagementAPI related configurations. (https://apim.docs.wso2.com/en/latest/install-and-setup/setup/mi-setup/security/securing_management_api/) |
| wso2.config.managementApi.authorizationHandler.resources | list | `["/users"]` | Enable authorization for additional resources |
| wso2.config.mediation.flow.statistics.captureAll | bool | `false` |  |
| wso2.config.mediation.flow.statistics.enable | bool | `false` |  |
| wso2.config.mediation.flow.tracer.collectMediationProperties | bool | `false` |  |
| wso2.config.mediation.flow.tracer.collectPayloads | bool | `false` |  |
| wso2.config.mediation.inbound.coreThreads | int | `20` |  |
| wso2.config.mediation.inbound.maxThreads | int | `100` |  |
| wso2.config.mediation.inbound.portOffsetEnable | bool | `false` |  |
| wso2.config.mediation.internalHttpApiEnable | bool | `true` |  |
| wso2.config.mediation.internalHttpApiPort | int | `9191` |  |
| wso2.config.mediation.internalHttpsApiPort | int | `9154` |  |
| wso2.config.mediation.statistics.cleanInterval | int | `1000` |  |
| wso2.config.mediation.statistics.enableClean | bool | `true` |  |
| wso2.config.mediation.synapse.buildValidNcName | bool | `false` |  |
| wso2.config.mediation.synapse.commandDebuggerPort | int | `9005` |  |
| wso2.config.mediation.synapse.coreThreads | int | `20` |  |
| wso2.config.mediation.synapse.disableAutoPrimitiveRegex | string | `"^-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][+-]?[0-9]+)?$"` |  |
| wso2.config.mediation.synapse.disableCustomReplaceRegex | string | `"@@@"` |  |
| wso2.config.mediation.synapse.enableAutoPrimitive | bool | `false` |  |
| wso2.config.mediation.synapse.enableNamespaceDeclaration | bool | `false` |  |
| wso2.config.mediation.synapse.enableXmlNil | bool | `false` |  |
| wso2.config.mediation.synapse.enableXpathDomFailover | bool | `true` |  |
| wso2.config.mediation.synapse.eventDebuggerPort | int | `9006` |  |
| wso2.config.mediation.synapse.globalTimeoutInterval | int | `120000` |  |
| wso2.config.mediation.synapse.jsonOutAutoArray | bool | `false` |  |
| wso2.config.mediation.synapse.maxThreads | int | `100` |  |
| wso2.config.mediation.synapse.preserveNamespaceOnXmlToJson | bool | `false` |  |
| wso2.config.mediation.synapse.scriptMediatorPoolSize | int | `15` |  |
| wso2.config.mediation.synapse.tempDataChunkSize | int | `3072` |  |
| wso2.config.mediation.synapse.threadsQueueLength | int | `10` |  |
| wso2.config.messageBuilders.blocking | list | `{"applicationBinary":"org.apache.axis2.format.BinaryBuilder","applicationJson":"org.wso2.micro.integrator.core.json.JsonStreamBuilder","applicationXml":"org.apache.axis2.builder.ApplicationXMLBuilder","formUrlencoded":"org.apache.synapse.commons.builders.XFormURLEncodedBuilder","jsonBadgerfish":"org.apache.axis2.json.JSONBadgerfishOMBuilder","multipartFormData":"org.apache.axis2.builder.MultipartFormDataBuilder","octetStream":"org.wso2.carbon.relay.BinaryRelayBuilder","textJavascript":"org.apache.axis2.json.JSONBuilder","textPlain":"org.apache.axis2.format.PlainTextBuilder"}` | Required for configuring the message builder implementation that is used to build messages that are received by the Micro Integrator in blocking mode |
| wso2.config.messageBuilders.custom.blocking | list | `[{"class":"","contentType":""}]` | List of custom message builder implementation class and the selected content types to which the builder should apply in blocking mode |
| wso2.config.messageBuilders.custom.nonBlocking | list | `[{"class":"","contentType":""}]` | List of custom message builder implementation class and the selected content types to which the builder should apply in non-blocking mode |
| wso2.config.messageBuilders.nonBlocking | list | `{"applicationBinary":"org.apache.axis2.format.BinaryBuilder","applicationJson":"org.wso2.micro.integrator.core.json.JsonStreamBuilder","applicationXml":"org.apache.axis2.builder.ApplicationXMLBuilder","formUrlencoded":"org.apache.synapse.commons.builders.XFormURLEncodedBuilder","jsonBadgerfish":"org.apache.axis2.json.JSONBadgerfishOMBuilder","multipartFormData":"org.apache.axis2.builder.MultipartFormDataBuilder","octetStream":"org.wso2.carbon.relay.BinaryRelayBuilder","textJavascript":"org.apache.axis2.json.JSONBuilder","textPlain":"org.apache.axis2.format.PlainTextBuilder"}` | Required for configuring the message builder implementation that is used to build messages that are received by the Micro Integrator in non-blocking mode |
| wso2.config.messageFormatters.blocking | list | `{"applicationBinary":"org.apache.axis2.format.BinaryFormatter","applicationJson":"org.wso2.micro.integrator.core.json.JsonStreamFormatter","applicationXml":"org.apache.axis2.transport.http.ApplicationXMLFormatter","formUrlencoded":"org.apache.synapse.commons.formatters.XFormURLEncodedFormatter","jsonBadgerfish":"org.apache.axis2.json.JSONBadgerfishMessageFormatter","multipartFormData":"org.apache.axis2.transport.http.MultipartFormDataFormatter","octetStream":"org.wso2.carbon.relay.ExpandingMessageFormatter","soapXml":"org.apache.axis2.transport.http.SOAPMessageFormatter","textJavascript":"org.apache.axis2.json.JSONMessageFormatter","textPlain":"org.apache.axis2.format.PlainTextFormatter","textXml":"org.apache.axis2.transport.http.SOAPMessageFormatter"}` | Required for configuring the message formatting implementation that is used for formatting messages that are sent out of the Micro Integrator in blocking mode |
| wso2.config.messageFormatters.custom.blocking | list | `[{"class":"","contentType":""}]` | List of custom message formatter implementation class and the selected content types to which the formatter should apply in blocking mode |
| wso2.config.messageFormatters.custom.nonBlocking | list | `[{"class":"","contentType":""}]` | List of custom message formatter implementation class and the selected content types to which the formatter should apply in non-blocking mode |
| wso2.config.messageFormatters.nonBlocking | list | `{"applicationBinary":"org.apache.axis2.format.BinaryFormatter","applicationJson":"org.wso2.micro.integrator.core.json.JsonStreamFormatter","applicationXml":"org.apache.axis2.transport.http.ApplicationXMLFormatter","formUrlencoded":"org.apache.synapse.commons.formatters.XFormURLEncodedFormatter","jsonBadgerfish":"org.apache.axis2.json.JSONBadgerfishMessageFormatter","multipartFormData":"org.apache.axis2.transport.http.MultipartFormDataFormatter","octetStream":"org.wso2.carbon.relay.ExpandingMessageFormatter","soapXml":"org.apache.axis2.transport.http.SOAPMessageFormatter","textJavascript":"org.apache.axis2.json.JSONMessageFormatter","textPlain":"org.apache.axis2.format.PlainTextFormatter","textXml":"org.apache.axis2.transport.http.SOAPMessageFormatter"}` | Required for configuring the message formatting implementation that is used for formatting messages that are sent out of the Micro Integrator in non-blocking mode |
| wso2.config.opentelemetry.enable | bool | `false` | Enable/Disable OpenTelemetry |
| wso2.config.opentelemetry.host | string | `nil` | Hostname of the OpenTelemetry tracing system |
| wso2.config.opentelemetry.port | string | `nil` | Port of the OpenTelemetry tracing system |
| wso2.config.opentelemetry.type | string | `nil` | OpenTelemetry tracing system. Supported values: jaeger, zipkin, log and otlp |
| wso2.config.opentelemetry.logs | string | `nil` | Enable logs for OpenTelemetry |
| wso2.config.opentelemetry.url | string | `nil` | Url of the OpenTelemetry tracing system. Instead of ‘host’ and ‘port’, ‘url’ can be used |
| wso2.config.portOffset | int | `10` | Port offset for Micro Integrator (https://apim.docs.wso2.com/en/latest/install-and-setup/setup/deployment-best-practices/changing-the-default-ports-with-offset/#changing-the-default-mi-ports) |
| wso2.config.secureVault.enabled | bool | `false` | Enable/Disable secure vault |
| wso2.config.serviceCatalog | object | `{"apimHost":"","enabled":false,"password":"","username":""}` | Required if you want the Micro Integrator to publish integation services to the Service Catalog in the API Publisher (https://apim.docs.wso2.com/en/4.1.0/tutorials/integration-tutorials/service-catalog-tutorial/#step-3-configure-the-micro-integrator) |
| wso2.config.serviceCatalog.apimHost | string | `""` | API Manager runtime URL. (https://{hostname/ip}:{port}) |
| wso2.config.serviceCatalog.enabled | bool | `false` | Enable/Disable service catalog |
| wso2.config.serviceCatalog.password | string | `""` | Password for signing in to the API Manager runtime |
| wso2.config.serviceCatalog.username | string | `""` | User name for signing in to the API Manager runtime |
| wso2.config.synapseHandlers | list | `[{"class":"","name":""}]` | List of synapse handlers with the name and the implementation class |
| wso2.config.synapseProperties | list | `nil` | List of synapse properties |
| wso2.config.transport.http.blocking.listener.enable | bool | `true` |  |
| wso2.config.transport.http.blocking.listener.hostname | string | `""` |  |
| wso2.config.transport.http.blocking.listener.originServer | string | `""` |  |
| wso2.config.transport.http.blocking.listener.port | int | `8280` |  |
| wso2.config.transport.http.blocking.listener.requestCoreThreadPoolSize | string | `""` |  |
| wso2.config.transport.http.blocking.listener.requestMaxThreadPoolSize | string | `""` |  |
| wso2.config.transport.http.blocking.listener.requestTcpNoDelay | string | `""` |  |
| wso2.config.transport.http.blocking.listener.requestTimeout | string | `""` |  |
| wso2.config.transport.http.blocking.listener.threadKeepaliveTime | string | `""` |  |
| wso2.config.transport.http.blocking.listener.threadKeepaliveTimeUnit | string | `""` |  |
| wso2.config.transport.http.blocking.sender.defaultConnectionsPerHost | int | `200` |  |
| wso2.config.transport.http.blocking.sender.enable | bool | `true` |  |
| wso2.config.transport.http.blocking.sender.enableClientCaching | bool | `true` |  |
| wso2.config.transport.http.blocking.sender.omitSoap12Action | bool | `true` |  |
| wso2.config.transport.http.blocking.sender.proxyHost | string | `""` |  |
| wso2.config.transport.http.blocking.sender.proxyPort | int | `nil` |  |
| wso2.config.transport.http.blocking.sender.securedDefaultConnectionsPerHost | int | `200` |  |
| wso2.config.transport.http.blocking.sender.securedEnable | bool | `true` |  |
| wso2.config.transport.http.blocking.sender.securedEnableClientCaching | bool | `true` |  |
| wso2.config.transport.http.blocking.sender.securedOmitSoap12Action | bool | `true` |  |
| wso2.config.transport.http.blocking.sender.securedProxyHost | string | `""` |  |
| wso2.config.transport.http.blocking.sender.securedProxyPort | int | `nil` |  |
| wso2.config.transport.http.blocking.sender.securedSoTimeout | int | `60000` |  |
| wso2.config.transport.http.blocking.sender.securedTransferEncoding | string | `"chunked"` |  |
| wso2.config.transport.http.blocking.sender.soTimeout | int | `60000` |  |
| wso2.config.transport.http.blocking.sender.transferEncoding | string | `"chunked"` |  |
| wso2.config.transport.http.nonBlocking.coreWorkerPoolSize | int | `400` | number of core threads used by the executor pool |
| wso2.config.transport.http.nonBlocking.disableConnectionKeepalive | bool | `false` | Enables/disables backend HTTP connection close after the request is served |
| wso2.config.transport.http.nonBlocking.enableMessageSizeValidation | bool | `false` | If this property is enabled and the payload exceeds the size specified by the 'maxMessageSizeBytes' property, the Micro Integrator will discontinue reading the input stream |
| wso2.config.transport.http.nonBlocking.forceJsonValidation | bool | `false` | Validates JSON messages by parsing the input message |
| wso2.config.transport.http.nonBlocking.forceXmlValidation | bool | `false` | This property validates badly formed XML messages by building the whole XML document |
| wso2.config.transport.http.nonBlocking.ioBufferSize | int | `16384` | Memory buffer allocated when reading data into the memory from the underlying socket/file channels |
| wso2.config.transport.http.nonBlocking.listener.bindAddress | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.certificateRevocationCacheDelay | int | `1000` |  |
| wso2.config.transport.http.nonBlocking.listener.certificateRevocationCacheSize | int | `1024` |  |
| wso2.config.transport.http.nonBlocking.listener.certificateRevocationVerifierEnable | bool | `false` |  |
| wso2.config.transport.http.nonBlocking.listener.enable | bool | `true` |  |
| wso2.config.transport.http.nonBlocking.listener.keystore.fileName | string | `"wso2carbon.jks"` |  |
| wso2.config.transport.http.nonBlocking.listener.keystore.keyPassword | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.keystore.password | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.keystore.type | string | `"JKS"` |  |
| wso2.config.transport.http.nonBlocking.listener.port | int | `8280` |  |
| wso2.config.transport.http.nonBlocking.listener.preferredCiphers | string | `"TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"` |  |
| wso2.config.transport.http.nonBlocking.listener.securedBindAddress | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.securedEnable | bool | `true` |  |
| wso2.config.transport.http.nonBlocking.listener.securedPort | int | `8243` |  |
| wso2.config.transport.http.nonBlocking.listener.securedProtocols | string | `"TLSv1,TLSv1.1,TLSv1.2"` |  |
| wso2.config.transport.http.nonBlocking.listener.securedWsdlEprPrefix | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.sslProfile.filePath | string | `"conf/sslprofiles/listenerprofiles.xml"` |  |
| wso2.config.transport.http.nonBlocking.listener.sslProfile.readInterval | int | `30000` |  |
| wso2.config.transport.http.nonBlocking.listener.truststore.fileName | string | `"client-truststore.jks"` |  |
| wso2.config.transport.http.nonBlocking.listener.truststore.password | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.truststore.type | string | `"JKS"` |  |
| wso2.config.transport.http.nonBlocking.listener.verifyClient | string | `""` |  |
| wso2.config.transport.http.nonBlocking.listener.wsdlEprPrefix | string | `""` |  |
| wso2.config.transport.http.nonBlocking.maxHttpConnectionPerHostPort | int | `32767` | Maximum number of connections allowed per host port |
| wso2.config.transport.http.nonBlocking.maxMessageSizeBytes | int | `2147483647` | If the size of the payload exceeds this value, the Micro Integrator will discontinue reading the input stream. Only applicable if the enableMessageSizeValidation property is enabled |
| wso2.config.transport.http.nonBlocking.maxOpenConnections | int | `-1` | Restrict the number of simultaneously opened connections |
| wso2.config.transport.http.nonBlocking.maxWorkerPoolSize | int | `400` | This is the maximum number of threads in the worker thread pool |
| wso2.config.transport.http.nonBlocking.preserveHttpHeaders | list | `["Content-Type"]` | Header field/s of messages passing through the EI that need to be preserved |
| wso2.config.transport.http.nonBlocking.preserveHttpServerName | bool | `true` |  |
| wso2.config.transport.http.nonBlocking.preserveHttpUserAgent | bool | `false` | Preserves the HTTP user agent header |
| wso2.config.transport.http.nonBlocking.reverseProxyMode | bool | `false` |  |
| wso2.config.transport.http.nonBlocking.sender.certificateRevocationCacheDelay | int | `1000` |  |
| wso2.config.transport.http.nonBlocking.sender.certificateRevocationCacheSize | int | `1024` |  |
| wso2.config.transport.http.nonBlocking.sender.certificateRevocationVerifierEnable | bool | `false` |  |
| wso2.config.transport.http.nonBlocking.sender.enable | bool | `true` |  |
| wso2.config.transport.http.nonBlocking.sender.hostnameVerifier | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.keystore.fileName | string | `"wso2carbon.jks"` |  |
| wso2.config.transport.http.nonBlocking.sender.keystore.keyPassword | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.keystore.password | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.keystore.type | string | `"JKS"` |  |
| wso2.config.transport.http.nonBlocking.sender.nonProxyHosts | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.proxyHost | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.proxyPort | string | `nil` |  |
| wso2.config.transport.http.nonBlocking.sender.securedEnable | bool | `true` |  |
| wso2.config.transport.http.nonBlocking.sender.securedProtocols | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.securedProxyHost | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.securedProxyPort | string | `nil` |  |
| wso2.config.transport.http.nonBlocking.sender.sslProfile.filePath | string | `"conf/sslprofiles/senderprofiles.xml"` |  |
| wso2.config.transport.http.nonBlocking.sender.sslProfile.readInterval | int | `30000` |  |
| wso2.config.transport.http.nonBlocking.sender.truststore.fileName | string | `"client-truststore.jks"` |  |
| wso2.config.transport.http.nonBlocking.sender.truststore.password | string | `""` |  |
| wso2.config.transport.http.nonBlocking.sender.truststore.type | string | `"JKS"` |  |
| wso2.config.transport.http.nonBlocking.sender.warnOnHttp500 | string | `""` |  |
| wso2.config.transport.http.nonBlocking.socketTimeout | int | `180000` | This is the maximum period of inactivity between two consecutive data packets, specified in milliseconds |
| wso2.config.transport.http.nonBlocking.workerPoolQueueLength | int | `-1` | Defines the length of the queue that is used to hold runnable tasks to be executed by the worker pool |
| wso2.config.transport.jms.listener | list | `[{"name":"","parameters":{"initial_naming_factory":"","provider_url":"","session_transaction":true}}]` | JMS Listener configurations in blocking mode |
| wso2.config.transport.jms.listener[0] | object | `{"name":"","parameters":{"initial_naming_factory":"","provider_url":"","session_transaction":true}}` | JMS Listener name in blocking mode |
| wso2.config.transport.jms.listener[0].parameters | object | `{"initial_naming_factory":"","provider_url":"","session_transaction":true}` | JMS Listener parameters in blocking mode |
| wso2.config.transport.jms.sender | list | `[{"name":"","parameters":{"initial_naming_factory":"","provider_url":""}}]` | JMS Sender configurations in blocking mode |
| wso2.config.transport.jms.sender[0] | object | `{"name":"","parameters":{"initial_naming_factory":"","provider_url":""}}` | JMS Sender name in blocking mode |
| wso2.config.transport.jms.sender[0].parameters | object | `{"initial_naming_factory":"","provider_url":""}` | JMS Sender parameters in blocking mode |
| wso2.config.transport.jndi.connectionFactories | list | `[{"name":"","url":""}]` | List of JNDI connection factories |
| wso2.config.transport.jndi.connectionFactories[0] | object | `{"name":"","url":""}` | JNDI connection factory name |
| wso2.config.transport.jndi.connectionFactories[0].url | string | `""` | JNDI connection factory url |
| wso2.config.transport.jndi.queue | list | `[{"jndiName":"","physicalName":""}]` | List of queues that are defined in the JMS broker |
| wso2.config.transport.jndi.queue[0] | object | `{"jndiName":"","physicalName":""}` | JNDI queue name |
| wso2.config.transport.jndi.queue[0].physicalName | string | `""` | Actual queue name |
| wso2.config.transport.jndi.topic | list | `[{"jndiName":"","physicalName":""}]` | List of topics that are defined in the JMS broker |
| wso2.config.transport.jndi.topic[0] | object | `{"jndiName":"","physicalName":""}` | JNDI topic name |
| wso2.config.transport.jndi.topic[0].physicalName | string | `""` | Actual topic name |
| wso2.config.transport.rabbitmq.listener | list | `[{"name":"","parameters":null}]` | RabbitMQ Listener configurations in blocking mode |
| wso2.config.transport.rabbitmq.listener[0] | object | `{"name":"","parameters":null}` | RabbitMQ Listener name in blocking mode |
| wso2.config.transport.rabbitmq.listener[0].parameters | list | `nil` | RabbitMQ Listener parameters in blocking mode (https://apim.docs.wso2.com/en/4.1.0/reference/config-catalog-mi/#rabbitmq-listener) |
| wso2.config.transport.rabbitmq.sender | list | `[{"name":"","parameters":null}]` | RabbitMQ Sender configurations in blocking mode |
| wso2.config.transport.rabbitmq.sender[0] | object | `{"name":"","parameters":null}` | RabbitMQ Sender name in blocking mode |
| wso2.config.transport.rabbitmq.sender[0].parameters | list | `nil` | RabbitMQ Sender parameters in blocking mode (https://apim.docs.wso2.com/en/4.1.0/reference/config-catalog-mi/#rabbitmq-sender) |
| wso2.config.transport.vfs.listener.customParameters | list | `nil` | List of custom parameters for VFS listener |
| wso2.config.transport.vfs.listener.enable | bool | `true` |  |
| wso2.config.transport.vfs.listener.keystore.alias | string | `"wso2carbon"` |  |
| wso2.config.transport.vfs.listener.keystore.fileName | string | `"wso2carbon.jks"` |  |
| wso2.config.transport.vfs.listener.keystore.keyPassword | string | `""` |  |
| wso2.config.transport.vfs.listener.keystore.password | string | `""` |  |
| wso2.config.transport.vfs.listener.keystore.type | string | `"JKS"` |  |
| wso2.config.transport.vfs.sender.customParameters | list | `nil` | List of custom parameters for VFS sender |
| wso2.config.transport.vfs.sender.enable | bool | `true` |  |
| wso2.config.trustStore.primary.fileName | string | `"client-truststore.jks"` | Primary truststore file name |
| wso2.config.trustStore.primary.password | string | `""` | Primary truststore password |
| wso2.config.userstore.file.enabled | bool | `true` | Enable/Disable file based userstore |
| wso2.config.userstore.ldap.anonymousBind | bool | `false` |  |
| wso2.config.userstore.ldap.backLinksEnabled | bool | `false` |  |
| wso2.config.userstore.ldap.class | string | `"org.wso2.micro.integrator.security.user.core.ldap.ReadOnlyLDAPUserStoreManager"` |  |
| wso2.config.userstore.ldap.connectionName | string | `""` |  |
| wso2.config.userstore.ldap.connectionPassword | string | `""` |  |
| wso2.config.userstore.ldap.connectionPoolingEnabled | bool | `true` |  |
| wso2.config.userstore.ldap.connectionUrl | string | `""` |  |
| wso2.config.userstore.ldap.displayNameAttribute | string | `""` |  |
| wso2.config.userstore.ldap.groupNameAttribute | string | `""` |  |
| wso2.config.userstore.ldap.groupNameListFilter | string | `""` |  |
| wso2.config.userstore.ldap.groupNameSearchFilter | string | `""` |  |
| wso2.config.userstore.ldap.groupSearchBase | string | `""` |  |
| wso2.config.userstore.ldap.ldapConnectionTimeout | int | `5000` |  |
| wso2.config.userstore.ldap.maxRoleNameListLength | int | `100` |  |
| wso2.config.userstore.ldap.maxUserNameListLength | int | `100` |  |
| wso2.config.userstore.ldap.membershipAttribute | string | `""` |  |
| wso2.config.userstore.ldap.multiAttributeSeparator | string | `","` |  |
| wso2.config.userstore.ldap.passwordHashMethod | string | `"PLAIN_TEXT"` |  |
| wso2.config.userstore.ldap.passwordJavaRegex | string | `"^[\\S]{5,30}$"` |  |
| wso2.config.userstore.ldap.readGroups | bool | `true` |  |
| wso2.config.userstore.ldap.readOnly | bool | `false` |  |
| wso2.config.userstore.ldap.readTimeout | int | `nil` |  |
| wso2.config.userstore.ldap.replaceEscapeCharactersAtUserLogin | bool | `true` |  |
| wso2.config.userstore.ldap.retryAttempts | int | `nil` |  |
| wso2.config.userstore.ldap.rolenameJavaRegex | string | `"[a-zA-Z0-9._\\-|//]{3,30}$"` |  |
| wso2.config.userstore.ldap.scimEnabled | bool | `false` |  |
| wso2.config.userstore.ldap.type | string | `"read_only_ldap"` |  |
| wso2.config.userstore.ldap.userNameAttribute | string | `""` |  |
| wso2.config.userstore.ldap.userNameListFilter | string | `""` |  |
| wso2.config.userstore.ldap.userNameSearchFilter | string | `""` |  |
| wso2.config.userstore.ldap.userRolesCacheEnabled | bool | `true` |  |
| wso2.config.userstore.ldap.userSearchBase | string | `""` |  |
| wso2.config.userstore.ldap.usernameJavaRegex | string | `"[a-zA-Z0-9._\\-|//]{3,30}$"` |  |
| wso2.config.userstore.rdbms.jdbc.driver | string | `""` | JDBC driver class name of the User Database |
| wso2.config.userstore.rdbms.jdbc.poolParameters | list | `nil` | JDBC connection pool parameters of the User Database |
| wso2.config.userstore.rdbms.password | string | `""` | User Database password |
| wso2.config.userstore.rdbms.url | string | `""` | User Database URL |
| wso2.config.userstore.rdbms.username | string | `""` | User Database username |
| wso2.config.vault.hashicorp | object | `{"address":null,"cacheableDuration":15000,"engineVersion":2,"keyStoreFile":null,"keyStorePassword":null,"namespace":null,"roleId":null,"rootToken":null,"secretId":null,"trustStoreFile":null}` | HashiCorp Vault configurations |
| wso2.config.vault.hashicorp.address | string | `nil` | HashiCorp Vault URL |
| wso2.config.vault.hashicorp.cacheableDuration | int | `15000` | All resources fetched from the HashiCorp vault are cached for this number of milliseconds |
| wso2.config.vault.hashicorp.engineVersion | int | `2` | The version of the HashiCorp secret engine |
| wso2.config.vault.hashicorp.keyStoreFile | string | `nil` | The Key store that is used for SSL communication with the HashiCorp server |
| wso2.config.vault.hashicorp.keyStorePassword | string | `nil` | The password of the keystore file that is used for SSL communication |
| wso2.config.vault.hashicorp.namespace | string | `nil` | The namespace value specified here applies globally to HashiCorp secrets in all synapse configurations |
| wso2.config.vault.hashicorp.roleId | string | `nil` | AppRole authentication roleId |
| wso2.config.vault.hashicorp.rootToken | string | `nil` | Static Token authentication |
| wso2.config.vault.hashicorp.secretId | string | `nil` | AppRole authentication secretId |
| wso2.config.vault.hashicorp.trustStoreFile | string | `nil` | The Trust store that is used for SSL communication with the HashiCorp server |
| wso2.deployment.BuildVersion | string | `"4.4.0"` | Build version of the Micro Integrator |
| wso2.deployment.JKSSecretName | string | `""` | K8s secret name which contains JKS files |
| wso2.deployment.cmdArgs | string | `nil` | List of Command line arguments passed to startup script |
| wso2.deployment.configMaps | object | `{"entryPoint":{"defaultMode":"0407"}}` | Set UNIX permissions over the startup scripts |
| wso2.deployment.envs | list | `nil` | Environment variables for the Micro integrator deployment |
| wso2.deployment.annotations | list | `nil` | Annotations for the Micro integrator deployment |
| wso2.deployment.hostname | string | `""` | Hostname of the Micro Integrator deployment |
| wso2.deployment.hpa | object | `{"cpuUtilizationPercentage":75,"enabled":false,"maxReplicas":2,"memoryUtilizationPercentage":75,"minReplicas":1}` | Horizontal Pod Autoscaler (HPA) configurations (https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| wso2.deployment.hpa.cpuUtilizationPercentage | int | `75` | Average CPU utilization percentage for HPA |
| wso2.deployment.hpa.enabled | bool | `false` | Enable/Disable Horizontal Pod Autoscaler (HPA) |
| wso2.deployment.hpa.maxReplicas | int | `2` | Max replica count for HPA |
| wso2.deployment.hpa.memoryUtilizationPercentage | int | `75` | Average memory utilization percentage for HPA |
| wso2.deployment.hpa.minReplicas | int | `1` | Min replica count for HPA |
| wso2.deployment.image.digest | string | `""` | Container image digest |
| wso2.deployment.image.pullPolicy | string | `"Always"` | Container image pull policy. Refer (https://kubernetes.io/docs/concepts/containers/images/#updating-images) |
| wso2.deployment.image.repository | string | `""` | Container image repository name |
| wso2.deployment.mountCapps | bool | `false` | Incase the CApps are not burned into the docker image, set the following to `true` to mount the CApps using a persistent volume |
| wso2.deployment.pdb | object | `{"enabled":false,"minAvailable":1}` | Pod disruption budget configurations (https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| wso2.deployment.pdb.enabled | bool | `false` | Enable/Disable pod disruption budget |
| wso2.deployment.pdb.minAvailable | int | `1` | Min available pods for pod disruption budget |
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
| wso2.deployment.securityContext.enableRunAsGroup | bool | `true` |  |
| wso2.deployment.securityContext.enableRunAsUser | bool | `true` |  |
| wso2.deployment.securityContext.runAsGroup | string | `"10802"` | The GID to run the entrypoint of the container process |
| wso2.deployment.securityContext.runAsUser | string | `"10802"` | The UID to run the entrypoint of the container process |
| wso2.deployment.securityContext.seLinux.enabled | bool | `false` |  |
| wso2.deployment.securityContext.seLinux.level | string | `"s0:c26,c0"` |  |
| wso2.deployment.securityContext.seccompProfile | object | `{"enabled":true,"type":"RuntimeDefault"}` | Enable/Disable seccomp profile (https://kubernetes.io/docs/tutorials/security/seccomp/) |
| wso2.deployment.securityContext.seccompProfile.enabled | bool | `true` | Enable/Disable seccomp profile |
| wso2.deployment.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Seccomp profile type |
| wso2.deployment.strategy.rollingUpdate.maxSurge | int | `1` | The maximum number of pods that can be scheduled above the desired number of pods. |
| wso2.deployment.strategy.rollingUpdate.maxUnavailable | int | `0` | The maximum number of pods that can be unavailable during the update. |
| wso2.deployment.synapseTest.enabled | bool | `false` | Enable/Disable synapse testing |
| wso2.ingress.annotations | list | `nil` | Ingress annotations |
| wso2.ingress.enabled | bool | `true` | Enable Ingress for MI |
| wso2.ingress.ingressClassName | string | `""` | Ingress class name |
| wso2.ingress.ratelimit.burstLimit | string | `""` | Ingress ratelimit burst limit |
| wso2.ingress.ratelimit.enabled | bool | `false` | Ingress rate limit |
| wso2.ingress.ratelimit.zoneName | string | `""` | Ingress ratelimit zone name |
| wso2.ingress.tlsSecret | string | `""` | K8s TLS secret for configured hostname |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
