# Database CRD

This document explains how to deploy Azure SQL databases with Platform Data
Pilot by using Kubernetes custom resources (CRDs).

## How to deploy

1. Create a database CRD file using the specification below for each
  environment that needs the database.
2. Update the existing CD pipelines to apply the environment-specific CRD to
  each Kubernetes context. For example, in DEV:
  `kubectl apply -n platform-data-pilot -f dev-database-crd.yaml`.
3. Platform Data Pilot reads the CRD and creates or updates the database in
  the target environment.

## Important notes

1. Platform Data Pilot does not delete databases. Contact the Platform Team for
  help removing a database.
2. Reapplying an unchanged database CRD does not trigger a database deployment
  or update. Changes to supported fields, such as `spec.maxSizeGB`, are
  applied.
3. Platform Data Pilot only consumes CRDs applied to each environment's North
  Europe Kubernetes context. Applying them to West Europe has no effect.

## Sample database CRD

```yaml
apiVersion: devops.uniphar.ie/v1
kind: PlatformDataPilotSqlDatabase
metadata:
  name: platform-data-pilot-integration
  namespace: platform-data-pilot
spec:
  maxSizeGB: 40
  access:
    workloadIdentity:
      name: compute-aks-platform-data-pilot-dev-k8s-sa
      namespace: platform-data-pilot
    entraIdGroup:
      name: DevOps High-RoleAssignable
```

## What each property means

### `apiVersion: devops.uniphar.ie/v1`

The Kubernetes API group and version for this custom resource.

Platform Data Pilot expects the database CRD under the `devops.uniphar.ie`
group and `v1` version.

### `kind: PlatformDataPilotSqlDatabase`

The type of custom resource.

Platform Data Pilot watches this CRD kind as the source of database
provisioning requests.

### `metadata.name: platform-data-pilot-integration`

This is the Kubernetes object name.

Platform Data Pilot uses `metadata.name` as the Azure SQL database name. In this
example, the database to be created or updated is
`platform-data-pilot-integration`.

### `metadata.namespace: platform-data-pilot`

This is the Kubernetes namespace where the CRD exists.

Platform Data Pilot uses this value to resolve where the database should be
provisioned. It maps the namespace to:

- SQL Server
- Elastic Pool
- Failover Group

using the mapping CRD.

This value is not the SQL database schema or any Azure SQL namespace concept.

See the currently deployed
[environment mappings](https://github.com/Uniphar/platform-data-pilot/tree/main/mappings).

### `spec.maxSizeGB: 40`

The requested maximum database size in GB.

Platform Data Pilot converts this value to Azure SQL `MaxSizeBytes` and uses it
when creating or updating the database.

If the CRD is updated later with a different value, Platform Data Pilot will
upsert the database with the new size.

### `spec.access`

Container for access-related configuration.

At present, Platform Data Pilot uses this section to determine which
Kubernetes workload identity should become the managed database owner.

### `spec.access.workloadIdentity.name: compute-aks-platform-data-pilot-dev-k8s-sa`

The Kubernetes ServiceAccount name used to identify the workload identity.

Platform Data Pilot reads that ServiceAccount from Kubernetes and expects it to
contain the annotation `azure.workload.identity/client-id`.

That client ID is then resolved to an Entra service principal.

### `spec.access.workloadIdentity.namespace: platform-data-pilot`

The Kubernetes namespace containing the ServiceAccount.

Platform Data Pilot combines:

- `spec.access.workloadIdentity.name`
- `spec.access.workloadIdentity.namespace`

to read the ServiceAccount and resolve its Entra identity.

### `spec.access.entraIdGroup.name: DevOps High-RoleAssignable`

The name of the Entra ID group to grant `db_owner` access to the database.

> **Important note**:
> The Entra ID group must be a security group.

## What Platform Data Pilot does with `workloadIdentity`

After the database is provisioned, Platform Data Pilot:

1. Reads the Kubernetes ServiceAccount identified by:
   - `spec.access.workloadIdentity.name`
   - `spec.access.workloadIdentity.namespace`
2. Extracts the annotation `azure.workload.identity/client-id`.
3. Resolves that client ID to an Entra service principal display name.
4. Connects to the Azure SQL database using Azure AD authentication.
5. Ensures that principal exists as an external SQL user.
6. Ensures that principal is a member of `db_owner`.
7. Removes any other previously Platform Data Pilot managed owners.
8. Tags the managed owner with the extended property `platformdatapilot.managed`.

This ensures that Platform Data Pilot manages the configured workload identity
as a database owner.

## What Platform Data Pilot does with `entraIdGroup`

After resolving the workload identity, Platform Data Pilot handles the
configured Entra ID group as follows:

1. Queries Microsoft Graph to verify that exactly one group matches
  `spec.access.entraIdGroup.name`. If no group or multiple groups with that
  name are found, Platform Data Pilot does not proceed with granting access.
2. Connects to the Azure SQL database using Azure AD authentication.
3. Ensures that principal exists as an external SQL user.
4. Ensures that principal is a member of `db_owner`.
5. Removes any other previously Platform Data Pilot managed owners.
6. Tags the managed owner with the extended property
    `platformdatapilot.managed.group`.
