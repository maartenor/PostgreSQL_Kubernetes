@echo off
REM PostgreSQL Development Instance Deployment Script (Windows)
REM This script deploys a PostgreSQL instance to a different namespace with separate storage

setlocal enabledelayedexpansion

REM Configuration Variables
set DEV_NAMESPACE=develop
set ENV_SUFFIX=-%DEV_NAMESPACE%
set DEV_IP=192.168.179.190
set DEV_PV_PATH=/data/postgresql%ENV_SUFFIX%
set SOURCE_FILE=10_working_postgres.yaml

echo ========================================
echo PostgreSQL Deployment Script
echo ========================================
echo.
echo Configuration:
echo   Namespace:        %DEV_NAMESPACE%
echo   LoadBalancer IP:  %DEV_IP%
echo   PV Path:          %DEV_PV_PATH%
echo   Source File:      %SOURCE_FILE%
echo.

REM Check if source file exists
if not exist "%SOURCE_FILE%" (
    echo Error: Source file %SOURCE_FILE% not found!
    exit /b 1
)

REM Create StorageClass if it doesn't exist
echo Checking StorageClass 'manual'...
kubectl get storageclass manual >nul 2>&1
if !errorlevel! equ 0 (
    echo StorageClass 'manual' already exists
) else (
    echo Creating StorageClass 'manual'...
    echo apiVersion: storage.k8s.io/v1 > storageclass-temp.yaml
    echo kind: StorageClass >> storageclass-temp.yaml
    echo metadata: >> storageclass-temp.yaml
    echo   name: manual >> storageclass-temp.yaml
    echo provisioner: kubernetes.io/no-provisioner >> storageclass-temp.yaml
    echo volumeBindingMode: WaitForFirstConsumer >> storageclass-temp.yaml
    kubectl apply -f storageclass-temp.yaml
    del storageclass-temp.yaml
    echo StorageClass 'manual' created
)

echo.
REM Create namespace if it doesn't exist
echo Creating namespace %DEV_NAMESPACE%...
kubectl get namespace %DEV_NAMESPACE% >nul 2>&1
if !errorlevel! equ 0 (
    echo Namespace %DEV_NAMESPACE% already exists
) else (
    kubectl create namespace %DEV_NAMESPACE%
    echo Namespace %DEV_NAMESPACE% created
)

echo.
echo Applying PostgreSQL deployment to %DEV_NAMESPACE% namespace...

REM Apply with sed replacements (requires Git Bash or WSL sed)
REM IMPORTANT: Order matters! Replace longer/more specific strings first
sed -e "s/namespace: postgresql/namespace: %DEV_NAMESPACE%/g" ^
    -e "s|path: /data/postgresql|path: %DEV_PV_PATH%|g" ^
    -e "s/name: postgres-volume-claim/name: postgres-volume-claim%ENV_SUFFIX%/g" ^
    -e "s/claimName: postgres-volume-claim/claimName: postgres-volume-claim%ENV_SUFFIX%/g" ^
    -e "s/name: postgres-volume$/name: postgres-volume%ENV_SUFFIX%/g" ^
    -e "s/name: postgres-secret/name: postgres-secret%ENV_SUFFIX%/g" ^
    -e "s/loadBalancerIP: 192.168.179.206/loadBalancerIP: %DEV_IP%/g" ^
    "%SOURCE_FILE%" | kubectl apply -f -

if !errorlevel! neq 0 (
    echo.
    echo Error: Deployment failed!
    exit /b 1
)

echo.
echo ========================================
echo Deployment completed successfully!
echo ========================================
echo.
echo Resources created in namespace: %DEV_NAMESPACE%
echo.
echo To check the deployment status:
echo   kubectl get all -n %DEV_NAMESPACE%
echo.
echo To check PersistentVolume:
echo   kubectl get pv postgres-volume%ENV_SUFFIX%
echo.
echo To access PostgreSQL:
echo   kubectl exec -it -n %DEV_NAMESPACE% deployment/postgres -- psql -U ps_user -d ps_db_dev
echo.
echo To delete this deployment:
echo   kubectl delete namespace %DEV_NAMESPACE%
echo   kubectl delete pv postgres-volume%ENV_SUFFIX%
echo.

endlocal
