# CKAN Helm Chart

Helm charts to create CKAN instances and relates services. This repository
contains helm chart templates that are used across the projects to deploy
application.

## Values.yaml

`values.yaml` is the main configuration file for CKAN helm charts. Its Values are
populating helm chart variables in templates accordingly. In `values.yaml` we are
able to configure things  like

- Enabling needed services (Next Gent frontend, Giftless etc...)
- Passing Environment Variables to Container
- Defining which Images to use for Services
- Allocating Resources (CPU, Memory) for Services
- Enabling Auto Scaling
- And more

See full list of values and their reference in [Values File](/values.md)

## Quickstart

Each New project uses its own set of configurations (values.yaml) depending on
its needs. All you need are [Charts.yaml](#charts.yaml) and [values.yaml](#values.yaml).

```
mkdir my-awesome-project && cd my-awesome-project
touch Charts.yaml values.yaml
```

## Charts.yaml

Your `Charts.yaml` should look smth like this

```
cat Charts.yaml

apiVersion: v2
name: my-awesome-project
description: The best project I've deployed
type: application
version: 0.0.1
appVersion: 0.0.1
dependencies:
  - name: redis
    repository: https://charts.bitnami.com/bitnami
    version: "10.7.4"
  - name: solr
    version: "1.5.2"
    repository: http://storage.googleapis.com/kubernetes-charts-incubator
  - name: ckan
    version: "0.0.1"
    repository: "https://gitlab.com/datopian/experiments/dx-helm-ckan"
```

### values.yaml

See [values.example.yaml](/ckan/values.example.yaml) to get and idea how your `value.yaml`
shold look like.

## Release new version

Update the version in `ckan/Chart.yaml`

```
# Create Package
cd charts
helm package ../ckan

# Create New index
helm repo index .
```
