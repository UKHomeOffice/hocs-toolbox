# hocs-toolbox

This image contains the abilities to access the namespace database, and also provides scripts for clearing the database, Elasticsearch, S3 buckets and SQS queues.

To Access the deployment and work on SQL Server via CLI, please follow the steps


https://hub.acp.homeoffice.gov.uk/identities 

## Set up Kube config to access acp-notprod cluster
1. Set up the cluster settings:

**_kubectl config set-cluster acp-notprod --server=https://kube-api-notprod.notprod.acp.homeoffice.gov.uk && kubectl config set clusters.acp-notprod.certificate-authority-data Lxxxxxxo=_**

2. Set up the credentials:

**_kubectl config set-credentials user@digital.homeoffice.gov.uk_acp-notprod_HOCS --token=1fxxx9_**

3. Set up the context:

**_kubectl config set-context acp-notprod_HOCS --cluster=acp-notprod --user=user@digital.homeoffice.gov.uk_acp-notprod_HOCS_**

4. Now you can access the cluster: to list the pods in the namespace

**_kubectl --context=acp-notprod_HOCS --namespace=cs-dev-migration get pods_**

Displays the hooks-migration-toolbox

NAME                                      READY   STATUS    RESTARTS   AGE
hocs-migration-toolbox-76485cf569-7xhdn   1/1     Running   0          94m

We can connect to this container by 
  **_kubectl --context=acp-notprod_HOCS --namespace=cs-dev-migration exec -it deployment/hocs-migration-toolbox -- bash_**

Once we are in the container, we can connect to the Sql Server using sqlCmd 
  **_sqlcmd -S $CMS_DB_HOSTNAME -U $CMS_USERNAME -P $CMS_PASSWORD_**

**_Create Database LaganECM_**
**_GO_**

**_CREATE LOGIN Lagan_admin WITH PASSWORD = 'Lagan_admin'_**
**_GO_**

Exit 

Now we can load schema from the container bash

**_sqlcmd -S $CMS_DB_HOSTNAME -U $CMS_USERNAME -P $CMS_PASSWORD -I LaganECM_schema.sql_**

From Sql cmd we can now 

**_Use LaganECM_**
**_Go_**

Now we can list out all the tables that are created from Schema

**_SELECT * FROM INFORMATION_SCHEMA.TABLES;_**
**_GO_**

This will show all the 590 tables and views created.
