#!/bin/bash

# Start Minikube
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
sleep 50
kubectl get pods
echo ""

echo "Starting Service creation..."
kubectl apply -f ps-service.yaml
kubectl get svc
echo ""
echo "Starting port-forwarding"
kubectl port-forward service/postgres 5432:5432 &

echo "Waiting for port-forwarding to start..."
sleep 5

# Get the name of the first pod with the pattern "postgres-"
POD_NAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep "postgres-" | head -n 1)

# Connect to PostgreSQL using psql
kubectl exec -it "$POD_NAME" -- psql -h localhost -U ps_user --password -p 5432 ps_db

# Uncomment the following lines for backup (if needed)
# echo ""
# echo "# Backup database:"
# echo "kubectl exec -it $POD_NAME -- pg_dump -U ps_user -d ps_db > db_backup.sql"
# echo ""
# echo "kubectl get pods"
# echo "kubectl cp db_backup.sql $POD_NAME:/tmp/db_backup.sql"
# echo "kubectl exec -it $POD_NAME -- /bin/bash"
# echo "psql -U ps_user -d ps_db -f /tmp/db_backup.sql"
