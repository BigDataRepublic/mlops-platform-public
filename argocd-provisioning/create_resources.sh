# The tunnel should have been setup on port 8888 beforehand
export NO_PROXY=oauth2.googleapis.com,kubernetes-sigs.github.io
export HTTPS_PROXY=localhost:8888

echo "Preparing generic resources"
kubectl apply -f manifests/provisioning/namespaces.yaml

echo "Installing the GCE external secrets"
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n eso --wait

echo "Installing istio"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --set pilot.resources.requests.memory=100Mi --set pilot.resources.requests.cpu=100m --wait
kubectl apply -f manifests/provisioning/istio-gateway.yaml

echo "Installing argocd"
kubectl apply -f manifests/provisioning/secrets.yaml
kubectl apply -n argocd -f ../applications/argocd
kubectl apply -f manifests/apps
