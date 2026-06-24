# CKAN Helm Chart

Helm charts to create CKAN instances and related services. This repository contains helm chart templates that are used across the projects to deploy the application.

## Values.yaml

`values.yaml` is the main configuration file for CKAN helm charts. Its values populate helm chart variables in templates accordingly. In `values.yaml` we are able to configure things like:

- Enabling needed services (Next Gen frontend, Giftless etc...)
- Passing Environment Variables to Container
- Defining which Images to use for Services
- Allocating Resources (CPU, Memory) for Services
- Enabling Auto Scaling
- And more

See full list of values and their reference in [Values File](/VALUES.md).

## Using Charts

Charts are installed with helm per project. Each New project uses its own set of configurations (`values.yaml`) depending on its needs. See [VALUES.md](VALUES.md) for values reference.

You will need `Charts.yaml` and `values.yaml`.

```bash
mkdir my-awesome-project && cd my-awesome-project
touch Charts.yaml values.yaml

```

Your `Charts.yaml` defines what dependencies your helm deployment has. This repository also represents a remote repository for helm charts. You can set it in your `Charts.yaml` including the version. Run `helm repo update` to get the desired version of charts.

Example of how `Charts.yaml` might look:

```yaml
apiVersion: v2
name: my-awesome-project
description: The best project I've deployed
type: application
version: 0.0.1
appVersion: 0.0.1
dependencies:
  - name: redis
    repository: [https://charts.bitnami.com/bitnami](https://charts.bitnami.com/bitnami)
    version: "10.7.4"
  - name: solr
    version: "1.5.2"
    repository: [http://storage.googleapis.com/kubernetes-charts-incubator](http://storage.googleapis.com/kubernetes-charts-incubator)
  - name: ckan
    version: "1.3.0"
    repository: "[https://raw.githubusercontent.com/datopian/dx-helm-ckan/master/charts/](https://raw.githubusercontent.com/datopian/dx-helm-ckan/master/charts/)"

```

### values.yaml

See [values.example.yaml](https://www.google.com/search?q=/ckan/values.example.yaml) to get an idea of how your `values.yaml` should look.

---

## 🏗️ CKAN Configuration & Initialization Architecture

The `ckan/templates/config/` directory contains Kubernetes ConfigMaps used to initialize and configure the CKAN application and its database dependencies.

### Database Initialization

The database initialization logic is handled during the CKAN Pod's startup via an `initContainer`.

* **`ckan-deployment.yaml` (Active):** This ConfigMap contains `initContainer.sh` and `get_details.py`. When the CKAN pod starts, the init container mounts these scripts, parses the database URLs (`CKAN_SQLALCHEMY_URL`, etc.), and dynamically connects to the PostgreSQL server to provision the required databases, roles, PostGIS extensions, and Datastore Read/Write permissions before the main CKAN app boots.
* **`ckan.yaml` (Legacy/Fallback):** Contains `ckan.sql`, a static SQL equivalent of the initialization script. It is preserved for backwards compatibility with older Datopian operators but is not actively mounted by the default deployment.

---

## 🔐 Configuration & Secrets Management

This deployment uses a **split-architecture pattern** to strictly separate non-sensitive configuration from sensitive credentials. We utilize standard **ConfigMaps** for plain-text variables and **Bitnami Sealed Secrets** for zero-knowledge GitOps encrypted secrets.

> **Master Toggle:** This feature is controlled by the `general.useSealedSecrets` toggle in your `values.yaml`. When set to `true`, the legacy plain-text secret templates are disabled, and all services (CKAN, Frontend, Datapusher, etc.) will look for encrypted Sealed Secrets.

### 1. `values.yaml` Structure

Environment variables for the CKAN application (and all enabled microservices) must be placed into one of two blocks under their respective keys (e.g., `ckan:`, `frontend:`, `datapusher:`) in your `values.yaml` file:

* **`config`**: For plain-text, non-sensitive variables (e.g., URLs, ports, boolean flags, resource limits). These are mounted as a ConfigMap.
* **`env`**: For highly sensitive credentials (e.g., Database URLs, SMTP passwords, API keys). **These must be encrypted using `kubeseal`.**

**Example:**

```yaml
ckan:
  # Plain-text variables (ConfigMap)
  config:
    CKAN_SITE_URL: "[https://data.myorganization.com](https://data.myorganization.com)"
    CKAN_PORT: "5000"

  # Encrypted variables (SealedSecret)
  env:
    CKAN_SQLALCHEMY_URL: "AgBxp41A+D9vK2...[encrypted-string]...vN125zYw=="

```

### 2. 🛡️ Built-in Security Guardrails

To prevent accidental credential leaks, this Helm chart contains strict template-level guardrails.

If you attempt to deploy the chart with plain-text database connection strings (matching `postgresql://` or `redis://`) placed inside any `config` block, **the Helm deployment will physically crash and reject the configuration.** All sensitive connection strings *must* be encrypted and placed in the `env` block.

### 3. Developer Workflow: How to Add or Update a Secret

Because our GitHub repository is public/shared, you cannot commit plain-text passwords. When you need to add a new secret or rotate an existing one, follow these steps:

#### Prerequisites

Ensure you have the `kubeseal` CLI installed and your terminal is authenticated to the target Kubernetes cluster (so the tool can fetch the public encryption key).

```bash
# macOS
brew install kubeseal

```

#### Step-by-Step

1. **Encrypt the plain-text value locally.** Run the following command in your terminal, replacing the dummy text with your actual secret.
> ⚠️ **CRITICAL:** You must use the `-n` flag with `echo` to prevent invisible newline characters from breaking the password, and you must include `--scope cluster-wide`.


```bash
echo -n "postgresql://ckan_user:SuperSecretPassword@postgres-host/ckan" | kubeseal --raw --scope cluster-wide

```


2. **Copy the ciphertext.** The command will output a long string starting with `Ag...`. Copy this entire string.
3. **Update `values.yaml`.** Paste the encrypted string into your `values.yaml` file under the appropriate service's `env` block.
4. **Commit and Push.** Commit the changes to your branch. The Sealed Secrets controller inside the cluster will automatically detect the new encrypted string, decrypt it using the master private key, and securely inject it into the pods.

---

## 🚀 Releasing new version

New releases are automated by GitHub Actions. New versions are pushed to the charts directory on a tagged commit.

To release a new package, commit your changes to the master branch and create a tagged release. Tags should follow semantic versioning starting with "v".

```bash
# Make changes, commit, and push to master (you probably need to skip this step if merging via PR)
git add <changed-files>
git commit -m 'My awesome changes'
git push origin master

# Create a tagged release
git tag v1.1.1
git push origin v1.1.1

```

