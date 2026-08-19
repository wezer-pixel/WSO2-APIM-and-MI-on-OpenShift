# WSO2 APIM and MI on Vanilla Kubernetes

This branch contains the Helm charts, Docker customizations, and supporting assets for deploying WSO2 API Manager 4.7.0 and WSO2 Micro Integrator 4.4.0 on a standard, Vanilla Kubernetes cluster.

---

## Repository Structure

```text
WSO2-APIM-and-MI-on-Vanilla-K8s/
├── apim-deployment/               # API Manager deployment
│   ├── apim/                      # Docker customization and database setup
│   │   ├── Dockerfile             # Custom APIM image (MySQL driver integration)
│   │   ├── DB_SETUP.md            # Database setup guide
│   │   ├── mysql.yaml             # In-cluster MySQL manifest (dev/demo)
│   │   ├── db-scripts/            # Schema scripts for wso2amdb and wso2shareddb
│   │   ├── keystores/             # Source keystore files
│   │   └── lib/                   # MySQL JDBC driver
│   └── helm-apim/                 # Helm charts
│       ├── all-in-one/            # All-in-one deployment chart
│       ├── distributed/           # Distributed deployment charts
│       │   ├── control-plane/
│       │   ├── gateway/
│       │   ├── key-manager/
│       │   └── traffic-manager/
│       └── docs/                  # Deployment pattern reference configs
│
└── mi-deployment/                 # Micro Integrator deployment
    ├── agency-intg/               # Integration project source
    │   ├── Dockerfile             # Custom MI image (baked .car files)
    │   ├── carbonapps/            # Compiled .car files
    │   ├── conf/                  # deployment.toml, log4j2, file.properties
    │   └── libs/                  # Custom JARs
    └── helm-mi/
        └── mi/                    # Helm chart for WSO2 MI
            ├── carbonapps/        # .car files (dev/test)
            ├── confs/             # deployment.toml, log4j2.properties
            ├── security/          # Keystore files (not committed)
            ├── templates/         # Kubernetes manifest templates
            ├── mi-pvcs.yaml       # Manual PVC & PV definitions (NFS)
            └── values.yaml        # Main configuration (not committed)
```

---

## Architecture

Both products run as containerized workloads on Vanilla Kubernetes, exposed securely via the **NGINX Ingress Controller**. The APIM gateway proxies traffic to MI APIs registered through the APIM Publisher. Storage for CApps and configurations is handled via standard Kubernetes Persistent Volumes (e.g., NFS).

```text
Internet
   │
   ▼
NGINX Ingress Controller
   │                    │
   ▼                    ▼
WSO2 APIM          WSO2 MI Pod
(Publisher,        (CarbonApps
 DevPortal,         via NFS PVC)
 Gateway)               | 
   │                    │
   └────────────────────┘
     APIM Gateway proxies
     to MI backend service
          │
          ▼
     PostgreSQL (wso2amdb
     + wso2shareddb)
```

---

## Deployments

### API Manager

APIM runs in an all-in-one topology (Publisher, DevPortal, Gateway, and Key Manager in a single pod). It requires two pre-populated PostgreSQL databases and a Kubernetes secret containing the JKS keystores for HTTPS and Ingress TLS termination.

See **[`apim-deployment/apim/DB_SETUP.md`](apim-deployment/apim/DB_SETUP.md)** for database setup and **[`apim-deployment/helm-apim/README.md`](apim-deployment/helm-apim/README.md)** for the full deployment guide including:

- Building and pushing the custom Docker image
- Setting up PostgreSQL databases & permissions
- Creating the JKS Keystore & Password secrets
- Installing the Helm chart
- Exposing a backend MI API through the Publisher

### Micro Integrator

MI runs as a stateless pod with CarbonApps (`.car` files) either baked into the Docker image (dev) or mounted from an NFS Host volume (production). It integrates with APIM as a backend gateway environment and can connect to the Integration Control Plane (ICP).

See **[`mi-deployment/helm-mi/README.md`](mi-deployment/helm-mi/README.md)** for the full deployment guide including:

- NFS Host directory provisioning and PV/PVC setup
- Keystore and Truststore secret creation
- Helm chart configuration (values.yaml) and deployment
- CarbonApp hot-deployment strategies 

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Vanilla Kubernetes | `kubectl` CLI configured and authenticated |
| Helm 3.x | Run `helm version` to verify |
| Docker / containerd | For building custom images |
| PostgreSQL 18 | In-cluster pod or external database server |
| NGINX Ingress | `ingress-nginx` controller must be installed and running |
| NFS Server | Required for MI CarbonApp/Config volume mounts |
| Container registry | Docker Hub, local registry, or private |

---

## Quick Reference

| Task | Command |
|---|---|
| Deploy APIM | `helm upgrade --install apim apim-deployment/helm-apim/all-in-one/ -f values.yaml -n <ns>` |
| Deploy MI | `helm upgrade --install mi mi-deployment/helm-mi/mi/ -f values.yaml -n <ns>` |
| Watch pods | `kubectl get pods -n <ns> -w` |
| APIM Publisher | `https://<management-hostname>/publisher` |
| APIM DevPortal | `https://<management-hostname>/devportal` |
| MI health check | `curl -k https://<mi-hostname>/healthz` |

---

## Related Documentation

- [WSO2 API Manager Docs](https://apim.docs.wso2.com/en/latest/)
- [WSO2 Micro Integrator Docs](https://mi.docs.wso2.com/en/latest/)
- [Kubernetes NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Kubernetes Persistent Volumes (NFS)](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)
---
Yes, you cant reach this cluster. It's in my private network.