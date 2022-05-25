# hocs-toolbox

This branch is customised for the CMS data migration, it is a toolbox with Microsoft sqlcmd and the AWS CLI installed. It's main purpose is to allow the team to copy the CMS database backup file to an S3 bucket and then restore the database to the SQL Server 2016 database in the cluster.

To Access the deployment and work on SQL Server via CLI, please follow the steps


https://hub.acp.homeoffice.gov.uk/identities

## Set up Kube config to access acp-notprod cluster
1. Set up the cluster settings:
```
kubectl config set-cluster acp-notprod --server=https://kube-api-notprod.notprod.acp.homeoffice.gov.uk && kubectl config set clusters.acp-notprod.certificate-authority-data xxxxxxxxx
```

2. Set up the credentials:

```
kubectl config set-credentials user@digital.homeoffice.gov.uk_acp-notprod_HOCS --token=xxxxxx
```

3. Set up the context:

```
kubectl config set-context acp-notprod_HOCS --cluster=acp-notprod --user=user@digital.homeoffice.gov.uk_acp-notprod_HOCS
```

4. Now you can access the cluster: to list the pods in the namespace

```
kubectl --context=acp-notprod_HOCS --namespace=cs-dev-migration get pods
```

Displays the hooks-migration-toolbox

NAME                                      READY   STATUS    RESTARTS   AGE
hocs-migration-toolbox-76485cf569-7xhdn   1/1     Running   0          94m

We can connect to this container by

```
kubectl --context=acp-notprod_HOCS --namespace=cs-dev-migration exec -it deployment/hocs-migration-toolbox -- bash
```

Once we are in the container, we can connect to the Sql Server using sqlCmd

```
sqlcmd -S $CMS_DB_HOSTNAME -U $CMS_DB_USERNAME -P $CMS_DB_PASSWORD
```

Then create the LaganECM database

```
Create Database LaganECM
GO
```

Create Lagan user

```
CREATE LOGIN $CMS_LAGAN_ADMIN_USERNAME WITH PASSWORD = $CMS_LAGAN_ADMIN_PASSWORD
GO
Exit 
```
Upload the database schema from your local machine:
```console
$ kubectl cp deployment/hocs-toolbox LaganECM_schema.sql:.
Now we can load schema from the container bash

```
sqlcmd -S $CMS_DB_HOSTNAME -U $CMS_DB_USERNAME -P $CMS_DB_PASSWORD -I LaganECM_schema.sql
```

From Sql cmd we can now 

```
Use LaganECM
GO
```

Now we can list out all the tables that are created from Schema

```
SELECT * FROM INFORMATION_SCHEMA.TABLES;
GO
```

This will show all the 590 tables and views created.
