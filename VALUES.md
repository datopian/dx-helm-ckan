# CKAN Values File Reference

Below you can find the values and their definitions used in helm charts to boot CKAN instance and all the necessary services. There are several services running in the Namespace and each has some configurable options. Depending on instance needs, some of them might not have a full set of services.

All the values that need to be overridden from the ckan chart should come under `ckan: {}`. Please refer to the `values.example.yaml` file.

- [General](#general)
- [Nginx Ingress](#values-for-nginx-ingress)
- [CKAN](#values-for-ckan-service)
- [Frontend (CKAN next gen)](#values-for-frontend-service)
- [Datapusher](#values-for-datapusher-service)
- [Giftless](#values-for-giftless-service)
- [Auth](#values-for-auth-service)
- [Data Subscriptions](#values-for-data-subscriptions-service)
- [SOLR](#values-for-solr-service)

## General
- `ckan.general.useSealedSecrets` - Master toggle to use SealedSecrets and ConfigMaps over legacy plain-text secrets [default: `true`]
- `ckan.general.maintenance` - Enable it to put all the ingress in maintenance mode [default: `false`]
- `ckan.general.maintenanceImage` - registry URL to pull image from [default: `registry.gitlab.com/datopian/deploys/maintenance-page:latest`]
- `ckan.general.projectId`- The project ID <projectname-environment> Eg: datahub-staging
- `ckan.general.imagePullSecrets` - The name of `kubernetes.io/dockerconfigjson` secrets that contains credentials for private docker registry [default: `ckan-sealed-registry`]
- `ckan.general.dockerconfigjson` - Encrypted (`kubeseal`) base64 docker config string for registry authentication.
- `ckan.general.useProductionCerts` - Flag to use let's encrypt's production certificates or staging [default: `false`]
- `ckan.general.autoscaling` - Object containing auto Scaling related metadata
  - `ckan.general.autoscaling.enable` - Flag to enable autoscaling [default: `false`]
  - `ckan.general.autoscaling.maxReplicas` - Maximum number of replicas [default: `5`]
  - `ckan.general.autoscaling.minReplicas` - Minimum number of replicas [default: `1`]
  - `ckan.general.autoscaling.targetCPUUtilizationPercentage` - Target CPU Utilization in Percentage [default: `80`]
  - `ckan.general.autoscaling.targetMemoryUtilizationPercentage` - Target Memory Utilization in Percentage [default: `80`]
- `backupCronTab` - schedule expressions as a cron tab [default: `0 1 * * *`]

## Values For Nginx Ingress

- `ckan.ingress.enable` - Flag to enable Nginx Ingress
- `ckan.ingress.ingressClass` - The name of the ingress to use [default: `nginx-production`]
- `ckan.ingress.enableExternal` - Flag to enable Nginx Ingress for external domains
- `ckan.ingress.enableExternalCertificate` - Flag to enable Nginx Ingress for external domains having their own certificate
- `ckan.ingress.limitConnections` - Number of concurrent connection per IP [default: `20`]
- `ckan.ingress.limitRps` - Number of connections per second per IP [default: `25`]
- `ckan.ingress.proxyBodySize` - Value for `nginx.ingress.kubernetes.io/proxy-body-size` [default: `1000m`]
- `ckan.ingress.proxyReadTimeOut` - Value for `nginx.ingress.kubernetes.io/proxy-read-timeout` [default: `60`]
- `ckan.ingress.proxyConnectTimeout` - Value for `nginx.ingress.kubernetes.io/proxy-connect-timeout` [default: `60`]
- `ckan.ingress.extraAnnotations` - YAML mapped annotations for nginx ingress that are not considered by default
- `ckan.ingress.hosts` - Array of host related metadata for each domain
  - `ckan.ingress.hosts.host` - Host domain name Eg data.datopian.com
  - `ckan.ingress.hosts.isExternal` - Flag if domain is interanl or external [default: `false`]
  - `ckan.ingress.hosts.path` - Array of path related metadata
    - `ckan.ingress.hosts.path.port`- Port number
    - `ckan.ingress.hosts.path.service` - Service names
    - `ckan.ingress.hosts.path.path` - Path to serve requests from
- `ckan.ingress.tls` - Array of tls secrets related metadata for each domain
  - `ckan.ingress.tls.secretName` - Name of kubernetes secret to store TLS secrets
  - `ckan.ingress.tls.isExternal` - Flag if domain is interanl or external [default: `false`]
  - `ckan.ingress.tls.hosts` - Array of domain names
- `ckan.ingress.external` - External ingress related metadata (hosts and tls)
  - `ckan.ingress.external.hosts` - Array of host related metadata for each domain
- `ckan.ingress.externalCertificate` - External ingress related metadata (hosts and tls)
  - `ckan.ingress.externalCertificate.hosts.tlsSecret.name`- name of the secret need to be created
  - `ckan.ingress.externalCertificate.hosts.tlsSecret.crt` - base64 encoded value of the certificate
  - `ckan.ingress.externalCertificate.hosts.tlsSecret.key` - base64 encoded value of the private key

## Values For CKAN Service

- `ckan.ckan.replicaCount` - Number of replicas for CKAN pod [default: `2`]
- `ckan.ckan.serviceAccountName` - Service account name
- `ckan.ckan.customCommand` - Custom Command that will used for the container
- `ckan.ckan.runAsRoot` - Flag to run pod with root privileges [default: `false`]
- `ckan.ckan.sleep` - Container will start without running application for 1 hour if set to `true` [default: `true`]
- `ckan.ckan.resources` - Object defining resources (CPU and Memory) for ckan pod
- `ckan.ckan.config` - Plain-text environment variables mounted as a ConfigMap (e.g. `CKAN_SITE_URL`).
- `ckan.ckan.env` - Encrypted environment variables mounted as a SealedSecret (e.g. `CKAN_SQLALCHEMY_URL`).
- `ckan.ckan.image` - Metadata for ckan image
  - `ckan.ckan.image.repository` - Docker repository to pull image from [required]
  - `ckan.ckan.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.ckan.image.tag` - Image tag
- `ckan.ckan.service` - Ckan service related metadata
- `ckan.ckan.ckanOperatorImage` - CCO image to trigger the psql and other init. [default: `viderum/ckan-cloud-docker:cca-operator-latest`]
- `ckan.ckan.envVarsSecretName` - Copied Secret from the default namespace that contains value of the SQL instance

## Values For Xloader Service

- `ckan.xloader.replicaCount` - Number of replicas for Xloader pod [default: `1`]
- `ckan.xloader.customCommand` - Custom Command that will used for the container
- `ckan.xloader.resources` - Object defining resources (CPU and Memory)
- `ckan.xloader.config` - Plain-text environment variables mounted as a ConfigMap.
- `ckan.xloader.env` - Encrypted environment variables mounted as a SealedSecret.
- `ckan.xloader.image` - Metadata for Xloader image
- `ckan.xloader.service` - Xloader service related metadata
- `ckan.xloader.supervisor` - Xloader supervisor service related metadata

## Values For Datapusher Service

- `ckan.datapusher.enable` - Flag to enable datapusher [default: `true`]
- `ckan.datapusher.config` - Plain-text environment variables mounted as a ConfigMap.
- `ckan.datapusher.env` - Encrypted environment variables mounted as a SealedSecret.
- `ckan.datapusher.replicaCount` - Number of replicas for datapusher pods [default: `1`]
- `ckan.datapusher.image` - Metadata for Datapusher image
- `ckan.datapusher.service` - Datapusher service related metadata
- `ckan.datapusher.resources` - Object defining resources (CPU and Memory) for datapusher pod

## Values For Frontend Service

- `ckan.frontend.enable` - Flag to enable frontend [default: `false`]
- `ckan.frontend.config` - Plain-text environment variables mounted as a ConfigMap (e.g., `SITE_URL`).
- `ckan.frontend.env` - Encrypted environment variables mounted as a SealedSecret (e.g., `SESSION_SECRET`).
- `ckan.frontend.replicaCount` - Number of replicas for frontend pods [default: `2`]
- `ckan.frontend.runAsRoot` - Flag to run container as root user [default: `false`]
- `ckan.frontend.debug` - Flag to run container in debug mode [default: `false`]
- `ckan.frontend.image` - Metadata for frontend image
- `ckan.frontend.service` - Frontend service related metadata

## Values For Auth Service

- `ckan.auth.enable` - Flag to enable auth [default: `false`]
- `ckan.auth.config` - Plain-text environment variables mounted as a ConfigMap.
- `ckan.auth.env` - Encrypted environment variables mounted as a SealedSecret (e.g., `DSN`).
- `ckan.auth.replicaCount` - Number of replicas for auth pods [default: `2`]
- `ckan.auth.image` - Metadata for auth image

## Values For Data Subscription Service

- `ckan.dataSubscriptions.enable` - flag to enable dataSubscriptions [default: `false`]
- `ckan.dataSubscriptions.config` - Plain-text environment variables mounted as a ConfigMap.
- `ckan.dataSubscriptions.env` - Encrypted environment variables mounted as a SealedSecret.
- `ckan.dataSubscriptions.replicaCount` - Number of replicas [default: `2`]
- `ckan.dataSubscriptions.image` - Metadata for image
- `ckan.dataSubscriptions.service` - Service related metadata

## Values For Giftless Service

- `ckan.giftless.enable` - Flag to enable Giftless [default: `false`]
- `ckan.giftless.env.GIFTLESS_YAML_CONTENT` - Base64 encoded and encrypted (`kubeseal`) string containing the entire contents of the `giftless.yaml` configuration file. **[Required if `useSealedSecrets: true`]**.
- `ckan.giftless.replicaCount` - Number of replicas for giftless pods [default: `2`]
- `ckan.giftless.port` - Port number for giftless pod [default: `5000`]
- `ckan.giftless.JwtRs256Key` - Base64 endoded JWT RS256 private key [Required if `useSealedSecrets: false`]
- `ckan.giftless.JwtRs256KeyPub` - Base64 endoded JWT RS256 public key [Required if `useSealedSecrets: false`]
- `ckan.giftless.GoogleAccountCredentials` - Base64 encoded Google service account credentials [Required if `useSealedSecrets: false`]
- `ckan.giftless.project` - Google Project ID [Required if `useSealedSecrets: false`]
- `ckan.giftless.bucket` - Google Storage bucket name (should exist) [Required if `useSealedSecrets: false`]
- `ckan.giftless.runAsRoot` - Flag to run pod with root privileges [default: `false`]
- `ckan.giftless.sleep` - Container will start without running application for 1 hour if set to `true` [default: `true`]
- `ckan.giftless.image` - Metadata for giftless image

## Values For SOLR Service

- `ckan.solr.image` - SOLR image related metadata
  - `ckan.solr.image.tag` - SOLR version [default: 6.6.6]

## Values For Separate CKAN Service for Datapusher

- `ckan.ckanmiddleware.enable` - Flag to enable ckan service for only datapusher [default: `true`]
- `ckan.ckanmiddleware.replicaCount` - Number of replicas for datapusher pods [default: `1`]
- `ckan.ckanmiddleware.ingress.enable` - Flag to enable Nginx Ingress
- `ckan.ckanmiddleware.ingress.proxyBodySize` - Value for `nginx.ingress.kubernetes.io/proxy-body-size` [default: `1000m`]
- `ckan.ckanmiddleware.resources` - Object defining resources (CPU and Memory) for ckan pod [default: `{limits: {cpu: 1000m, memory: 4Gb}, {requests: cpu: 600m memory: 2Gb}}`]
