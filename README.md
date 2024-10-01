# Terraform AKS with Azure DNS, cert-manager, nginx-ingress and workload identity

I couldn't find a good example creating a AKS cluster that could setup Azure DNS, cert-manager, nginx-ingress and workload identity. My goal was to setup cert-manager to do DNS01 challenges with Azure DNS and use the certificates to secure the nginx-ingress. I also wanted to use workload identity to allow the pods to access Azure resources without having to store credentials in the cluster. My domain provider is namecheap, so I set that up too. If you have suggestions for improvements, please let me know.

## Prerequisites

1. You need to have a domain registered with a provider that supports the DNS01 challenge. I used Namecheap.
2. You need to have an Azure subscription.
3. You need to have Terraform installed and setup with an account that has the required permissions.

## Setup

You need to create one or more .env files in the config directory with the following environment variables:

```bash
# This is the active directory group you want to be AKS admins
K8S_ADMIN_GROUP_ID=00000000-0000-0000-0000-000000000000

# This is the active directory group for your terraform accounts
TERRAFORM_GROUP_ID=00000000-0000-0000-0000-000000000000

# These are the Namecheap API keys
NAMECHEAP_API_KEY=00000000000000000000000000000000
NAMECHEAP_API_USER=YourUserName
NAMECHEAP_USER_NAME=YourUserName

# This is your Azure Container Registry ID
EXISTING_ACR_ID="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.ContainerRegistry/registries/ACR_NAME"
```

## Run

1. Run `terraform init` to download the required providers.
2. Run `terraform apply` to create the resources.

## Notes

- This will create a cluster_name.kubeconfig file in the root directory that you can use to access the cluster. You can also use the Azure CLI to access the cluster.
- I use .env files to store secret configuration and .json for non secret. The .env files are not checked into source control and the json are.
- I chose that VM size because it was cheap and you can purchase a reservation making it even cheaper.
- The web module is setup that way so you can resue it for other sites.

## TODO

- Work on a DRY app deployment to do multiple sites and services per site, including subdomains.
- CI/CD pipeline for the deployments.
- Setup job deployments.
