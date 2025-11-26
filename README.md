### About
Simple collection of YAML files to start a PostgreSQL database on a cluster.
Using minikube as a local cluster for development purposes.

Update postgres-configmap.yaml to define initial database name, username and password.

### Deploy and start
To deploy the configuration and start the PostgreSQL database and services, run:
- `start_10_working_postgresql.sh` (Linux)
- `start_10_working_postgresql.bat` (Windows)

Deploy on kubernetes cluster 
`kubectl apply -f ./10_working_postgres.yaml`

### [Improvement] Creating password to add to Secret
```bash
# Linux
echo -n "your-password" | base64
```

```Powershell
# Windows Powershell 
$YourPassword = "your-password"
$Base64String = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($YourPassword))
Write-Host $Base64String
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: postgres
type: Opaque
data:
  password: SihIQVtHdWlWWStecCg= # base64 encoded value of "your-password"
```

### Test persisting volume
In order to test the persisting volume of actually keeping data retained:
1. Create database and records, by executing `create_dummy_databaset.sql`;
2. Delete deployment `kubectl apply -f ./10_working_postgres.yaml`;
3. Restart the node mentioned under _spec.template.spec.nodeSelector_ of the Deployment section in the yaml file;
4. (Re-)create deployment `kubectl apply -f ./10_working_postgres.yaml`;
5. Wait for approx 3 minutes after image got pulled, for init-postgres pod to become ready;
6. Connect to database using credentials in the ConfigMap section under the _postgres-secret_;
7. Select the database and table, check if records remained persitent as created by .sql under step 2.