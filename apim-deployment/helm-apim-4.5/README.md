# helm-apim

This repo maintains WSO2 API Manager Helm charts and supporting assets for deployment on OpenShift (ROSA) and other Kubernetes platforms.

---

## Repository Structure

```
apim-deployment/
├── apim/                        # Docker customization and database setup
│   ├── Dockerfile               # Custom APIM image for OpenShift compatibility
│   ├── DB_SETUP.md              # Database setup guide (start here for DB setup)
│   ├── mysql.yaml               # In-cluster MySQL manifest (dev/demo)
│   ├── db-scripts/
│   │   ├── apimgt/mysql.sql     # Schema for wso2amdb
│   │   └── shareddb/mysql.sql   # Schema for wso2shareddb
│   ├── keystores/               # Source keystore files (wso2carbon.jks, client-truststore.jks)
│   └── lib/
│       └── mysql-connector-j-8.0.32.jar   # MySQL JDBC driver (bundled into Docker image)
│
└── helm-apim/                   # Helm charts
    ├── README.md                # This file
    ├── apim-secrets/            # Keystore files used to create the Kubernetes secret
    ├── all-in-one/              # All-in-one deployment (single node / HA)
    │   ├── values.yaml          # Active deployment values
    │   ├── openshift-values.yaml
    │   ├── confs/               # TOML, log4j2, entrypoint, and frontend configs
    │   └── templates/           # Kubernetes resource templates
    └── distributed/             # Distributed deployment charts
        ├── control-plane/
        ├── gateway/
        ├── key-manager/
        └── traffic-manager/
```

---

## Prerequisites

- A running OpenShift (ROSA) or Kubernetes cluster.
- Helm 3.x and the `oc` / `kubectl` CLI installed.
- A custom APIM Docker image built from `apim/Dockerfile` and pushed to your container registry. The Dockerfile bundles the MySQL JDBC driver and applies the OpenShift-compatible permissions required by WSO2. Update `wso2.deployment.image` in `values.yaml` to point to your image.
- MySQL 8.x reachable from within the cluster, with both databases created and schemas applied. See [`apim/DB_SETUP.md`](../apim/DB_SETUP.md) for full instructions.
- Configure the mandatory symmetric encryption key (`wso2.apim.configurations.encryption.key`) before first startup. This key must be identical across all nodes in HA or distributed deployments.
- For routing, OpenShift Routes are used by default (configured in `values.yaml` under `kubernetes.route`). NGINX Ingress and Envoy Gateway API are also supported but disabled by default.
- If enabling Secure Vault, configure the secret manager for your cloud provider (AWS Secrets Manager, Azure Key Vault, or GCP Secret Manager).
- If enabling Solr indexing, provision persistent storage for the Carbon database and Solr index data.

---

## Deployment Guide

### Step 1: Build and Push the Custom Docker Image

The `apim/Dockerfile` extends the base WSO2 APIM image to bundle the MySQL JDBC driver and fix file permissions for OpenShift's restricted SCC (which runs containers as a non-root, arbitrary UID).

```bash
cd apim/
docker build -t <your-registry>/wso2am-openshift:<tag> .
docker push <your-registry>/wso2am-openshift:<tag>
```

Update `helm-apim/all-in-one/values.yaml`:

```yaml
wso2:
  deployment:
    image:
      registry: "<your-registry>"
      repository: "wso2am-openshift"
      tag: "<tag>"
```

---

### Step 2: Set Up the Databases

Follow **[`apim/DB_SETUP.md`](../apim/DB_SETUP.md)** for complete instructions. That guide covers:

- Deploying an in-cluster MySQL pod (dev/demo) or connecting to an external RDS instance (production).
- Creating the `wso2amdb` and `wso2shareddb` databases.
- Running the schema scripts from `apim/db-scripts/`.
- Creating the `wso2` database user with the required grants.

The `values.yaml` JDBC URLs reference the database by the Kubernetes service name `mysql:3306`. Ensure the service name matches your MySQL deployment before proceeding.

---

### Step 3: Create the Keystore Secret

APIM requires a Kubernetes secret containing the JKS keystore files. The keystore files are stored in `helm-apim/apim-secrets/`. The chart references this secret as `apim-keystore-secret` by default (configurable via `wso2.apim.configurations.security.jksSecretName`).

```bash
cd helm-apim/

oc create secret generic apim-keystore-secret \
  --from-file=wso2carbon.jks=apim-secrets/wso2carbon.jks \
  --from-file=client-truststore.jks=apim-secrets/client-truststore.jks \
  -n <namespace>
```

Verify both keys are present:

```bash
oc get secret apim-keystore-secret -n <namespace> -o jsonpath='{.data}' | tr ',' '\n'
```

You should see `wso2carbon.jks` and `client-truststore.jks` with base64-encoded values.

> If the secret already exists but is empty (e.g. from a previous failed install), replace it:
> ```bash
> oc create secret generic apim-keystore-secret \
>   --from-file=wso2carbon.jks=apim-secrets/wso2carbon.jks \
>   --from-file=client-truststore.jks=apim-secrets/client-truststore.jks \
>   -n <namespace> \
>   --dry-run=client -o yaml | oc replace -f -
> ```

---

### Step 4: Install the Helm Chart

Create the namespace if it doesn't exist:

```bash
oc create namespace <namespace>
```

Install or upgrade the chart from the `all-in-one/` directory:

```bash
cd helm-apim/all-in-one/
helm upgrade --install apim . -n <namespace> -f values.yaml
```

Watch the pod come up:

```bash
oc get pods -n <namespace> -w
```

> `startupProbe.initialDelaySeconds` defaults to `240` seconds — the pod takes 4+ minutes before it is marked ready. This is expected.

---

### Step 5: Verify the Deployment

Once the pod is running, the following endpoints are available (hostnames are configured under `kubernetes.route` in `values.yaml`):

| Console | URL |
|---|---|
| Publisher | `https://<management-hostname>/publisher` |
| DevPortal | `https://<management-hostname>/devportal` |
| Admin Portal | `https://<management-hostname>/admin` |
| Carbon Management | `https://<management-hostname>/carbon` |
| Gateway | `https://<gateway-hostname>` |
| Websocket | `https://<websocket-hostname>` |
| Websub | `https://<websub-hostname>` |

Admin credentials are set in `values.yaml` under `wso2.apim.configurations.adminUsername` and `adminPassword`.

---

### Step 6: Expose a Backend API

This example demonstrates publishing an API backed by a service running in the same cluster (e.g. WSO2 Micro Integrator).

**Find your backend service name:**

```bash
oc get service -n <namespace>
```

Always use the Kubernetes **service name** as the endpoint base URL rather than the ClusterIP, so it remains stable across restarts.

**Create the API in Publisher:**

1. Log in to the Publisher portal.
2. Click **Create API → REST API → Create from Scratch**.
3. Fill in the details:
   - **Name:** e.g. `Hello`
   - **Context:** e.g. `/hello`
   - **Version:** e.g. `v1`
   - **Endpoint:** base URL only — e.g. `http://<service-name>:8290`
4. Select **Universal Gateway** as the gateway type.
5. Under **Resources**, define the resource paths — e.g. `GET /hello`.
6. Click **Create & Publish**.

> A `405 Method Not Allowed` shown during the endpoint connectivity check is expected and harmless — it means APIM reached the backend. The probe hits the root path with an unsupported method.

> Do **not** append the resource path to the endpoint URL. Set only the base URL in the Endpoint field and define paths under Resources. Appending the path to the endpoint causes double-path forwarding and returns `404` at the gateway.

**Test the API:**

```
GET https://<gateway-hostname>/<context>/<version>/<resource>
Authorization: Bearer <token>
```

Generate a test token from the DevPortal by subscribing to the API and creating application keys.

---

## Deployment Patterns

The `helm-apim/docs/` directory contains reference configurations for the supported deployment patterns:

| Pattern | Description | Chart |
|---|---|---|
| `am-pattern-0-all-in-one` | Single all-in-one node | `all-in-one/` |
| `am-pattern-1-all-in-one-HA` | All-in-one with HA (2 replicas) | `all-in-one/` |
| `am-pattern-2-all-in-one_GW` | All-in-one + separate Gateway | `all-in-one/` + `distributed/gateway/` |
| `am-pattern-3-ACP_TM_GW` | Control Plane + Traffic Manager + Gateway | `distributed/` |
| `am-pattern-4-ACP_TM_GW_KM` | Above + external Key Manager | `distributed/` |
| `am-pattern-5-all-in-one_GW_KM` | All-in-one + Gateway + Key Manager | `all-in-one/` + `distributed/` |

See the README in each pattern directory under `docs/` for pattern-specific values.

---

## Sample Configurations

### AWS (EKS)

```yaml
wso2:
  apim:
    configurations:
      encryption:
        key: "<generated-64-char-hex-key>"

aws:
  enabled: true
  efs:
    capacity: "50Gi"
    directoryPerms: "0777"
    fileSystemId: "fs-12345678"
    accessPoints:
      carbonDb: "fsap-12345678"
      solr: "fsap-12345678"
  region: "<aws-region>"
  secretsManager:
    secretProviderClass: "wso2am-am-secret-provider-class"
    secretIdentifiers:
      secretEncryptionKey:
        secretName: "<secret_name>"
        secretKey: "<secret_key>"
  serviceAccountName: "<k8s-service-account>"
```

When `aws.enabled` is `true`, the chart assumes an EKS deployment and enables EFS-backed persistent volumes and AWS Secrets Manager integration. Refer to the [all-in-one README](all-in-one/README.md) for the full parameter reference.