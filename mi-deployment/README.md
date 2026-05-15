# WSO2 Micro Integrator on Red Hat OpenShift Service on AWS (ROSA)

Deployment guide for running WSO2 MI 4.x.x on ROSA using a custom Docker image and Helm, with EFS-backed CarbonApp volume mounts for production API deployments.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Deployment Strategy: Baked Image vs Volume Mount](#deployment-strategy-baked-image-vs-volume-mount)
- [Step 1 — Provision EFS Storage & PVC](#step-2--provision-efs-storage--pvc)
- [Step 2 — Create the Keystores Secret](#step-3--create-the-keystores-secret)
- [Step 3 — Configure values.yaml](#step-4--configure-valuesyaml)
- [Step 4 — Deploy with Helm](#step-5--deploy-with-helm)
- [Step 5 — Verify the Deployment](#step-6--verify-the-deployment)
- [Troubleshooting](#troubleshooting)
- [Dev Setup: CarbonApp baked in Image](#dev-setup-carbonapp-baked-in-image)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                  ROSA Cluster                            │
│                                                          │
│  ┌──────────────┐     ┌──────────────────────────────┐   │
│  │  nginx       │────▶│  WSO2 MI Pod                 │   │
│  │  Ingress     │     │                              │   │
│  └──────────────┘     │  ┌─────────┐  ┌──────────┐   │   │
│                       │  │ Custom  │  │ EFS PVC  │   │   │
│                       │  │ Image   │  │ carbonapps│  │   │
│                       │  │ (baked  │  │ (prod)   │   │   │
│                       │  │ .car)   │  └──────────┘   │   │
│                       │  └─────────┘                 │   │
│                       └──────────────────────────────┘   │
│                                 │                        │
│                       ┌─────────▼────────┐               │
│                       │  mi-keystores    │               │
│                       │  Secret (JKS)    │               │
│                       └──────────────────┘               │
└──────────────────────────────────────────────────────────┘
                              │
                    ┌─────────▼────────┐
                    │   AWS EFS        │
                    │  fs-xxxxxxxx     │
                    └──────────────────┘
```

---

## Project Structure

```
mi-deployment/
├── agency-intg/                  # Integration project source
│   ├── carbonapps/               # Compiled .car files (baked into image)
│   ├── conf/                     # deployment.toml, log4j2, file.properties
│   ├── libs/                     # Custom JARs
│   └── Dockerfile                # Custom MI image definition
│
└── helm-mi/
    └── mi/                       # Helm chart for WSO2 MI
       ├── carbonapps/           # HelloWorld_1.0.0.car (dev/test)
       ├── confs/                # deployment.toml, log4j2.properties
       ├── security/             # wso2carbon.jks, client-truststore.jks
       ├── templates/            # Kubernetes manifest templates
       ├── mi-pvcs.yaml          # Manual PVC definition
       ├── mi-init-pod.yaml      # Init pod for EFS seeding
       └── values.yaml           # Main configuration file


```

---

## Prerequisites

- ROSA cluster provisioned and `oc` CLI authenticated
- `helm` v3.x installed
- `docker` or `podman` for image builds
- AWS EFS filesystem created in the same VPC as the ROSA cluster
- EFS CSI driver addon enabled on the cluster (`efs-sc` StorageClass present)
- Docker Hub or private registry credentials

Verify your StorageClasses include `efs-sc`:

```bash
oc get storageclass
# Expected: efs-sc with provisioner efs.csi.aws.com
```

---

## Deployment Strategy: Baked Image vs Volume Mount

This repo supports two deployment patterns:

| | Dev / CI | Production |
|---|---|---|
| **CarbonApps** | Baked into Docker image | Mounted from EFS PVC |
| **Image rebuild needed?** | Yes, on every API change | No — copy `.car` to EFS |
| **Rollout speed** | Slower (image pull) | Faster (no repull) |
| **`mountCapps` in values.yaml** | `true` (uses PVC) or `false` | `true` |

For this deployment, the `.car` file is stored in AWS EFS and mounted onto the container. See - [Dev Setup: CarbonApp baked in Image](#dev-setup-carbonapp-baked-in-image) if you are not using volume mounts.

---

## Step 1 — Provision EFS Storage & PVC

The EFS filesystem and access point must exist before deploying. The PVC is created manually (not via Helm) to avoid lifecycle coupling to the Helm release.

### 1a. Verify the EFS StorageClass

```bash
oc get storageclass efs-sc
```

### 1b. Create the PVC manually

Edit `helm-mi/mi/mi-pvcs.yaml` with your EFS filesystem ID and access point, then apply:

```bash
oc apply -f helm-mi/mi/mi-pvcs.yaml -n <your-namespace>

# Confirm it is Bound before proceeding
oc get pvc mi-carbonapps-pvc -n <your-namespace>
```

### 1c. Seed the EFS volume with CarbonApps (first time)

Use the init pod to copy `.car` files onto the EFS mount:

```bash
oc apply -f helm-mi/mi/mi-init-pod.yaml -n <your-namespace>

# Copy your .car file into the pod
oc cp helm-mi/mi/carbonapps/HelloWorld_1.0.0.car \
  <init-pod-name>:/data/ -n <your-namespace>

# Clean up
oc delete -f helm-mi/mi/mi-init-pod.yaml -n <your-namespace>
```

### EFS Networking Checklist

If you encounter mount errors, verify:

- EFS has a **mount target in the same AZ** as your worker nodes
- The EFS mount target security group allows **inbound TCP port 2049** from the node security group
- Node IAM role has the following EFS permissions:

```json
{
  "Effect": "Allow",
  "Action": [
    "elasticfilesystem:ClientMount",
    "elasticfilesystem:ClientWrite",
    "elasticfilesystem:DescribeMountTargets"
  ],
  "Resource": "*"
}
```

---

## Step 2 — Create the Keystores Secret

The Helm chart mounts `wso2carbon.jks` and `client-truststore.jks` into the pod via a Kubernetes Secret. The secret key names must match exactly.

```bash
oc create secret generic mi-keystores \
  -n <your-namespace> \
  --from-file=wso2carbon.jks=helm-mi/mi/security/wso2carbon.jks \
  --from-file=client-truststore.jks=helm-mi/mi/security/client-truststore.jks
```

Verify the key names are correct:

```bash
oc describe secret mi-keystores -n <your-namespace>
```

Expected output:

```
Data
====
client-truststore.jks:  <size> bytes
wso2carbon.jks:         <size> bytes
```

> **Important:** A common pitfall is creating the secret with a key named `keystore.jks` instead of `wso2carbon.jks`. The Helm chart uses `subPath` mounts and the key name must match the target filename exactly, otherwise the container will fail with `not a directory` on startup.

---

## Step 3 — Configure values.yaml

Key fields to set in `helm-mi/mi/values.yaml`:

```yaml
provider: "aws"

aws:
  storage:
    storageClass: "efs-sc"
    # Leave fileSystemId and cAppAccessPoint empty if PVC was created manually
    fileSystemId: ""
    cAppAccessPoint: ""

wso2:
  deployment:
    hostname: "mi.apps.<your-cluster-domain>"
    JKSSecretName: "mi-keystores"   # Must match the secret name created in Step 3
    mountCapps: true
    cappsPvcName: "mi-carbonapps-pvc"  # Must match the PVC name created in Step 2

    image:
      repository: "<your-registry>/wso2mi-openshift"
      digest: "sha256:<digest>"
      tag: "<tag>"
```

---

## Step 5 — Deploy with Helm

```bash
cd helm-mi/mi/

# Dry run first to catch template errors
helm template mi . -f values.yaml | oc apply --dry-run=client -f -

# Deploy
helm upgrade --install mi . \
  -f values.yaml \
  -n <your-namespace> \
  --create-namespace
```

---

## Step 6 — Verify the Deployment

```bash
# Check pod is Running
oc get pods -n <your-namespace>

# Check pod events if not Running
oc describe pod -n <your-namespace> <pod-name>

# Tail logs
oc logs deployment/cloud-wso2-mi-demo -n <your-namespace> --tail=100 -f

# Check ingress
oc get ingress -n <your-namespace>

# Test the Hello World API (use curl.exe on Windows PowerShell)
curl.exe -k https://mi.apps.<your-cluster-domain>/hello-world
```

---

## Troubleshooting

### PVC not found on scheduling

The scheduler emits `persistentvolumeclaim "mi-carbonapps-pvc" not found` if the PVC does not exist before the Helm release is deployed. Always apply `mi-pvcs.yaml` and confirm `Bound` status before running `helm upgrade --install`.

```bash
oc get pvc mi-carbonapps-pvc -n <your-namespace>
# STATUS must be: Bound
```

### EFS mount fails: `unrecognized init system "aws-efs-csi-dri"`

This indicates an outdated EFS CSI driver. Upgrade it via the ROSA addon or Helm:

```bash
oc get daemonset efs-csi-node -n kube-system \
  -o jsonpath='{.spec.template.spec.containers[0].image}'

helm upgrade aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
  --namespace kube-system
```

### Container fails with `not a directory`

The `mi-keystores` secret was created with incorrect key names. Delete and recreate it ensuring the keys are named `wso2carbon.jks` and `client-truststore.jks`:

```bash
oc delete secret mi-keystores -n <your-namespace>

oc create secret generic mi-keystores \
  -n <your-namespace> \
  --from-file=wso2carbon.jks=./security/wso2carbon.jks \
  --from-file=client-truststore.jks=./security/client-truststore.jks
```

### 503 from Ingress

The Ingress `ADDRESS` field being empty means the nginx ingress controller is not running or is in a different namespace. Check:

```bash
oc get pods -A | grep ingress
oc get svc -n <your-namespace>
```

---

## Dev Setup: CarbonApp baked in Image

In a test environment, you can bake the `.car` file into the Docker image. But this means every API deployment requires rebuilding and re-pulling the image.
For production, use EFS volume mounts so new CarbonApps can be deployed without touching the image.

## How it works

### Build & Push the Custom Docker Image

The `agency-intg/Dockerfile` bakes the CarbonApp and custom JARs directly into the WSO2 MI base image.

```bash
cd agency-intg/

# Build the image
docker build -t <your-registry>/wso2mi-openshift:<tag> .

# Push to registry
docker push <your-registry>/wso2mi-openshift:<tag>

# Get the digest for pinning in values.yaml (recommended over tags)
docker inspect --format='{{index .RepoDigests 0}}' <your-registry>/wso2mi-openshift:<tag>
```

Update `helm-mi/mi/values.yaml` with the digest:

```yaml
image:
  repository: "<your-registry>/wso2mi-openshift"
  digest: "sha256:<digest-here>"
  tag: "<tag>"
```
