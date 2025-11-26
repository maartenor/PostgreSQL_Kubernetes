Simple collection of YAML files to start a PostgreSQL database on a cluster.
Using minikube as a local cluster for development purposes.

Update postgres-configmap.yaml to define initial database name, username and password.

# Creating password to add to Secret
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
  password: SihIQVtHdWlWWStecCg=
```