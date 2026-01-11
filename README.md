# argus-observability-lab

## Pre Requisites

We need the following to ensure the cluster can run and function as expected:
- Docker
- [kind](https://kind.sigs.k8s.io)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Not required but makes it a lot easier to work with the cluster.
- [helm](https://helm.sh/docs/intro/install/)

## Start kind Cluster

```bash
kind create cluster --config ./kind-cluster.yaml
```

### Install HA proxy Ingress controller

We'll use helm to install haproxy ingress and set nodeports to predefined values to make it easier to access services.

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


