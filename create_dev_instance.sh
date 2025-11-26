#!/bin/bash

# PostgreSQL Development Instance Deployment Script
# This script deploys a PostgreSQL instance to a different namespace with separate storage

set -e  # Exit on error

# Configuration Variables
DEV_NAMESPACE="develop"
ENV_SUFFIX="-${DEV_NAMESPACE}"
DEV_IP="192.168.179.190"
DEV_PV_PATH="/data/postgresql${ENV_SUFFIX}"
SOURCE_FILE="10_working_postgres.yaml"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PostgreSQL Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Configuration:"
echo "  Namespace:        ${DEV_NAMESPACE}"
echo "  LoadBalancer IP:  ${DEV_IP}"
echo "  PV Path:          ${DEV_PV_PATH}"
echo "  Source File:      ${SOURCE_FILE}"
echo ""

# Check if source file exists
if [ ! -f "${SOURCE_FILE}" ]; then
    echo "Error: Source file ${SOURCE_FILE} not found!"
    exit 1
fi

# Create StorageClass if it doesn't exist
echo -e "${YELLOW}Checking StorageClass 'manual'...${NC}"
if kubectl get storageclass manual > /dev/null 2>&1; then
    echo "StorageClass 'manual' already exists"
else
    echo "Creating StorageClass 'manual'..."
    kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: manual
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
    echo "StorageClass 'manual' created"
fi

echo ""
# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace ${DEV_NAMESPACE}...${NC}"
if kubectl get namespace "${DEV_NAMESPACE}" > /dev/null 2>&1; then
    echo "Namespace ${DEV_NAMESPACE} already exists"
else
    kubectl create namespace "${DEV_NAMESPACE}"
    echo "Namespace ${DEV_NAMESPACE} created"
fi

echo ""
echo -e "${YELLOW}Applying PostgreSQL deployment to ${DEV_NAMESPACE} namespace...${NC}"

# Apply with sed replacements
# IMPORTANT: Order matters! Replace longer/more specific strings first
sed -e "s/namespace: postgresql/namespace: ${DEV_NAMESPACE}/g" \
    -e "s|path: /data/postgresql|path: ${DEV_PV_PATH}|g" \
    -e "s/name: postgres-volume-claim/name: postgres-volume-claim${ENV_SUFFIX}/g" \
    -e "s/claimName: postgres-volume-claim/claimName: postgres-volume-claim${ENV_SUFFIX}/g" \
    -e "s/name: postgres-volume$/name: postgres-volume${ENV_SUFFIX}/g" \
    -e "s/name: postgres-secret/name: postgres-secret${ENV_SUFFIX}/g" \
    -e "s/configMapKeyRef:/configMapKeyRef:/g" \
    -e "s/^        name: postgres-secret$/        name: postgres-secret${ENV_SUFFIX}/g" \
    -e "s/loadBalancerIP: 192.168.179.206/loadBalancerIP: ${DEV_IP}/g" \
    "${SOURCE_FILE}" | kubectl apply -f -

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Resources created in namespace: ${DEV_NAMESPACE}"
echo ""
echo "To check the deployment status:"
echo "  kubectl get all -n ${DEV_NAMESPACE}"
echo ""
echo "To check PersistentVolume:"
echo "  kubectl get pv postgres-volume${ENV_SUFFIX}"
echo ""
echo "To access PostgreSQL:"
echo "  kubectl exec -it -n ${DEV_NAMESPACE} deployment/postgres -- psql -U ps_user -d ps_db_dev"
echo ""
echo "To delete this deployment:"
echo "  kubectl delete deployment postgres -n ${DEV_NAMESPACE}"
echo "  kubectl delete pv postgres-volume${ENV_SUFFIX}"
echo ""