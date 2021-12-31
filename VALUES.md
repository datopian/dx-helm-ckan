# CKAN Values File Reference

Below you can find the values and their definitions used in helm charts to boot CKAN instance
and all the necessary services. There are several services running in the Namespace
And each has some configurable options. Depending on instance needs some of them might
not have a full set of services.

All the values that need to be overrider from the ckan chart should come under `ckan: {}`. Please refer to the `values.example.yaml` file.

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
- `ckan.general.maintenance` - Enable it to put all the ingress in maintenance mode [default: `false`]
- `ckan.general.maintenanceImage` - registry URL to pull image from [default: `registry.gitlab.com/datopian/deploys/maintenance-page:latest`]
- `ckan.general.projectId`- The project ID <projectname-environment> Eg: datahub-staging
- `ckan.general.imagePullSecrets` - The name of `kubernetes.io/dockerconfigjson` secrets that contains credentials for private docker registry [default: `ckan-sealed-registry`]
- `ckan.general.useProductionCerts` - Flag to use let's encypts production certificates or staging [default: `false`]
- `ckan.general.autoscaling` - Object containing auto Scaling related metadata
  - `ckan.general.autoscaling.enable` - Flag to enable autoscaling [default: `false`]
  - `ckan.general.autoscaling.maxReplicas` - Maximum number of replicas [default: `5`]
  - `ckan.general.autoscaling.minReplicas` - Minimum number of replicas [default: `1`]
  - `ckan.general.autoscaling.targetCPUUtilizationPercentage` - Target CPU Utilization in Percentage [default: `80`]
  - `ckan.general.autoscaling.targetMemoryUtilizationPercentage` - Target Memory Utilization in Percentage [default: `80`]
- `ckan.general.env` - Environment Variables for global use (EG Postgre Super User credentials)
  - `ckan.general.env.POSTGRES_HOST` - Postgres Host
  - `ckan.general.env.POSTGRES_SUPER_USER` - Postgres Super User username
  - `ckan.general.env.POSTGRES_SUPER_USER_PASSWORD` - Postgres Super User password
- `ckan.general.sealedSecrets` - Object containing metadata about sealed secrets
  - `ckan.general.sealedSecrets.enable` - Flag to enable scaled secrets [default: `true`]
  - `ckan.general.sealedSecrets.registry` - Private registry metadata
    - `ckan.general.sealedSecrets.registry.dockerconfigjson` - base64 encoded encrypted secretes from private registry
- `backupCronTab` - schedule expressions as a cron tab [default: `0 1 * * *`]

## Values For Nginx Ingress

- `ckan.ingress.enable` - Flag to enable Nginx Ingress
- `ckan.ingress.ingressClass` - The name of the ingress to use [default: `nginx-production`]
- `ckan.ingress.clusterIssuer` - The name of the ingress to use [default: `letsencrypt-production`, `letsencrypt-staging`]
- `ckan.ingress.enableExternal` - Flag to enable Nginx Ingress for external domains
- `ckan.ingress.enableExternalCertificate` - Flag to enable Nginx Ingress for external domains having their own certificate
- `ckan.ingress.limitConnections` - Number of concurrent connection per IP. Value for `nginx.ingress.kubernetes.io/limit-connections` [default: `20`]
- `ckan.ingress.limitRps` - Number of connections per second per IP. Value for `nginx.ingress.kubernetes.io/limit-rps` [default: `25`]
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
- `ckan.ingress.tls` - Array of tsl secrets related metadata for each domain
  - `ckan.ingress.tls.secretName` - Name of kubernetes secret to store TLS secrets
  - `ckan.ingress.tls.isExternal` - Flag if domain is interanl or external [default: `false`]
  - `ckan.ingress.tls.hosts` - Array of domain names
- `ckan.ingress.external` - External ingress related metadata (hosts and tls)
  - `ckan.ingress.external.hosts` - Array of host related metadata for each domain
    - `ckan.ingress.external.hosts.host` - Host domain name Eg data.datopian.com
    - `ckan.ingress.external.hosts.isExternal` - Flag if domain is interanl or external [default: `false`]
    - `ckan.ingress.external.hosts.path` - Array of path related metadata
      - `ckan.ingress.external.hosts.path.port`- Port number
      - `ckan.ingress.external.hosts.path.service` - Service names
      - `ckan.ingress.external.hosts.path.path` - Path to serve requests from
  - `ckan.ingress.external.tls` - Array of tsl secrets related metadata for each domain
    - `ckan.ingress.external.tls.secretName` - Name of kubernetes secret to store TLS secrets
    - `ckan.ingress.external.tls.isExternal` - Flag if domain is interanl or external [default: `false`]
    - `ckan.ingress.external.tls.hosts` - Array of domain names
- `ckan.ingress.externalCertificate` - External ingress related metadata (hosts and tls)
  - `ckan.ingress.externalCertificate.hosts` - Array of host related metadata for each domain
    - `ckan.ingress.externalCertificate.hosts.host` - Host domain name Eg data.datopian.com
    - `ckan.ingress.externalCertificate.hosts.isExternal` - Flag if domain is interanl or external [default: `false`]
    - `ckan.ingress.externalCertificate.hosts.path` - Array of path related metadata
      - `ckan.ingress.externalCertificate.hosts.path.port`- Port number
      - `ckan.ingress.externalCertificate.hosts.path.service` - Service names
      - `ckan.ingress.externalCertificate.hosts.path.path` - Path to serve requests from
    - `ckan.ingress.externalCertificate.hosts.tlsSecret` - Details of the Key, Certificate and Secret Name
      - `ckan.ingress.externalCertificate.hosts.tlsSecret.name`- name of the secret need to be created
      - `ckan.ingress.externalCertificate.hosts.tlsSecret.crt` - base64 encoded value of the certificate with the intermediate certificate
      - `ckan.ingress.externalCertificate.hosts.tlsSecret.key` - base64 encoded value of the private key
  - `ckan.ingress.externalCertificate.tls` - Array of tsl secrets related metadata for each domain
    - `ckan.ingress.externalCertificate.tls.secretName` - Name of kubernetes secret to store TLS secrets
    - `ckan.ingress.externalCertificate.tls.isExternal` - Flag if domain is interanl or external [default: `false`]
    - `ckan.ingress.externalCertificate.tls.hosts` - Array of domain names

## Values For CKAN Service

- `ckan.ckan.replicaCount` - Number of replicas for CKAN pod [default: `2`]
- `ckan.ckan.serviceAccountName` - Service account name
- `ckan.ckan.customCommand` - Custom Command that will used for the container if not specified command from the docker image will be used
- `ckan.ckan.runAsRoot` - Flag to run pod with root privileges [default: `false`]
- `ckan.ckan.sleep` - Container will start without running application for 1 hour if set to `true` [default: `true`]
- `ckan.ckan.resources` - Object defining resources (CPU and Memory) for ckan pod [default: `{limits: {cpu: 1500m, memory: 3Gb}, {requests: cpu: 800m memory: 2Gb}}`]
- `ckan.ckan.env` - Environment variables for ckan container
- `ckan.ckan.image` - Metadata for ckan image
  - `ckan.ckan.image.repository` - Docker repository to pull image from [required]
  - `ckan.ckan.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.ckan.image.tag` - Image tag [required if digest not present]
  - `ckan.ckan.image.digest` - Image sha digest [required if tag not present]
- `ckan.ckan.service` - Ckan service related metadata
  - `ckan.ckan.serviceType` - Service type [default: `ClusterIP`]
  - `ckan.ckan.port` - Service port [default: `80`]
  - `ckan.ckan.targetPort` - Target port container is exposing [default: `5000`]
- `ckan.ckan.ckanOperatorImage` - CCO image to trigger the psql and other init. [default: `viderum/ckan-cloud-docker:cca-operator-latest`]
- `ckan.ckan.envVarsSecretName` - Copied Secret from the default namespace that contains value of the SQL instance
- `ckan.ckan.livenessProbe` - LivenessProbe for CKAN

## Values For Xloader Service

- `ckan.xloader.replicaCount` - Number of replicas for Xloader pod [default: `1`]
- `ckan.xloader.serviceAccountName` - Service account name
- `ckan.xloader.customCommand` - Custom Command that will used for the container if not specified command from the docker image will be used
- `ckan.xloader.resources` - Object defining resources (CPU and Memory) for ckan pod [default: `{limits: {cpu: 800m, memory: 1.5Gb}, {requests: cpu: 400m memory: 1Gb}}`]
- `ckan.xloader.env` - Environment variables for Xloader container
- `ckan.xloader.image` - Metadata for ckan image
  - `ckan.xloader.image.repository` - Docker repository to pull image from [required]
  - `ckan.xloader.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.xloader.image.tag` - Image tag [required if digest not present]
  - `ckan.xloader.image.digest` - Image sha digest [required if tag not present]
- `ckan.xloader.service` - Xloader service related metadata
  - `ckan.xloader.serviceType` - Service type [default: `ClusterIP`]
  - `ckan.xloader.port` - Service port [default: `80`]
  - `ckan.xloader.targetPort` - Target port container is exposing [default: `8000`]
- `ckan.xloader.supervisor` - Xloader service related metadata
  - `ckan.xloader.supervisor.port` - Service port [default: `80`]
  - `ckan.xloader.supervisor.targetPort` - Target port container is exposing [default: `9001`]

## Values For Datapusher Service

- `ckan.datapusher.enable` - Flag to enable datapusher [default: `true`]
- `ckan.datapusher.env` - Environment variables for datapusher container
- `ckan.datapusher.replicaCount` - Number of replicas for datapusher pods [default: `1`]
- `ckan.datapusher.image` - Metadata for Datapusher image
  - `ckan.datapusher.image.repository` - Docker repository to pull the image from [default: `registry.gitlab.com/viderum/docker-datapusher`]
  - `ckan.datapusher.image.pullPolicy` - Datapusher Image pull policy [default: `Always`]
  - `ckan.datapusher.image.tag` - Datapusher Image tag [required if digest not present]
  - `ckan.datapusher.image.digest` - Datapusher Image sha digest [required if tag not present]
- `ckan.datapusher.service` - Datapusher service related metadata
  - `ckan.datapusher.port` - Service port [default: `80`]
  - `ckan.datapusher.targetPort` - Target port container is exposing [default: `5000`]
- `ckan.datapusher.resources` - Object defining resources (CPU and Memory) for datapusher pod [default: `{limits: {cpu: 1500m, memory: 4Gb}, {requests: cpu: 800m memory: 2Gb}}`]
- `ckan.datapusher.livenessProbe` - LivenessProbe for Datapusher

## Values For Frontend Service

- `ckan.frontend.enable` - Flag to enable frontend [default: `false`]
- `ckan.frontend.customCommand` - Custom Command that will used for the container if not specified command from the docker image will be used
- `ckan.frontend.env` - Environment variables for frontend container
- `ckan.frontend.replicaCount` - Number of replicas for frontend pods [default: `2`]
- `ckan.frontend.runAsRoot` - Flag to run container as root user [default: `false`]
- `ckan.frontend.debug` - Flag to run container in debug mode (with nodemon) [default: `false`]
- `ckan.frontend.image` - Metadata for ckan image
  - `ckan.frontend.image.repository` - Docker repository to pull the image from [required if enabled]
  - `ckan.frontend.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.frontend.image.tag` - Image tag [required if digest not present]
  - `ckan.frontend.image.digest` - Image sha digest [required if tag not present]
- `ckan.frontend.service` - Frontend service related metadata
  - `ckan.frontend.port` - Service port [default: `80`]
  - `ckan.frontend.targetPort` - Target port container is exposing [default: `4455`]
- `ckan.frontend.livenessProbe` - LivenessProbe for Frontend

## Values For Auth Service

- `ckan.auth.enable` - Flag to enable auth [default: `false`]
- `ckan.auth.env` - Environment variables for auth container
- `ckan.auth.replicaCount` - Number of replicas for auth pods [default: `2`]
- `ckan.auth.dsn` - DSN client key for authentication
- `ckan.auth.image` - Metadata for ckan image
  - `ckan.auth.image.repository` - Docker repository to pull the image from [default: `registry.gitlab.com/datopian/clients/nextgen-auth`]
  - `ckan.auth.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.auth.image.tag` - Image tag [required if digest not present]
  - `ckan.auth.image.digest` - Image sha digest [required if tag not present]

## Values For Data Subscription Service

- `ckan.dataSubscriptions.enable` - flag to enable dataSubscriptions [default: `false`]
- `ckan.dataSubscriptions.env` - Environment variables for dataSubscriptions container
- `ckan.dataSubscriptions.replicaCount` - Number of replicas for dataSubscriptions pods [default: `2`]
- `ckan.dataSubscriptions.image` - Metadata for ckan image
  - `ckan.dataSubscriptions.image.repository` - Docker repository to pull the image from [default: `datopian/data-subscriptions`]
  - `ckan.dataSubscriptions.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.dataSubscriptions.image.tag` - Image tag [required if digest not present]
  - `ckan.dataSubscriptions.image.digest` - Image sha digest [required if tag not present]
- `ckan.dataSubscriptions.service` - Data Subscription service related metadata
  - `ckan.dataSubscriptions.port` - Service port [default: `80`]
  - `ckan.dataSubscriptions.targetPort` - Target port container is exposing [default: `5500`]
- `ckan.dataSubscriptions.livenessProbe` - LivenessProbe for Data Subscriptions

## Values For Giftless Service

- `ckan.giftless.enable` - Flag to enable Giftles [default: `false`]
- `ckan.giftless.env` - Environment variables for Giftles container
- `ckan.giftless.replicaCount` - Number of replicas for giftless pods [default: `2`]
- `ckan.giftless.port` - Port number for giftless pod [default: `5000`]
- `ckan.giftless.JwtRs256Key` - Base64 endoded JWT RS256 private key [required]
- `ckan.giftless.JwtRs256KeyPub` - Base64 endoded JWT RS256 public key [required]
- `ckan.giftless.GoogleAccountCredentials` - Base64 encoded Google service account credentials [required]
- `ckan.giftless.project` - Google Project ID [required]
- `ckan.giftless.bucket` - Google Stroage bucket name (should exist) [requred]
- `ckan.giftless.runAsRoot` - Flag to run pod with root privileges [default: `false`]
- `ckan.giftless.sleep` - Container will start without running application for 1 hour if set to `true` [default: `true`]
- `ckan.giftless.image` - Metadata for ckan image
  - `ckan.giftless.image.repository` - Docker repository to pull image from [default: `datopian/giftless`]
  - `ckan.giftless.image.pullPolicy` - Image pull policy [default: `Always`]
  - `ckan.giftless.image.tag` - Image tag [required if digest not present]
  - `ckan.giftless.image.digest` - Image sha digest [required if tag not present]
- `ckan.giftless.service` - Giftless service related metadata
  - `ckan.giftless.port` - Service port [default: `5000`]
  - `ckan.giftless.targetPort` - Target port container is exposing [default: `5000`]
- `ckan.giftless.livenessProbe` - LivenessProbe for Giftless

## Values For SOLR Service

- `ckan.solr.image` - SOLR image related metadata
  - `ckan.solr.image.tag` - SOLR version [default: 6.6.6]

## Values For Separate CKAN Service for Datapusher

- `ckan.ckanmiddleware.enable` - Flag to enable ckan service for only datapusher [default: `true`]
- `ckan.ckanmiddleware.replicaCount` - Number of replicas for datapusher pods [default: `1`]q
- `ckan.ckanmiddleware.ingress.enable` - Flag to enable Nginx Ingress
- `ckan.ckanmiddleware.ingress.proxyBodySize` - Value for `nginx.ingress.kubernetes.io/proxy-body-size` [default: `1000m`]
- `ckan.ckanmiddleware.ingress.proxyReadTimeOut` - Value for `nginx.ingress.kubernetes.io/proxy-read-timeout` [default: `60`]
- `ckan.ckanmiddleware.ingress.proxyConnectTimeout` - Value for `nginx.ingress.kubernetes.io/proxy-connect-timeout` [default: `60`]
- `ckan.ckanmiddleware.ingress.extraAnnotations` - YAML mapped annotations for nginx ingress that are not considered by default
- `ckan.ckanmiddleware.ingress.hosts` - Array of host related metadata for each domain
  - `ckan.ckanmiddleware.ingress.hosts.host` - Host domain name Eg data.datopian.com
  - `ckan.ckanmiddleware.ingress.hosts.path` - Array of path related metadata
    - `ckan.ckanmiddleware.ingress.hosts.path.port`- Port number
    - `ckan.ckanmiddleware.ingress.hosts.path.service` - Service names
    - `ckan.ckanmiddleware.ingress.hosts.path.path` - Path to serve requests from
- `ckan.ckanmiddleware.ingress.tls` - Array of tsl secrets related metadata for each domain
  - `ckan.ckanmiddleware.ingress.tls.secretName` - Name of kubernetes secret to store TLS secrets
  - `ckan.ckanmiddleware.ingress.tls.hosts` - Array of domain names
- `ckan.ckanmiddleware.resources` - Object defining resources (CPU and Memory) for ckan pod [default: `{limits: {cpu: 1000m, memory: 4Gb}, {requests: cpu: 600m memory: 2Gb}}`]
