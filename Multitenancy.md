Ran command: `find apim-deployment/helm-apim-4.5/distributed/control-plane -name "*.toml"`
Viewed deployment.toml:1-45
Searched for "devportal"
Searched for "[apim.publisher]"
Viewed deployment.toml:185-215
Viewed values.yaml:210-250

### Is this expected behavior, or a fault?

**It is 100% expected behavior and NOT a fault.**

Your intuition was spot on. Here is exactly what is happening under the hood in WSO2 API Manager 4.7.0:

---

### 1. Why Publisher and Admin redirect to `am.sybyl.int`

In WSO2 API Manager, the Publisher (`/publisher`) and Admin Console (`/admin`) are protected web applications that enforce **OIDC / OAuth2 Single Sign-On (SSO)** immediately upon access:

1. When you navigate to `https://publisher.sybyl.int/publisher/`, Envoy Gateway forwards the request to the Control Plane pod.
2. The WSO2 Control Plane checks for an active authenticated session cookie. Since none exists, it initiates an **OAuth2 Authorization Code flow**.
3. In WSO2, the identity provider (IDP) endpoints (`/oauth2/authorize`, `/authenticationendpoint/login.do`, `/commonauth`) and the registered OAuth application's callback URLs are derived from the core server configuration in `deployment.toml`:
   ```toml
   [server]
   hostname = "am.sybyl.int"
   ```
4. Because `[server] hostname` is configured as **`am.sybyl.int`**, the OAuth2 client redirects your browser to:
   ```text
   https://am.sybyl.int/oauth2/authorize?response_type=code&client_id=...&redirect_uri=https://am.sybyl.int/publisher/auth/callback/login
   ```
5. Once authenticated (or when rendering the login page/dashboard), the session lands and stays on the canonical server hostname: **`https://am.sybyl.int/publisher/`** (and **`https://am.sybyl.int/admin/dashboard`**).

---

### 2. Why DevPortal stays on `devportal.sybyl.int`

Unlike Publisher and Admin, the Developer Portal (`/devportal`) enables **Anonymous Mode** by default (`enable_anonymous_mode = true`):
- Anyone can browse APIs publicly without logging in.
- Because no OAuth2 login redirect is forced when you first hit the URL, your browser stays on **`https://devportal.sybyl.int/devportal/`**.
- *(If you click "Sign In" in the top-right of DevPortal, it will then trigger the OIDC flow via `am.sybyl.int`).*

---

### 3. How Multi-Tenancy Works in this Setup

In WSO2 APIM Pattern 3, multi-tenancy operates across three distinct layers:

#### A. Data & User Isolation (PostgreSQL + Carbon Realm)
- The cluster uses the shared database `shared_dist_db` for multi-tenant userstores and registry mounting.
- **Super Tenant**: Has tenant ID `-1234` and domain `carbon.super`. Users log in with plain usernames (e.g., `admin`).
- **Custom Tenants (e.g. `tenant1.com`, `tenant2.sybyl.int`)**:
  - Created via the Admin Console (`https://am.sybyl.int/admin/` → *Tenants* → *Register New Tenant*).
  - Users belonging to a tenant log in with their fully-qualified name: `user@tenant1.com`.
  - Roles, permissions, and keystores are strictly isolated per tenant in the DB.

#### B. Portal Multi-Tenancy (Publisher & DevPortal)
- **Publisher**: When `publisher_user@tenant1.com` logs in, they only see and manage APIs belonging to `tenant1.com`.
- **Developer Portal**:
  - Each tenant gets their own branded API store accessible via a query parameter:
    ```text
    https://devportal.sybyl.int/devportal?tenant=tenant1.com
    ```
  - APIs marked as "Visible to Tenant Only" will only appear to users accessing that tenant’s store.
  - **Cross-tenant subscriptions**: Configurable in `values.yaml` (`enableCrossTenantSubscriptions: true`) if you want apps in one tenant to consume APIs from another.

#### C. Gateway Multi-Tenancy (API Runtime)
The Universal Gateway (`gw.sybyl.int`) routes calls based on the API context prefix:
- **Super Tenant APIs**:
  ```text
  https://gw.sybyl.int/<api-context>/<version>/<resource>
  ```
- **Tenant APIs**: Automatically prefixed with `/t/<tenant-domain>`:
  ```text
  https://gw.sybyl.int/t/tenant1.com/<api-context>/<version>/<resource>
  ```
  The Gateway isolates rate limits, subscription tokens, and analytics per tenant.

---

### Summary
The redirect from `publisher.sybyl.int` and `admin.sybyl.int` to `am.sybyl.int` is purely the standard OAuth2 canonical URL behavior dictated by `[server] hostname = "am.sybyl.int"`. 

Everything is working normally and as designed.