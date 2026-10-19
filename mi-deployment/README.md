# WSO2 Micro Integrator 4.4.0 — High Availability Production Deployment

Production-grade deployment of **WSO2 Micro Integrator (MI) 4.4.0** on Kubernetes / OpenShift, featuring High Availability across worker nodes, dynamic Nimble-backed NFS storage, and ingress via Envoy Gateway with internal wildcard TLS certificates.

---

## Architecture Overview

```text
                           Sybyl Enterprise Network
                                       │
                      [DNS: mi.sybyl.int (Internal CA)]
                                       │
                                       ▼
                       MetalLB LoadBalancer VIP: 172.18.10.246
                                       │
                         Envoy Gateway (Gateway API v1)
                           Port 443 (HTTPS) - *.sybyl.int
                                       │
                   ┌───────────────────┴───────────────────┐
                   │                                       │
    PathPrefix: /management                 PathPrefix: / (Services)
                   ▼                                       ▼
         Port 9201 (HTTP)                        Port 8290 (HTTP)
                   │                                       │
                   └───────────────────┬───────────────────┘
                                       │
        ┌──────────────────────────────┴──────────────────────────────┐
        ▼                                                             ▼
WSO2 MI Pod 1 (idpk8swkr1)                                    WSO2 MI Pod 2 (idpk8swkr2)
Namespace: wso2-mi                                            Namespace: wso2-mi
Active-Active Replica                                         Active-Active Replica
        │                                                             │
        ├──────────────────────────────┬──────────────────────────────┤
        ▼                                                             ▼
┌───────────────────────────────┐             ┌───────────────────────────────┐
│     mi-carbonapps-pvc         │             │          mi-libs-pvc          │
│   (2 Gi, ReadWriteMany)       │             │     (1 Gi, ReadWriteMany)     │
│       StorageClass: nfs-csi   │             │         StorageClass: nfs-csi │
│  Nimble Storage Provisioner   │             │   Nimble Storage Provisioner  │
│  Mount: .../server/carbonapps │             │   Mount: .../lib              │
└───────────────────────────────┘             └───────────────────────────────┘
```

---

## Key Highlights

1. **Dedicated Namespace (`wso2-mi`)**:
   - Completely isolated from API Manager (`wso2-apim`) to prevent service name or secret conflicts.
2. **Active-Active High Availability (HA)**:
   - 2 replicas scheduled across different physical worker nodes (`idpk8swkr1` and `idpk8swkr2`).
   - `PodDisruptionBudget` (`minAvailable: 1`) guarantees availability during node drains or rolling upgrades.
   - Zero-downtime rolling update strategy (`maxSurge: 1, maxUnavailable: 0`).
3. **Storage Best Practices (Nimble NFS via `nfs-csi`)**:
   - **`mi-carbonapps-pvc` (2 Gi, RWX)**: Shared directory for Carbon Applications (`.car` files). Any `.car` file dropped here is automatically hot-deployed across both replicas simultaneously.
   - **`mi-libs-pvc` (1 Gi, RWX)**: Shared directory for JDBC drivers (PostgreSQL, MySQL, Oracle, MSSQL) and custom connectors. Dropped JARs are picked up upon pod restart without needing Docker image rebuilds.
4. **Lean Container Strategy**:
   - Uses the official public Docker image `wso2/wso2mi:4.4.0` from DockerHub. No paid WSO2 subscription login required.
5. **Gateway API & TLS Termination**:
   - Terminated at Envoy Gateway on port 443 with the internal enterprise wildcard certificate (`*.sybyl.int`).
   - Traffic to the Management API (`/management`) routes cleanly to port `9201`.
   - Pass-through integration services traffic routes to port `8290`.

---

## Directory Structure

```text
mi-deployment/
├── README.md                          # This deployment guide
└── helm-mi/
    ├── deploy-mi.sh                   # Automated deployment & lifecycle script
    ├── mi-gateway-resources.yaml       # Gateway API Gateway and NFS PVC definitions
    ├── README.md                      # Chart reference notes
    └── mi/                            # WSO2 MI Helm Chart
        ├── Chart.yaml                 # Helm chart metadata
        ├── values.yaml                # Production configuration values
        ├── confs/
        │   └── deployment.toml        # Templated WSO2 MI configuration
        ├── security/
        │   ├── wso2carbon.jks         # Primary Java Keystore
        │   └── client-truststore.jks  # Truststore with CA certs
        ├── carbonapps/
        │   └── HelloWorld_1.0.0.car   # Sample verification Carbon Application
        └── templates/
            ├── mi-deployment.yaml     # Kubernetes Deployment with PDB & NFS mounts
            ├── mi-service.yaml        # ClusterIP Service (8290, 8253, 9164, 9201)
            ├── mi-gateway-httproute.yaml # Gateway API HTTPRoute for mi.sybyl.int
            ├── mi-conf.yaml           # deployment.toml ConfigMap
            ├── mi-conf-entrypoint.yaml# Startup entrypoint ConfigMap
            ├── mi-pdb.yaml            # PodDisruptionBudget
            └── _helpers.tpl           # Template helper macros
```

---

## Prerequisites

- Kubernetes cluster (`v1.26+`) with Gateway API CRDs (`gateway.networking.k8s.io/v1`).
- Envoy Gateway controller running in `envoy-gateway-system`.
- MetalLB configured with available IP pool (e.g. `172.18.10.245 - 254`).
- StorageClass `nfs-csi` backed by Nimble storage.
- Wildcard TLS certificates in `~/intlabcrt/`:
  - `sybyl-int-wildcard-1yr.crt`
  - `sybyl-int-wildcard-1yr.key`
  - `sybyl_int_root_ca.crt`

---

## Deployment Instructions

### 1. Execute the Deployment Script

Run the automated deployment script from the `helm-mi` directory:

```bash
cd mi-deployment/helm-mi
./deploy-mi.sh
```

The script automatically performs:
1. Creates namespace `wso2-mi` (if not present).
2. Generates the wildcard TLS secret `wso2-mi-wildcard-tls` for `*.sybyl.int`.
3. Creates the keystore secret `mi-keystores` containing `wso2carbon.jks` and `client-truststore.jks`.
4. Applies `mi-gateway-resources.yaml` to provision the Envoy Gateway and the two NFS PVCs (`mi-carbonapps-pvc` and `mi-libs-pvc`).
5. Executes `helm upgrade --install mi ./mi --namespace wso2-mi --wait --timeout 5m`.

### 2. Verify Resources

```bash
# Check Pods (Both should be 1/1 Running across wkr1 and wkr2)
kubectl get pods -n wso2-mi -o wide

# Check Gateway and HTTPRoute
kubectl get gateway,httproute -n wso2-mi

# Check Shared PVCs
kubectl get pvc -n wso2-mi
```

Expected output:
```text
NAME                         READY   STATUS    RESTARTS   AGE   IP               NODE
wso2mi-mi-6c744568f6-nvssf   1/1     Running   0          1h    10.244.130.50    idpk8swkr1
wso2mi-mi-6c744568f6-x42rw   1/1     Running   0          1h    10.244.187.250   idpk8swkr2

NAME                                                CLASS           ADDRESS         PROGRAMMED
gateway.gateway.networking.k8s.io/wso2-mi-gateway   envoy-gateway   172.18.10.246   True

NAME                                                         HOSTNAMES
httproute.gateway.networking.k8s.io/wso2mi-mi-mi-httproute   ["mi.sybyl.int"]
```

---

## Client Access & Testing

### 1. Update Workstation `/etc/hosts`

Add the MetalLB IP (`172.18.10.246`) to your local `/etc/hosts` file:

```text
172.18.10.246   mi.sybyl.int
```

### 2. Test Management API

Log in and obtain a JWT access token:

```bash
curl -k -s -u admin:admin --resolve "mi.sybyl.int:443:172.18.10.246" \
  https://mi.sybyl.int/management/login
```

Query deployed APIs using the token:

```bash
TOKEN=$(curl -k -s -u admin:admin --resolve "mi.sybyl.int:443:172.18.10.246" \
  https://mi.sybyl.int/management/login | python3 -c "import sys, json; print(json.load(sys.stdin)['AccessToken'])")

curl -k -H "Authorization: Bearer $TOKEN" --resolve "mi.sybyl.int:443:172.18.10.246" \
  https://mi.sybyl.int/management/apis
```

---

## Deploying Artifacts & Drivers

### Deploying Carbon Applications (`.car` files)

Copy your compiled `.car` file into the shared carbonapps volume on any running pod:

```bash
POD_NAME=$(kubectl get pods -n wso2-mi -l app.kubernetes.io/name=mi -o jsonpath='{.items[0].metadata.name}')

# Copy sample Hello World CAR or your custom CAR:
kubectl cp mi-deployment/helm-mi/mi/carbonapps/HelloWorld_1.0.0.car \
  wso2-mi/${POD_NAME}:/home/wso2carbon/wso2mi-4.4.0/repository/deployment/server/carbonapps/
```

Because the folder is backed by `mi-carbonapps-pvc` (NFS RWX), both replicas detect and hot-deploy the application immediately without restart.

### Adding Database JDBC Drivers & Connectors

To add a JDBC driver (e.g. PostgreSQL or Oracle driver):

```bash
kubectl cp postgresql-42.7.3.jar \
  wso2-mi/${POD_NAME}:/home/wso2carbon/wso2mi-4.4.0/lib/

# Trigger rolling restart to load the new library:
kubectl rollout restart deployment wso2mi-mi -n wso2-mi
```

---

## Uninstalling

To uninstall the MI release and clean up gateway resources:

```bash
cd mi-deployment/helm-mi
./deploy-mi.sh --uninstall
```
