# Some manual
kubectl create poddisruptionbudget fluentbit-pdb --namespace=kube-system --selector k8s-app=fluentbit-gke --max-unavailable 1
kubectl create poddisruptionbudget gke-metadata-pdb --namespace=kube-system --selector k8s-app=gke-metadata-server --max-unavailable 1
kubectl create poddisruptionbudget gke-metrics-pdb --namespace=kube-system --selector k8s-app=gke-metrics-agent --max-unavailable 1
kubectl create poddisruptionbudget ip-masq-pdb --namespace=kube-system --selector k8s-app=ip-masq-agent --max-unavailable 1
kubectl create poddisruptionbudget netd-pdb --namespace=kube-system --selector k8s-app=netd --max-unavailable 1

kubectl create poddisruptionbudget l7-default-backend-pdb --namespace=kube-system --selector name=glbc --max-unavailable 1
kubectl create poddisruptionbudget metrics-server-pdb --namespace=kube-system --selector k8s-app=metrics-server --max-unavailable 1
kubectl create poddisruptionbudget kube-dns-autoscaler-pdb --namespace=kube-system --selector k8s-app=kube-dns-autoscaler --max-unavailable 1
kubectl create poddisruptionbudget event-pdb --namespace=kube-system --selector k8s-app=event-exporter --max-unavailable 1
kubectl create poddisruptionbudget kube-dns-pdb --namespace=kube-system --selector k8s-app=kube-dns --max-unavailable 1
