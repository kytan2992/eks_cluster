# eks_cluster

Terraform code for creating an EKS Cluster and testing with Google MicroService Online Boutique Demo

* Some stuff are still in testing/WIP, cannot guarantee everything will be working! 

> ## Making Route 53

- **Install ExternalDNS:**
  - create iam role and policies for ExternalDNS --- see iam.tf
  - helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
  - helm upgrade --install external-dns external-dns/external-dns --values externaldns-values.yaml
- **Install Ng-Inx:**
  - kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.0.0/deploy/crds.yaml
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
    --set extraArgs={--default-ingress-class=nginx} # not sure if really needed, cos this will block grafana ingress
- **Run yaml files:**
  - run clusterissuer.yaml
  - edit ingress.yaml (add annotations certmanager and spec:tls) and deploy again

> ## Adding monitoring (promethus/grafana/alertmanager)
* Still testing, cannot guarantee all fully functional 
- **Deploy promethus, grafana, alertmanager and all required resources**
  - helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  - helm repo update
  - helm install {RELEASE NAME} prometheus-community/kube-prometheus-stack \ --namespace monitoring --create-namespace
- **Patch pods to allow opentelemetry**
  - *I've already done in manually in this manifests deployment file, but if using the official one run the kustomize file to enable opentelemetry since the official app is intergrated to opentelemtry by default
- **Deploy Opentelemetry services**
  - deploy otel-collector.yaml - Opentelemetry Collector
  - deploy opentele-service.yaml - Opentelemetry Collector Exporter to expose metrics endpoint
  - deploy servicemonitor.yaml - Allow prometheus to scrape Opentelemetry Collector

- **Add logging services (below here not tested/complete yet just list for future ref)**
  - helm repo add grafana https://grafana.github.io/helm-charts
  - helm repo update
  - helm upgrade --install {RELEASE NAME} grafana/loki-stack \
    --namespace *(same namespace as kube-prometheus-stack)* \
    --set grafana.enabled=false *(since we've alr installed earlier in kube-prometheus stack)*\ 
    --set persistence.enabled=true *(Enables persistent storage for Loki logs. Otherwise, logs are lost on pod restart.)* \
    --set persistence.size=10Gi *(Sets the volume size for Loki's persistent volume claim (PVC). Adjust based on retention needs.)* \
    --set serviceMonitor.enabled=true \
  - helm upgrade --install grafana-alloy grafana/alloy \
    --namespace *(same namespace as kube-prometheus-stack)* \
    --set mode=logs \
    --set alloy.logs.exporters.loki.endpoint="http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"
