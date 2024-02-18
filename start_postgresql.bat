@REM https://www.digitalocean.com/community/tutorials/how-to-deploy-postgres-to-kubernetes-cluster
minikube start --no-vtx-check

echo "minikube dashboard"
echo "To start local dashboard service."
echo ""

echo "Starting creation..."
kubectl apply -f postgres-configmap.yaml
kubectl get configmap
kubectl apply -f psql-pv.yaml
kubectl apply -f psql-claim.yaml
kubectl get pv
kubectl get pvc
kubectl apply -f ps-deployment.yaml
kubectl get deployments
kubectl get pods
echo "Waiting for pods to get running..."
timeout 50
kubectl get pods
echo ""

echo "Starting Service creation..."
kubectl apply -f ps-service.yaml
kubectl get svc
echo ""
echo "Starting port-forwarding"
cmd.exe /c start /b kubectl port-forward service/postgres 5432:5432


echo "kubectl get pods --no-headers -o custom-columns="":metadata.name"" | Out-String -Stream | Select-String -Pattern ""postgres-"" | select -first 1"
kubectl exec -it (kubectl get pods  --no-headers -o custom-columns=":metadata.name" | Out-String -Stream | Select-String -Pattern "postgres-" | select -first 1) -- psql -h localhost -U ps_user --password -p 5432 ps_db
@REM echo ""
@REM echo "# Backup database:"
@REM echo "kubectl exec -it postgres-665b7554dc-cddgq -- pg_dump -U ps_user -d ps_db > db_backup.sql"
@REM echo ""
@REM echo "kubectl get pods"
@REM echo "kubectl cp db_backup.sql postgres-665b7554dc-cddgq:/tmp/db_backup.sql"
@REM echo "kubectl exec -it postgres-665b7554dc-cddgq -- /bin/bash"
@REM echo "psql -U ps_user -d ps_db -f /tmp/db_backup.sql"