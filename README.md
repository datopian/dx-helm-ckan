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

## Using Charts

Charts are installed with helm per project. Each New project uses its own set of configurations (values.yaml) depending on
its needs. See [VALUES.md](#VALUES.md) for values reference.

You will need [Charts.yaml](#charts.yaml) and [values.yaml](#values.yaml).

```
mkdir my-awesome-project && cd my-awesome-project
touch Charts.yaml values.yaml
```

Your `Charts.yaml` defines what dependencies your helm deployment has.
This repository also represents a remote repository for helm charts. You can set
It in your Charts.yaml including version. Run `helm repo update` to get desired verison of cahrts


Example of how `Charts.yaml` might look like

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
    version: "1.3.0"
    repository: "https://raw.githubusercontent.com/datopian/dx-helm-ckan/master/charts/""
```

### values.yaml

See [values.example.yaml](/ckan/values.example.yaml) to get and idea how your `value.yaml`
shold look like.

## Releasing new version

New releases automated by GitHub actions. New versions are pushed to `charts` directory on tagged commit.

To release new package commit your changes to the master and create a tagged release. Tags should be following semantic versions starting with "v"

```
# Make changes, commit  and push to master (you probably need to skip this step)
git add <<changesd filed>>
git commit -m'My awesome changes'
git push origin master

# Create a tagged rlease
git tag v1.1.1
git push origin v1.1.1
```
