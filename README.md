# consul-k8s-ingress-controllers

## Prerequisites



1. Install the following cli tools
1. Install a Kubernetes cluster with a load balancer. This example uses GKE. You can run Terraform to create the cluster.

    ```sh
    $ cd cluster && terraform init && terraform apply
    ```

2. Get the kube configuration for the deployed cluster (change the cluster name and region below)

    ```sh
    $ gcloud container clusters get-credentials hc-abcdefghijkl123456 --region us-west1
    ```

3. Make sure the cluster is accessible

    ```sh
    $ kubectl get ns

    NAME              STATUS   AGE
    default           Active   1h
    kube-node-lease   Active   1h
    kube-public       Active   1h
    kube-system       Active   1h
    ```

4. Deploy Consul on the cluster

    ```sh
    $ helm repo add hashicorp https://helm.releases.hashicorp.com
    $ helm install --values consul/consul.yaml consul hashicorp/consul --create-namespace --namespace consul
    ```

5. Configure Consul access

    ```sh
    $ export CONSUL_HTTP_TOKEN=$(kubectl get -n consul secrets/consul-bootstrap-acl-token --template={{.data.token}} | base64 -d)
    $ export CONSUL_HTTP_ADDR=$(kubectl get svc -n consul consul-ui --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    $ export CONSUL_HTTP_SSL_VERIFY=false
    ```

6. 