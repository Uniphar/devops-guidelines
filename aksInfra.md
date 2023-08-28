# Access to Uniphar AKS infrastructure/applications

This document covers details of how to access Uniphar AKS infrastructure and
 applications running on it. It is intended for developers and support staff
 who need to access the infrastructure and applications running on it. It is
 not intended for end users of the applications.

## Login to AKS cluster

When provisioning access to AKS, we aim to provide minimum permissions
required to perform the task at hand. This is especially the case when
provisioning access to external users. This means that the user will not have
access to all namespaces in the cluster.

Each business/technical domain is provisioned with a separate namespace.
This namespace is then used to deploy applications pertaining to that
domain and therefore logically servers as a boundary for granting/limiting
access.

Uniphar AKS clusters use Azure AD RBAC authentication models. Azure provides
builtin roles that we can assign to AD groups that contain users pertaining
to a particular business domain and/or supplier.

We also consider environments when provisioning access. For example, a user
may have access to a namespace in the dev or test environment but not in
the prod environment. Prod access could be considered on a temporary basis
when investigating specific issues.

The roles we are utilising are
- **Azure Kubernetes Service RBAC Admin**- this role lets you manage all
resources under cluster/namespace, except update or delete resource quotas
and namespaces.
- **Azure Kubernetes Service Cluster User Role** - this role allows read-only
access to core cluster (for visibility in the portal) and log in to the cluster
- **Log Analytics Reader** - allows read/query access to dedicated environmental
log analytics workspaces

## AKS infrastructure

Our AKS infrastructure is provisioned in the following way:

each environment contains of two regions - north europe and west europe.
This may change.

We also use specific naming convention for AKS clusters. The template for
the name is

```bash
compute-aks-REGION-ENV-k8s
```

**REGION** token is the abbreviated region long name. For example, **northeurope**
is **ne** and **westeurope** is **we**.

**ENV** designates the environment. We recognize, **dev**, **test** and **prod**
respectively for development, test and production environments.

An example therefore for north europe development environment cluster is
therefore

*compute-aks-ne-dev-k8s*

These clusters are located in the Azure Resource group with the naming
convention of

```bash
compute-REGION-ENV
```

REGION and ENV tokens are the same as above. An example for north europe
development environment resource group is therefore

*compute-ne-dev*

All these clusters including their resource groups are visible to you in
Azure portal as well.

## Client machine setup

Several tools are needed to access the cluster/Azure. These are:
 - Azure CLI - [windows installer](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
 - kubectl - [installer](https://kubernetes.io/docs/tasks/tools/)

Please use your favorite tooling to install these (e.g. chocolatey, scoop, etc)
or use the links supplied in the list.

We assume you have been provided with uniphar account and it is fully set up
including MFA.

### Login to Azure

Please use the following command to login to Azure. This will open a browser
window and ask you to login to Azure. Please use your uniphar account.

```bash
az login
```

Then select subscription for dev and test environments.

```bash
az account set --subscription {subscriptionName}
```

*{subscriptionName}* is the name of the subscription you want to use. For
**dev** and **test** environment, this is *uniphar-dev*, **production** is *uniphar-prod*.

To access Azure portal, browse to https://portal.azure.com and log in with
your uniphar account.

### Kubernetes login

Once authenticated to Azure, we can now login to the cluster. We will use the
following command to do so - the reference

```bash
az aks get-credentials --resource-group {resourceGroupName} --name {clusterName}
```

so an example is for north europe development environment cluster is
therefore (this uses abbreviated parameter names)

*az aks get-credentials -n compute-aks-ne-dev-k8s -g compute-ne-dev*

This projects cluster config into kube config file and thus enables
standard K8 tooling such as kubectl. Its documentation is located
[here](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).
With kubectl, you can perform wide range of actions against AKS cluster
including creating/deleting deployments, accessing pod logs, port-forwarding
to a pod etc. Same applies to helm tooling - e.g. running helm charts against the cluster.

#### kubelogin

With additional tooling provided by MS, you can project your current az
cli token into kube config file and access the cluster without having to re-login.

The specific documentation - usage-  is located [here](https://azure.github.io/kubelogin/concepts/login-modes/azurecli.html#usage-examples).
Kubelogin is available for install - please follow the instructions
[here](https://azure.github.io/kubelogin/install.html). 

## Ingress

If your application is externally visible, you can utilise standard
AKS ingress resource. Our clusters use Azure application gateway
addon to expose specific ingress paths and manage service selector
mappings to dynamically allocated pods (and their IPs). Application
Gateway fronts a single region. Azure FrontDoor sits in front of
regional application gateways and provides global load balancing
and failover.

So the flow is as follows:

**Client**-->**FrontDoor**-->**Application Gateway**-->**Ingress Controller**-->**Service**-->**Pod**

An example of Application Gateway ingress resource is located [here](https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml).

We recommend each application/domain to reserve its own path prefix and
expose the application under it. This provides clear segmentation between
applications and allows for easy management of ingress rules. An example
may be */ABCApp/**. Anything below the /ABCApp is accessible by your
application and its ingress definition.

We terminate SSL at the FrontDoor level.  At pod level, the app is therefore
accessible via HTTP but any external access is expected via FrontDoor.

### DNS

We maintain certain DNS zones per environment so thar your ingress is provided
under clear DNS backed URLs. With these DNS zones, we recommend using host name
based ingress rules.

For general access, we use the following DNS zones:
 - api.dev.uniphar.ie
 - api.test.uniphar.ie
 - api.uniphar.ie

For specific needs, we can create additional DNS zones. Please contact us
for more information.

An example of hostname ingress rule

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aspnetapp
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
spec:
  rules:
  - host: api.dev.uniphar.ie
    http:
      paths:
      - path: /aspnetapp/*
        backend:
          service:
            name: aspnetapp
            port:
              number: 8080
        pathType: Prefix
```
