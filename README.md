# ML-OPS architecture

The setup entails a
* Hardened GKE cluster: [see "safer cluster"](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/modules/safer-cluster/README.md)
* Bastion host without an external IP address using Identity Aware Proxy. 
* Tinyproxy allowing `kubectl` commands to be piped through the bastion host (enabling local development on a private cluster).

Access to the cluster's control plane is restricted to the bastion host's internal IP using authorized networks.

### Installing dependencies
You need the following CLI's available:
```shell
terraform version
gcloud version
kubectl version
```
Find the guides to install them when needed:
- [Install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Install gcloud](https://cloud.google.com/sdk/docs/install)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)


### Provisioning the GKE kubernetes cluster

The provisioning is done in two parts. First the GKE cluster is created in the gke-terraform subfolder.
Before this provisioning can be done, make sure that the project exists in GCP, and that the Terraform storage exists.
```shell
# Login with gcloud
gcloud auth login
gcloud config set project mlops-platform-public
cd gke-terraform
terraform init
# First configure the project services, otherwise terraform will fail to plan
terraform apply --target module.enabled_google_apis
terraform apply
```

After the GKE cluster exists, in order to bootstrap the argo-cd cluster on kubernetes, we need to set up a local tunnel through the bastion host:
```shell
# First configure the kubeconfig entry for the private cluster:
$(terraform output get_credentials_command | tr -d '"')
# Then open a tunnel to the bastion host:
$(terraform output bastion_ssh_command | tr -d '"')
```

This tunnel should be open on port 8888. Any traffic to the kubernetes endpoint will need to pass through here.
The kubeconfig is configured by the get_credentials_command:
```shell
# Open a new terminal window; you will now be able to run kubectl commands via the bastion host
HTTPS_PROXY=localhost:8888 kubectl get pods --all-namespaces
```

### Provisioning the Argo CD framework with Identity Aware Proxy
The [argocd-provisioning](argocd-provisioning) project will use the tunnel started above to deploy argocd on the cluster.
```shell
# Provision argocd from its own folder
./create_resources.sh
# And destroyed again with
./delete_resources.sh
```

#### Manual steps 
We are using the [kubernetes external secrets operator](https://external-secrets.io/) to access GCE secrets manager (GCESM) from kubernetes as configured through Terraform or added manually.

A GCESM secret needs to be created called `argocd-private-key` that contains the configuration for argocd to read our private repository:

```json
{"name":"mlops-platform-public","sshPrivateKey":"-----BEGIN OPENSSH PRIVATE KEY-----\nSECRET!! Should exist already, or a new one can be created and added to https://github.com/<your.github.repo>/settings/keys\n-----END OPENSSH PRIVATE KEY-----","url":"git@github.com:<your.github.repo>.git"}
```

Besides that, annoyingly it is [not possible](https://issuetracker.google.com/issues/35907249/resources) to create Oauth credentials in an automated way currently.
Therefore in principle you need to do the steps described in [Argocd SSO config](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/google/#configure-a-new-oauth-client-id), and create a secret `argocd-sso-client` like:
```json
{"client_id": "<clientId>.apps.googleusercontent.com","client_secret": "<secret>"}
```

If you deploy Argo CD, it will automatically start reading from configured folders in [applications](applications). Secrets are added as [GCE external secrets](https://external-secrets.io/latest/provider-google-secrets-manager/). If setup correctly, it should be possible to login through using OAuth.

Certificate generation will only succeed if the subdomain is allowed. As this is not managed by terraform, it needs to be fixed manually.

Make sure to create an A record pointing to your chosen domain (`mlops.<your.domain>` in our case) and a CNAME record for all subdomains (`*.mlops.<your.domain>`).

## How to create a new application on the platform?

A new application can be easily added to our MLOps platform. The actual code for the application (and its configuration)
itself lives in [another repository](https://github.com/<your.github.repo>).

A few things have to be configured on the platform side to enable our end-users to use a new applications
1. If necessary, create a `virtual-service.yaml` file in your application's folder. This virtual service works as a load-balancer and configures `istio` to properly handle network traffic.
2. Add a domain to `gke-terraform/http_loadbalancer.tf` to update the SSL certificate.
3. Add an argo-cd manifest that provides argo-cd with the information on where your application lives. Each application has to live in its own namespace. Be sure to add the option `CreateNamespace=true`, so a new namespace will be created if it does not exist yet.
