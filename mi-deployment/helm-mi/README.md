# Helm Chart for WSO2 Micro Integrator (MI) 4.4.0

This directory contains the Helm chart and bootstrap automation for deploying **WSO2 Micro Integrator 4.4.0** in the `wso2-mi` namespace.

For the comprehensive architecture, storage configuration, endpoints, and deployment instructions, refer to the primary guide:
👉 **[mi-deployment/README.md](../README.md)**

## Quick Start

```bash
# Deploy or Upgrade
./deploy-mi.sh

# Uninstall
./deploy-mi.sh --uninstall
```

## Chart Layout

- `deploy-mi.sh`: Automated bootstrap and Helm deploy script.
- `mi-gateway-resources.yaml`: Envoy Gateway resource (`wso2-mi-gateway`) and NFS PersistentVolumeClaims (`mi-carbonapps-pvc`, `mi-libs-pvc`).
- `mi/`: Helm chart templates, configurations (`confs/deployment.toml`), and production values (`values.yaml`).
- `mi/carbonapps/`: Sample `HelloWorld_1.0.0.car` for testing deployments.
