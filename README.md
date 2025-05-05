# eks_cluster

Terraform code for creating an EKS Cluster and testing with Google MicroService Online Boutique Demo

> ## Making Route 53

- **Install ExternalDNS:**
  - create iam role and policies for ExternalDNS --- see iam.tf
  - helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
  - helm upgrade --install external-dns external-dns/external-dns --values externaldns-values.yaml
- **Install Ng-Inx:**
  - helm install my-release oci://ghcr.io/nginx/charts/nginx-ingress --version 2.1.0
  - helm upgrade my-release oci://ghcr.io/nginx/charts/nginx-ingress --version 2.1.0
- **Run yaml files**
  - run kubernetes-manifest.yaml (make sure loadbalancer service is commented out since we are using ingress instead)
  - run ingress.yaml (comment out annotations: cert-manager.io/cluster-issuer and spec:tls hosts and secretname first since cert-manager not installed yet)

> ## Adding Certificate Manager

- **Install Cert Manager:**
  - helm repo add jetstack https://charts.jetstack.io --force-update
  - helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.17.2 \
    --set crds.enabled=true
- **Run yaml files:**
  - run clusterissuer.yaml
  - edit ingress.yaml (add annotations certmanager and spec:tls) and deploy again
