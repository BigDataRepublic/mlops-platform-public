# The tunnel should have been setup on port 8888 beforehand
export NO_PROXY=oauth2.googleapis.com,kubernetes-sigs.github.io
export HTTPS_PROXY=localhost:8888

echo "Deleting argocd"
kubectl delete -f manifests/apps
kubectl delete -n argocd -f ../applications/argocd
kubectl delete -f manifests/provisioning/secrets.yaml

echo "Deleting istio"
kubectl delete -f manifests/provisioning/istio-gateway.yaml
helm delete istiod -n istio-system
helm delete istio-base -n istio-system
helm repo remove istio

echo "Deleting the GCE external secrets"
helm uninstall external-secrets -n eso
helm repo remove external-secrets

echo "Deleting generic resources"
kubectl delete -f manifests/provisioning/namespaces.yaml
