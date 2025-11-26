### About
Simple collection of YAML files to start a PostgreSQL database on a cluster.
Using minikube as a local cluster for development purposes.

Update postgres-configmap.yaml to define initial database name, username and password.

### Requirements
- minikube installed (Windows)
- (if needed) Any Kubernetes cluster running
- (if needed) Argo CD application running 

### Deploy and start
To deploy the configuration and start the PostgreSQL database and services, run:
- `start_10_working_postgresql.sh` (Linux)
- `start_10_working_postgresql.bat` (Windows)

Deploy on kubernetes cluster 
`kubectl apply -f ./10_working_postgres.yaml`

Deploy to ArgoCD via yaml files
`kubectl apply -f postgresql_argocd_application.yaml`

Deploy via Helm Chart to ArgoCD
`kubectl apply -f argocd-helm-application.yaml`

### Test persisting volume
In order to test the persisting volume of actually keeping data retained:
1. Create database and records, by executing `create_dummy_databaset.sql`;
2. Delete deployment `kubectl apply -f ./10_working_postgres.yaml`;
3. Restart the node mentioned under _spec.template.spec.nodeSelector_ of the Deployment section in the yaml file;
4. (Re-)create deployment `kubectl apply -f ./10_working_postgres.yaml`;
5. Wait for approx 3 minutes after image got pulled, for init-postgres pod to become ready;
6. Connect to database using credentials in the ConfigMap section under the _postgres-secret_;
7. Select the database and table, check if records remained persitent as created by .sql under step 2.

### Create develop/test/acceptance instance
To Customize for Different Environments:
1. Adapt script variables (see below);
2. Run ```./create_dev_instance.sh ``` (linux) or ```create_dev_instance.bat``` (Windows)

Just edit the variables at the top of the script:
```bash
# For staging environment
DEV_NAMESPACE="staging"
ENV_POSTFIX="-${DEV_NAMESPACE}"
DEV_IP="192.168.179.208"
DEV_PV_PATH="/data/postgresql${ENV_POSTFIX}"
```

What Gets Modified:
- ✅ Namespace: postgresql → develop
- ✅ PV name: postgres-volume → postgres-volume-develop
- ✅ PVC name: postgres-volume-claim → postgres-volume-claim-develop
- ✅ ConfigMap name: postgres-secret → postgres-secret-develop
- ✅ PV hostPath: /data/postgresql → /data/postgresql-develop
- ✅ LoadBalancer IP: 192.168.179.206 → 192.168.179.190

This keeps your production (postgresql namespace) and development (develop namespace) completely isolated with separate storage!

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

### [Improvement] Prometheus exporter for PostgreSQL
By default, a prometheus exporter for PostgreSQL as a sidecar is enabled 
- in the 98_values.yaml file (for Helm deployments) via `exporter.enabled: True`
- the deployment file via Helm chart via the annotations `prometheus.io/scrape: "true"` etc
- and the regular direct deployment based on the Git repo it is enabled by default. And can be disabled by commenting out the 1) annotations and 2) the export container `postgres-exporter`

Add to prometheus values.yaml under scrapeconfig:
```yaml
# Add to prometheus configuration
# Edit /etc/prometheus/prometheus.yml and add the following scrape config
scrape_configs:
  - job_name: 'prom-postgres-kubernetes'
    static_configs:
      - targets: ['192.168.179.62:9187']
        # labels:
        #   instance: 'postgres-rpicm4-2'
        #   node: 'rpicm4-2'

# Use a web browser or curl to verify metrics are being collected
curl http://localhost:9187/metrics | grep ^pg_
```