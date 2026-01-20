# argos-observability-lab

The project was born out of the need to have a k8s cluster that's as close to an actual cluster as possible that I can run on my Raspberrypi.

Minikube is good for starting but it doesn't really come close to an actual cluster. I tried k3d but that came with it's own set of challenges.

Kind started as good but did have some issues if I went past the two nodes that are currently configured. Even with the lower number of workers, it feels like an actual cluster and allows me to deploy the required components.

Once I did have at least a few components working, I wanted to share the project so here it is!

The following shows up a high level diagram of the cluster as it stands now. As of now the ELK stack is on the todo list(coming soon)

![](./argos-arch-dark.png)

the following minimal config allows you to get a cluster running on a local laptop and get Prometheus and Grafana up and running with some data collection started within minutes.

## Pre Requisites

We need the following to ensure the cluster can run and function as expected:
- Docker
- [kind](https://kind.sigs.k8s.io)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Not required but makes it a lot easier to work with the cluster.
- [helm](https://helm.sh/docs/intro/install/) - Optional if you want to install using helm directly
- [terraform](https://developer.hashicorp.com/terraform) - Optional if you want to use terraform to install haproxy

## Start kind Cluster

The config file provides most of the neccessary config but requires one change.

The mount path on your machine may be different and needs to be updated as required.

Update the following lines to change the path to the directory where you cloned the repository.
```
  - role: worker
    extraMounts:
      - hostPath: < repository path >
```

```bash
kind create cluster --config ./kind-cluster.yaml
```

## Install HAProxy Ingress Controller
### Install HA proxy Ingress controller using Helm

We may use helm to install haproxy ingress and set nodeports to predefined values to make it easier to access services.

```
helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo udpate
helm install haproxy-kubernetes-ingress haproxytech/kubernetes-ingress \
  --create-namespace \
  --namespace haproxy-controller \
  --set controller.service.nodePorts.http=30000 \
  --set controller.service.nodePorts.https=30001 \
  --set controller.service.nodePorts.stat=30002 \
  --set controller.service.nodePorts.prometheus=30003
```

### Install HA Proxy Ingress controller using Terraform

The code for the installation is in the terraform directory

Install using the following commands after changing to the terraform directory.

```bash
terraform init
terraform plan # optional to view output and validate changes
terraform apply
```

## Install Metrics Server

### Install using kubectl

The metrics server provides the neccessary telemetry to work with HPA and may be installed using:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```


## Deploy Promethes

Prometheus is set up with a deployment, a ClusterIP service and an Ingress

Deploy using the following command:

```bash
kubectl apply -f prom/
```
If the pods are started successfully and everything went well you can access the prometheus interface at:

> http://< local or remote host >:30000/prometheus


## Deploy Grafana

Grafana can be installed as a stand alone component using the following command:

```bash
kubectl apply -f grafana/
```

This deploys the pods, service and ingress.

If the pods are started successfully and everything went well you can access the grafana interface at:

> http://< local or remote host >:30000/grafana

If you want to connect Prometheus to Grafana to start visualizing your data you'll have to add the Prometheus data source with the following URL.

> http://prom-internal-service.prometheus:9090/prometheus

## New Relic Observability Setup

### Install New Relic agents and required configs using Helm

We may use helm to install the New Relic bundle and associated requirements.

The following commands also provide the required configuratin parameters for us to toggle, update.

```bash
KSM_IMAGE_VERSION="v2.13.0"
helm repo add newrelic https://helm-charts.newrelic.com 
helm repo update 
kubectl create namespace newrelic ; 
helm upgrade --install newrelic-bundle newrelic/nri-bundle \
--set global.licenseKey=<> \
--set global.cluster=argos \
--namespace=newrelic \
--set global.lowDataMode=true \
--set kube-state-metrics.image.tag=${KSM_IMAGE_VERSION} \
--set kube-state-metrics.enabled=true \
--set kubeEvents.enabled=true \
--set newrelic-prometheus-agent.enabled=true \
--set newrelic-prometheus-agent.lowDataMode=true \
--set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \
--set k8s-agents-operator.enabled=true \
--set logging.enabled=true \
--set newrelic-logging.lowDataMode=true \
```

### Install New Relic agents using Terraform

I've created a module for New Relic that allows us to pass the values to it to add the required agents and configurations.

The terraform values are assigned in the *terraform.tfvars* file. Although this file isn't usually committed to the repository, I wanted to provide this as a sample.

The module has been written in such a way that you can toggle the installation of New Relic with a single parameter.

Use the following variable to toggle this module.

> install_newrelic_k8s   = false

The New Relic Key is something you'll have to get for your environment or create to allow reporting data to the correct account.

> newrelic_key           = "<new relic license key>"

The following uses a map to define the other settings that are then used within the module to create the configuration.

```
newrelic_options = {
  "global.lowDataMode"                                                      = "true"
  "kubeEvents.enabled"                                                      = "true"
  "logging.enabled"                                                         = "true"
  "newrelic-logging.lowDataMode"                                            = "true"
  "k8s-agents-operator.enabled"                                             = "true"
  "global.cluster"                                                          = "argus"
  "newrelic-prometheus-agent.enabled"                                       = "true"
  "newrelic-prometheus-agent.lowDataMode"                                   = "true"
  "newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled" = "false"
}
```

Install using the following commands after changing to the terraform directory and updating the variables.

```bash
terraform init
terraform plan # optional to view output and validate changes
terraform apply
```

## DataDog Observability Setup

### Install DataDog Operator using Helm

We may use helm to install the New Relic bundle and associated requirements. There are additional steps in this case since the manifest needs to be applied to the cluster separately.

The following installs the DataDog operator into the cluster and creates the secret for the api-key.
```bash
helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator
kubectl create secret generic datadog-secret --from-literal api-key=< api key >
```

Once the operator is installed, you must apply the manifest with the configuration.

The following yaml file provides the basic config. Create the file *datadog-agent.yml* with the following contents.

```yaml
kind: "DatadogAgent"
apiVersion: "datadoghq.com/v2alpha1"
metadata:
  name: "datadog"
spec:
  global:
    clusterName: "argos"
    site: "us5.datadoghq.com"
    credentials:
      apiSecret:
        secretName: "datadog-secret"
        keyName: "api-key"
  features:
    clusterChecks:
      enabled: true
    orchestratorExplorer:
      enabled: true
    logCollection:
      enabled: true
      containerCollectAll: true
    otelCollector:
      enabled: true
      ports:
        - containerPort: 4317
          hostPort: 4317
          name: "otel-grpc"
        - containerPort: 4318
          hostPort: 4318
          name: "otel-http"
  override:
    nodeAgent:
      env:
        - name: "DD_HOSTNAME_TRUST_UTS_NAMESPACE"
          value: "true"
    clusterAgent:
      containers:
        cluster-agent:
          env:
            - name: "DD_HOSTNAME_TRUST_UTS_NAMESPACE"
              value: "true"

```

> NOTE: The environment variables for NodeAgent and ClusterAgent had to be added to ensure that the containers are able to resolve the hostnames. Without them the agent was stuck in a CrashLoop

Apply the configuration using:

```bash
kubectl apply -f datadog-agent.yaml
```

### Install DataDog Operator using Terraform

I've created a module for DataDog that allows us to pass the values to it to add the required agents and configurations.

The terraform values are assigned in the *terraform.tfvars* file. Although this file isn't usually committed to the repository, I wanted to provide this as a sample.

The module has been written in such a way that you can toggle the installation of DataDog with a single parameter.

Use the following variable to toggle this module.

> install_datadog_k8s    = false

The DataDog Key is something you'll have to get for your environment or create to allow reporting data to the correct account.

> datadog_key = "<datadog api key>"

Install using the following commands after changing to the terraform directory and updating the variables.

```bash
terraform init
terraform plan # optional to view output and validate changes
terraform apply
```

The module also contains some provisioners that allow adding the datadog-agent.yml to the cluster post installation of the required operator.

I've noticed some issues with the removal of datadog operators from the cluster. The module will be updated further if the issues persist.

## ToDo

The next steps for the project are:

- [ ] Add ELK stack option
- [x] Add New Relic observability option
- [x] Add DataDog observability option
- [ ] Add Sample App workload
- [ ] Add API Server workload
- [ ] Add Opentelemetry instrumentation and collector for sample App and API server
- [ ] Add LGTM stack option
- [ ] More
