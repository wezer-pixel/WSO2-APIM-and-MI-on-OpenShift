# Kubernetes lab design: WSO2 APIM Pattern 3 + MI

Oct 15, 2026 · @Jerry

An internal-lab, 3-master, 2-worker kubeadm cluster runs WSO2 APIM 4.7.0 (control plane, traffic manager and gateway distributions) and MI 4.6.0 for two demo tenants, with NFS-backed storage, MetalLB and Gateway API for exposure, and no workloads on the control plane except Kubernetes system services.

## At a glance

&#91;embedded content: cluster layout · 3 masters, 2 workers, NFS, database\]

Each worker runs one replica of every APIM and MI tier, so one worker can carry the platform after a failure; monitoring and other lab apps share the same workers.

## Versions and prerequisites

The newest releases are APIM 4.7.0 and MI 4.6.0; MI 4.7.0 is still a release candidate, so this design uses MI 4.6.0.

| Component | Version | Released | Java |
| --- | --- | --- | --- |
| [WSO2 API Manager](https://github.com/wso2/product-apim/releases) | 4.7.0 | 29 April 2026 | JDK 21 |
| [WSO2 Integrator: MI](https://github.com/wso2/product-integrator-mi/releases) | 4.6.0 | 15 May 2026 | JDK 21 or 25 |

APIM 4.7.0 ships separate API Control Plane, Traffic Manager and Universal Gateway distributions, which is what this design deploys. It also ships a new API Platform Gateway, which the baseline leaves out.

**4.7.0 changes to check against your Helm charts and the existing PostgreSQL before demo day:**

- UTF-8 is enabled by default, so confirm that `apim_db` and `shared_db` use UTF-8 encoding.
- The default encryption mechanism is now symmetric, which affects how you generate and mount keys and secrets.
- Token persistence is off by default and API keys are API-bound by default, so older demo scripts may behave differently.
- Control plane resource access is default-deny, so check that your Publisher, DevPortal and Admin REST calls still work.

## Cluster topology

The three masters run only Kubernetes system services; every APIM, MI, Gateway API and storage workload runs on the two workers.

| Role | Count | Purpose |
| --- | --- | --- |
| Control plane | 3 | kubeadm HA with stacked etcd, tainted `node-role.kubernetes.io/control-plane:NoSchedule` |
| Workers | 2 | APIM, MI, Gateway API proxy, MetalLB speaker, NFS CSI, monitoring and other lab apps |
| API server VIP | 1 | kube-vip or HAProxy + keepalived on port 6443, fronting the three masters; MetalLB cannot serve this because the cluster must exist first |
| Service VIPs | pool | MetalLB in L2 mode on the workers' network; the Gateway API proxy takes one address |
| NFS server | 1, external | Single server; storage replicated at infra level |
| Database | 1, external | Existing PostgreSQL outside the cluster |

**Keeping workloads off the control plane**

- Keep the default kubeadm taint on all three masters.
- Add control-plane tolerations only to Kubernetes system components: CNI, kube-proxy, CoreDNS, kube-vip, metrics-server.
- The Gateway API proxy, MetalLB, NFS CSI, cert-manager, monitoring and every lab app carry no tolerations, so they land on workers.
- Some MetalLB charts tolerate the control-plane taint on the speaker DaemonSet; remove that toleration.
- Keep kube-vip's Service load balancer disabled so MetalLB owns Service addresses.

**Baseline:** containerd, Calico or Cilium CNI, pod and service CIDRs that do not overlap the lab network, the Gateway API CRDs installed before the proxy, and kubeadm within the supported minor version range. Automate the build with Ansible or Terraform.

## Node sizing

These are starting points; validate them with load tests against your real API count and TPS.

| Node | vCPU | RAM | Disk |
| --- | --- | --- | --- |
| Master (x3) | 4 | 8 GB | 100 GB SSD, etcd on a dedicated low-latency disk |
| Worker (x2) | 16 | 64 GB | 200 GB SSD for OS and image layers; no local-path volumes for pods |

**Lab sizing rule.** Size requests so that APIM, MI and the platform components fit on one worker with room to spare; what is left on each worker is headroom for other namespaces. Give monitoring and other lab apps a lower PriorityClass than the WSO2 workloads so the scheduler evicts them first.

## Workloads and namespaces

This design reads Pattern 3 as the distributed APIM 4.x layout, which APIM 4.7.0 ships as three distributions: API Control Plane (Publisher, DevPortal, Admin, Key Manager), Traffic Manager and Universal Gateway. Confirm that your Helm charts map to this split. Namespaces below are a suggestion; keep one wso2-apim namespace if your charts deploy that way, and separate the tiers with labels and NetworkPolicies.

| Namespace | Workload | Replicas | Starting requests / limits |
| --- | --- | --- | --- |
| `wso2-apim` | API Control Plane | 2 | 1.5 vCPU / 3 Gi request, 3 vCPU / 5 Gi limit |
| `wso2-apim` | Traffic Manager | 2 | 0.5 vCPU / 1.5 Gi request, 1 vCPU / 2 Gi limit |
| `wso2-apim` | Universal Gateway | 2 | 1 vCPU / 2 Gi request, 3 vCPU / 3 Gi limit |
| `wso2-mi` | Micro Integrator | 2 | 0.5 vCPU / 1 Gi request, 2 vCPU / 2 Gi limit |
| `gateway-system` | Gateway API proxy | 2, one per worker | Per controller guidance |
| `metallb-system` | MetalLB controller and speakers | 1 controller, 1 speaker per worker | Small |
| `nfs-csi` | csi-driver-nfs | 1 to 2 controller pods, node plugin on workers | Small |
| `monitoring` | Prometheus, Grafana, Alertmanager | 1 each | Prometheus about 1 vCPU / 3 Gi request |
| Other namespaces | Lab apps | As needed | Governed by ResourceQuota and LimitRange |
| `kube-system` | CNI, CoreDNS, kube-proxy, kube-vip, metrics-server | Default | Control-plane tolerations only for these |

The APIM and MI requests add up to about 7 vCPU and 15 Gi, so one worker can carry them after a failure and still leave room for the platform components. Set the JVM heap to roughly 50 to 60 percent of each container's memory limit. These are starting estimates; load-test them.

**Exposure**

- North-south traffic enters through the shared Gateway API proxy on a MetalLB address; the networking section below lists the hostnames and routes.
- MI is ClusterIP only, reached through the gateway or internal services, with no route of its own.
- TLS everywhere, issued by cert-manager from an internal CA; trust that CA on the machines you demo from.

## Networking: MetalLB and Gateway API

MetalLB gives the Gateway API proxy a stable address, and one shared Gateway routes hostnames to APIM and to the other lab apps. The Gateway API handles traffic into the cluster only; APIM remains the API management layer.

**MetalLB**

- Run it in L2 mode with a small address pool on the workers' subnet: one address for the shared Gateway and a few spares for other lab services.
- Run the speakers on workers only. In L2 mode one worker answers for each address at a time, so a worker failure moves the address after a short delay that you will see in a failover demo.
- Keep `externalTrafficPolicy: Cluster` on the Gateway Service unless you need the client source address; with `Local` the announcing node must hold a proxy pod.
- Create a wildcard DNS record such as `*.<lab-domain>` that points at the Gateway address.

**Gateway API**

- Install the standard Gateway API CRDs, then one controller of your choice. This design does not depend on which one you pick; choose one that supports TLS to the backend (see below).
- Create one shared Gateway in `gateway-system` with HTTPS listeners and a cert-manager wildcard certificate. Use `allowedRoutes` so APIM and other namespaces attach their own HTTPRoutes without touching the Gateway.

| Hostname | Route lives in | Backend (default ports; confirm in your charts) |
| --- | --- | --- |
| `publisher.<lab-domain>`, `devportal.<lab-domain>`, `admin.<lab-domain>` | `wso2-apim` | API Control Plane service, HTTPS on 9443 |
| `gw.<lab-domain>` | `wso2-apim` | Universal Gateway service, HTTPS on 8243 |
| One hostname per tenant, if you use custom URLs | `wso2-apim` | Same services as above |
| Hostnames for other lab apps | Each app's namespace | Each app's own Service |

**TLS to APIM:** APIM serves HTTPS on these ports. Terminate at the Gateway and re-encrypt to the backend with a BackendTLSPolicy if your controller supports it; otherwise use TLS passthrough with SNI-based routing. Test this early, because backend TLS support differs between controllers and versions.

## Storage design (NFS)

All pod persistent storage comes from one NFS-backed StorageClass, and local-path is never deployed.

**StorageClass `nfs-csi`** (csi-driver-nfs, or nfs-subdir-external-provisioner):

- `reclaimPolicy: Retain`, `volumeBindingMode: Immediate`, `allowVolumeExpansion` per your NFS server's capabilities.
- Mount options: `nfsvers=4.1, hard, noatime, nconnect=4`.
- Export options: `rw,sync,no_subtree_check`. Either use `no_root_squash`, or pre-own the export directories to the WSO2 container UID/GID (usually 802 in official images; verify for your image). NFS largely ignores `fsGroup`.
- Mark `nfs-csi` as the default class so nothing silently falls back to a node-local volume.

**What needs a PVC**

| Component | Needs shared storage? | Detail |
| --- | --- | --- |
| Gateway | No | Pulls artifacts from the control plane; logs go to stdout |
| Control plane | Yes, ReadWriteMany | Shared `repository/tenants` for multitenancy and `repository/deployment/server/userstores` for secondary userstores |
| MI | Only if needed | A shared volume for file/VFS inbound endpoints, file connectors or drop folders; carbon apps are baked into the image |
| Prometheus and Grafana | Prometheus only | Prometheus gets a ReadWriteOnce volume with short retention; Grafana provisions dashboards from ConfigMaps and needs no volume |

**Do not put on NFS:** databases, etcd, Elasticsearch, RabbitMQ. They are sensitive to NFS latency and locking, and some are unsupported on it. Prometheus is the one exception you accepted for this lab: keep retention to a few days and expect to rebuild it if the volume is damaged.

**NFS server:** one server is enough for the lab, with storage replicated at the infrastructure level. Keep the exports on a dedicated disk or dataset, and note that an NFS outage stops the shared control plane volume and every NFS-backed pod until it returns.

## Multitenancy

APIM multitenancy isolates tenants logically inside shared JVMs and shared databases, so the cluster design must add the shared storage, routing and noisy-neighbor controls that tenancy needs. Confirm the exact configuration keys against the documentation for APIM 4.7.0. With only two tenants, the load effects below are small, but the routing and isolation choices still matter for the demo.

| Layer | How tenancy behaves | Design decision |
| --- | --- | --- |
| Control plane | Tenant configuration, registry content and secondary userstores are kept per tenant, with file-based parts under `repository/tenants` | Mount a ReadWriteMany NFS volume shared by both control plane replicas |
| Gateway | Tenant APIs are pushed from the control plane; a tenant's context is typically loaded on first use | Expect a slower first request per tenant after a restart; test it, and warm tenants up in the readiness or smoke-test step if it matters |
| Routing and DNS | Tenant traffic arrives on tenant-qualified paths (`/t/<tenant-domain>/`) or on per-tenant custom domains | Use path routing on the shared hostname by default; if each tenant gets its own domain, add one HTTPRoute hostname per tenant on the shared Gateway and cover it with the wildcard certificate |
| Key Manager | Tenants can register their own key managers | Allow egress from the control plane namespace to tenant IdPs, and keep that egress list explicit |
| MI | MI has no tenant model of its own, as far as I know | Share one MI deployment if tenants only call common backends; deploy MI per tenant group, each in its own namespace, if integrations must be isolated |
| Databases | Tenant data lives in the shared `apim_db` and `shared_db` | Back up per schema in the existing PostgreSQL and monitor connection pool use |

**Isolation limits to state to stakeholders**

- Tenants share gateway CPU and memory, so one tenant's traffic spike can affect others. Control this with per-tenant throttling policies and subscription tiers, because Kubernetes resource quotas cannot split a single pod between tenants.
- A tenant that needs hard isolation, such as separate capacity or a separate failure domain, should get its own gateway deployment (a gateway environment) or its own cluster.
- With two tenants, memory per loaded tenant is a minor cost; still load-test with both tenants active.

## HA and scheduling rules

With two workers, scheduling rules decide whether a node failure or a rolling update keeps the platform serving.

- Apply `topologySpreadConstraints` on `kubernetes.io/hostname` to every tier, and pin all workloads to workers with `nodeSelector` or node affinity.
- Set a PodDisruptionBudget with `minAvailable: 1` per tier.
- Use readiness probes on the management and health endpoints, with generous `startupProbe` values because WSO2 products boot slowly.
- Add a `preStop` hook and `terminationGracePeriodSeconds` of at least 60 seconds so in-flight requests drain.
- **Rolling-update trap:** hard (`required`) pod anti-affinity at 2 replicas plus the default `maxSurge: 25%` leaves the surge pod unschedulable and stalls the rollout. Use `maxSurge: 0, maxUnavailable: 1`, or use topology spread with `whenUnsatisfiable: ScheduleAnyway`.
- **Autoscaling:** an HPA on the gateway adds little on 2 workers, because pods beyond two share nodes. Treat capacity as a tested fixed figure and add workers before scaling out.
- **Control plane failure:** the API server VIP and three-member etcd tolerate the loss of one master; losing two masters stops cluster changes but running pods keep serving.

**Sharing the cluster with other apps**

- Define PriorityClasses: WSO2 workloads highest, monitoring next, other lab apps lowest.
- Put a ResourceQuota and LimitRange in every other namespace, including a storage quota for `nfs-csi`, so they cannot starve APIM or fill the export.
- Apply default-deny NetworkPolicies to those namespaces as well, and let them reach the outside only through their own HTTPRoutes on the shared Gateway.

## Security

- **NetworkPolicies:** default-deny in every namespace, then allow traffic from the Gateway API proxy to the control plane and gateway, gateway to MI, gateway and control plane to each other (event hub, key manager), and egress to the database and NFS addresses only.
- **Pod security:** Pod Security Admission at `restricted`, or `baseline` if the WSO2 images require it, with a non-root UID.
- **Secrets:** Kubernetes Secrets with etcd encryption at rest enabled, preferably fed by External Secrets or Vault. Mount keystores from secrets rather than baking them into images.
- **TLS:** cert-manager with an internal CA for the Gateway listeners and inter-service certificates, and a wildcard certificate for the lab domain.
- **Cluster hardening:** least-privilege RBAC, API server audit logging, kubelet certificate rotation, and a private registry for the custom WSO2 images.
- **Network exposure:** restrict the NFS and database ranges so only the workers can reach them.

## Backup, observability and operations

| Area | Approach |
| --- | --- |
| etcd | Scheduled `etcdctl snapshot save` copied off-cluster, with a restore procedure that has been tested |
| NFS and databases | Storage is replicated at infrastructure level; back up the PostgreSQL databases with your existing routine; add Velero if you want cluster object backup |
| Metrics and logs | Prometheus and Grafana run in the cluster with short retention; MI 4.6.0 supports Prometheus metrics and OpenTelemetry traces and logs; add a log shipper reading stdout if you want searchable logs |
| Upgrades | kubeadm one minor version at a time, control plane first, then drain workers one at a time; expect reduced capacity during each drain |
| Provisioning | Ansible or Terraform for node build and cluster bootstrap, so a rebuilt node matches the others |

## Demo showcase

The cluster is set up so you can show more than a working install.

- **Two tenants side by side.** Create two tenant domains, give each its own admin, APIs and DevPortal, and reach them on separate hostnames through the shared Gateway.
- **Failure on stage.** Delete a gateway pod, then drain a worker, while a load tool runs; show traffic continuing and the MetalLB address moving, with Grafana on screen.
- **AI and MCP gateway features.** APIM 4.7.0 adds [MCP governance, MCP-aware analytics, a semantic tool filtering guardrail and multi-model routing](https://github.com/wso2/product-apim/releases/tag/v4.7.0).
- **MI with agents and tracing.** MI 4.6.0 adds [MCP tool support for agents in the AI connector and OpenTelemetry traces and logs](https://github.com/wso2/product-integrator-mi/releases/tag/v4.6.0); send traces to Jaeger or Tempo if you want to show a request trace.
- **Clean first impression.** Real hostnames, and certificates from an internal CA that your demo laptop trusts, so no browser warnings appear.
- **Repeatable reset.** Keep Helm values in git and take a PostgreSQL dump of the seeded demo state, so you can rebuild the environment before each client session.

## Risks and open items

This is a lab for demos, so these are accepted trade-offs and checks rather than blockers.

1. **Two workers means a node failure is degraded service.** That is acceptable for a lab, and the failure demo is a feature; rehearse it so the MetalLB address move and pod rescheduling are predictable.
2. **A single NFS server**, with storage replicated at infrastructure level, is accepted. An outage stops the shared control plane volume and every NFS-backed pod until it returns.
3. **Prometheus on NFS** is accepted with short retention. This design reads "local" as "inside the cluster"; node-local disk would conflict with the no local-path rule.
4. **MetalLB L2 mode** announces each address from one worker at a time, so a worker failure shows as a short interruption on that address.
5. **The Gateway API controller and backend TLS** are not chosen yet. Support for re-encrypting to HTTPS backends differs between controllers, so test it before the demo.
6. **Chart and version fit:** confirm that your Helm charts target APIM 4.7.0 and MI 4.6.0 and handle the 4.7.0 default changes listed under versions.

**Still to decide:** the Gateway API controller, the MetalLB address range and lab domain name, and which APIM and MI features go into the demo script.
