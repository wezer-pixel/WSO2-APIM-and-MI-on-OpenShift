# WSO2 API Manager 4.7.0 Distributed Deployment (Pattern 3) + Micro Integrator 4.4.0

Production-grade deployment repository for **WSO2 API Manager 4.7.0** in a **Pattern 3 Distributed Architecture** (Control Plane, Gateway, Traffic Manager) and **WSO2 Micro Integrator 4.4.0** on Kubernetes.

---

## 1. Architectural Overview (Pattern 3 Distributed)

```
                            Sybyl Enterprise Network
                                        │
                         [DNS: *.sybyl.int (Internal CA)]
                                        │
                                        ▼
                      Envoy Gateway (Gateway API v1)
                    Port 443 / NodePort 31542 (HTTPS)
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        │ (*.sybyl.int)                 │ (gw.sybyl.int)                │ (websocket / websub)
        ▼                               ▼                               ▼
Control Plane (CP)              Universal Gateway (GW)          Async Gateways
2 Instances (Active-Active)     2 Instances (Active-Active)     - websocket.sybyl.int
- publisher.sybyl.int           - API runtime traffic           - websub.sybyl.int
- devportal.sybyl.int           - Port 8243 (HTTPS)
- admin.sybyl.int               - Port 8280 (HTTP)
        │                               │
        │ Artifacts sync                │ Throttling events
        ▼                               ▼
NFS CSI Shared Volume           Traffic Manager (TM)
(/home/wso2carbon/              2 Instances (Active-Active)
 wso2-shared-volume)            - Event processor / Siddhi
                                - Port 9763 / 9611 / 9711
                                        │
        └───────────────────────────────┼───────────────────────────────┘
                                        ▼
                          External PostgreSQL 16/18
                                172.18.10.143:5432
                         ├── apim_dist_db   (APIM metadata)
                         └── shared_dist_db (Registry & Userstore)
```

### Components & Sizing
| Role | Pod Count | CPU (Req / Limit) | Memory (Req / Limit) | JVM Memory | Storage / Mounts |
|---|---|---|---|---|---|
| **Control Plane (CP)** | 2 | 1.5 vCPU / 3 vCPU | 3 Gi / 5 Gi | `-Xms2048m -Xmx2560m` | NFS CSI Shared PVC (`wso2am-cp-shared-pvc`) |
| **Gateway (GW)** | 2 | 1 vCPU / 2 vCPU | 2 Gi / 4 Gi | `-Xms1536m -Xmx2048m` | Ephemeral |
| **Traffic Manager (TM)** | 2 | 0.5 vCPU / 1 vCPU | 1.5 Gi / 2.5 Gi | `-Xms1024m -Xmx1280m` | Ephemeral |

---

## 2. Cluster Topology & Infrastructure Details

- **Kubernetes Version**: `v1.37.1` (containerd `2.4.2`, Ubuntu 26.04)
- **Nodes**:
  - `idpk8smaster1` (`172.18.10.216`): Control Plane Master
  - `idpk8smaster2` (`172.18.10.55`): Control Plane Master
  - `idpk8smaster3` (`172.18.10.225`): Control Plane Master
  - `idpk8swkr1` (`172.18.10.74`): Worker Node 1
  - `idpk8swkr2` (`172.18.10.40`): Worker Node 2
- **Namespace**: `wso2-apim`
- **Ingress Controller**: Envoy Gateway (`v1.2.x+`) using Kubernetes Gateway API (`gateway.networking.k8s.io/v1`)
- **Shared Storage**: NFS CSI Driver (`nfs.csi.k8s.io`) pointing to `172.18.10.143:/srv/nfs/wso2-apim-shared`

---

## 3. Hostnames & Endpoints

| Service | Public / Internal Hostname | Routing Path | Target Component |
|---|---|---|---|
| **Publisher Portal** | `https://publisher.sybyl.int/publisher` | Envoy HTTPRoute | Control Plane (Port 9443) |
| **Developer Portal** | `https://devportal.sybyl.int/devportal` | Envoy HTTPRoute | Control Plane (Port 9443) |
| **Admin Portal** | `https://admin.sybyl.int/admin` | Envoy HTTPRoute | Control Plane (Port 9443) |
| **API Gateway (HTTPS)** | `https://gw.sybyl.int` | Envoy HTTPRoute | Gateway (Port 8243) |
| **WebSocket Gateway** | `wss://websocket.sybyl.int` | Envoy HTTPRoute | Gateway (Port 9099) |
| **WebSub Gateway** | `https://websub.sybyl.int` | Envoy HTTPRoute | Gateway (Port 9021) |
| **Traffic Manager** | `tm.sybyl.int` (Internal cluster) | ClusterIP Service | Traffic Manager (Port 9763) |
| **Micro Integrator (Services)** | `https://mi.sybyl.int/services/` | Envoy HTTPRoute (VIP: `172.18.10.246`) | Micro Integrator (Port 8290) |
| **Micro Integrator (Management)**| `https://mi.sybyl.int/management` | Envoy HTTPRoute (VIP: `172.18.10.246`) | Micro Integrator (Port 9201) |

---

## 4. Repository Structure

```text
.
├── Kubernetes production design WSO2 APIM Pattern 3 + MI.md  # Infrastructure design spec
├── README.md                                                 # This file
├── apim-deployment/
│   ├── apim/                                                 # Keystores & DB schema scripts
│   │   ├── apim-secrets/                                     # Source keystores for JKS secrets
│   │   └── db-scripts/                                       # PostgreSQL database scripts
│   └── helm-apim-4.5/
│       └── distributed/                                      # Active Pattern 3 Helm Charts
│           ├── control-plane/                                # Control Plane Chart
│           │   ├── confs/                                    # deployment.toml & entrypoints
│           │   ├── templates/                                # Deployments, HTTPRoutes, PDB, NFS PVC
│           │   └── values.yaml                               # CP Values
│           ├── gateway/                                      # Gateway Chart
│           │   ├── confs/                                    # deployment.toml & entrypoints
│           │   ├── templates/                                # Deployments, HTTPRoutes, PDB
│           │   └── values.yaml                               # GW Values
│           └── traffic-manager/                              # Traffic Manager Chart
│               ├── confs/                                    # deployment.toml per instance
│               ├── templates/                                # Instance 1 & 2 Deployments, PDB
│               └── values.yaml                               # TM Values
└── mi-deployment/
    ├── README.md                                             # Detailed WSO2 MI HA architecture & guide
    └── helm-mi/
        ├── deploy-mi.sh                                      # Automated MI bootstrap & deploy script
        ├── mi-gateway-resources.yaml                         # Gateway & Nimble NFS PVCs
        └── mi/                                               # WSO2 MI 4.4.0 Helm Chart
            ├── values.yaml                                   # Production values
            ├── confs/deployment.toml                         # MI configuration
            └── templates/                                    # Deployment, Service, HTTPRoute, PDB
```

---

## 5. Security & Production Hardening Applied

1. **Non-Root Execution (UID/GID 10001)**:
   - Configured `securityContext` (`runAsUser: 10001`, `runAsGroup: 10001`, `fsGroup: 10001`) aligning strictly with the WSO2 Carbon user ownership in `/home/wso2carbon`.
   - Enabled `seccompProfile: { type: RuntimeDefault }` across all pods.
2. **High Availability & Fault Tolerance**:
   - `PodDisruptionBudget` configured with `minAvailable: 1` across all components (CP, GW, TM).
   - `topologySpreadConstraints` configured for `kubernetes.io/hostname` to guarantee 1 pod per worker node.
3. **Optimized Health Probes**:
   - Control Plane & Gateway: Startup probe with TCP socket check and HTTP GET `/services/Version`.
   - Traffic Manager: HTTP GET probe on port `9763` (`/services/Version`) with a failure threshold of 60 (10 minutes) allowing safe OSGi and webapp cold starts.
4. **TLS Termination & Internal CA Integration**:
   - Secret `my-tls-secret` loaded with the full certificate chain for `*.sybyl.int` issued by the Sybyl Internal Intermediate & Root CA.
   - Client PCs with `sybyl_int_root_ca.crt` installed trust all portals and API gateways natively without browser warnings.

---

## 6. Deployment Guide

### Step 1: Create Namespace and Secrets

```bash
# Create namespace
kubectl create namespace wso2-apim

# Create Wildcard TLS Secret for Envoy Gateway
kubectl create secret tls my-tls-secret \
  --cert=/home/ubuntu/intlabcrt/sybyl-int-wildcard-1yr.crt \
  --key=/home/ubuntu/intlabcrt/sybyl-int-wildcard-1yr.key \
  -n wso2-apim

# Create Java Keystore Secret for APIM
kubectl create secret generic apim-keystore-secret \
  --from-file=wso2carbon.jks=apim-deployment/apim/keystores/wso2carbon.jks \
  --from-file=client-truststore.jks=apim-deployment/apim/keystores/client-truststore.jks \
  -n wso2-apim
```

### Step 2: Deploy Envoy Gateway & Gateway Resource

```bash
kubectl apply -f apim-deployment/helm-apim-4.5/docs/assets/sample-gateway.yaml
```

### Step 3: Deploy Pattern 3 Distributed Charts via Helm

```bash
# 1. Deploy Control Plane (CP)
helm upgrade --install wso2am-cp \
  ./apim-deployment/helm-apim-4.5/distributed/control-plane \
  -n wso2-apim

# 2. Deploy Universal Gateway (GW)
helm upgrade --install wso2am-gw \
  ./apim-deployment/helm-apim-4.5/distributed/gateway \
  -n wso2-apim

# 3. Deploy Traffic Manager (TM)
helm upgrade --install wso2am-tm \
  ./apim-deployment/helm-apim-4.5/distributed/traffic-manager \
  -n wso2-apim
```

### Step 4: Verify APIM Deployment

```bash
# Verify all 6 pods are Running (1/1 Ready)
kubectl get pods -n wso2-apim -o wide

# Verify HTTPRoutes attached to Envoy Gateway
kubectl get httproutes -n wso2-apim
```

### Step 5: Deploy WSO2 Micro Integrator (MI)

Micro Integrator is deployed in its own namespace (`wso2-mi`) using dynamic Nimble NFS storage:

```bash
cd mi-deployment/helm-mi
./deploy-mi.sh

# Verify MI pods (2/2 Running across wkr1 and wkr2)
kubectl get pods -n wso2-mi -o wide
```

See [mi-deployment/README.md](mi-deployment/README.md) for full MI architecture and CarbonApp deployment instructions.

---

## 7. Client Access & Testing

Add the MetalLB LoadBalancer VIPs to your workstation `/etc/hosts` or local DNS:

```text
# WSO2 API Manager 4.7.0 (VIP: 172.18.10.245)
172.18.10.245   am.sybyl.int publisher.sybyl.int devportal.sybyl.int admin.sybyl.int gw.sybyl.int websocket.sybyl.int websub.sybyl.int

# WSO2 Micro Integrator 4.4.0 (VIP: 172.18.10.246)
172.18.10.246   mi.sybyl.int
```

Open in any browser with the Sybyl Root CA installed:
- **Publisher Portal**: `https://publisher.sybyl.int/publisher`
- **Developer Portal**: `https://devportal.sybyl.int/devportal`
- **Admin Portal**: `https://admin.sybyl.int/admin`
- **API Runtime Gateway**: `https://gw.sybyl.int`
- **Micro Integrator Services**: `https://mi.sybyl.int/services/`
- **Micro Integrator Management**: `https://mi.sybyl.int/management`
- Default Credentials: `admin` / `admin` (update upon first login)