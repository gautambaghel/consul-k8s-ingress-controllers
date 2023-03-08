# consul-k8s-ingress-controllers

## Prerequisites

1. Install the following cli tools on your local machine: 
   * `consul`
   * `gcloud`
   * `helm`
   * `kubectl`
   * `terraform`


1. Install a Kubernetes cluster with a load balancer. This example uses GKE. You can run Terraform to create the cluster.

    ```sh
    $ cd cluster && terraform init && terraform apply
    ```

1. Get the kube configuration for the deployed cluster (change the cluster name and region below)

    ```sh
    $ gcloud container clusters get-credentials hc-abcdefghijkl123456 --region us-west1
    ```

1. Make sure the cluster is accessible

    ```sh
    $ kubectl get ns

    NAME              STATUS   AGE
    default           Active   1h
    kube-node-lease   Active   1h
    kube-public       Active   1h
    kube-system       Active   1h
    ```

1. Deploy Consul on the cluster

    ```sh
    $ helm repo add hashicorp https://helm.releases.hashicorp.com
    $ helm install --values consul/consul.yaml consul hashicorp/consul --create-namespace --namespace consul
    ```

1. Confirm Consul is accessible

    ```sh
    $ export CONSUL_HTTP_TOKEN=$(kubectl get -n consul secrets/consul-bootstrap-acl-token --template={{.data.token}} | base64 -d)
    $ export CONSUL_HTTP_ADDR=$(kubectl get svc -n consul consul-ui --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    $ export CONSUL_HTTP_SSL_VERIFY=false
    $ consul members
    ```

1. Apply intentions and proxy defaults to Consul on Kubernetes

    ```sh
    $ kubectl apply -f consul/intention-defaults.yaml
    $ kubectl apply -f consul/proxy-defaults.yaml
    ```

1. Deploy the example workloads, UI and web, and intentions for services
   
    ```sh
    $ kubectl apply -f app/
    ```