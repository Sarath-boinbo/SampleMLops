# deploy-k8s.ps1
param(
    [string]$Tag = "latest"
)

Write-Host "=== Deploying to Local Kubernetes ===" -ForegroundColor Green

# Load configuration
if (-not (Test-Path "config.json")) {
    Write-Host "❌ config.json not found. Copy config.example.json and update it with your values." -ForegroundColor Red
    exit 1
}

$config = Get-Content "config.json" | ConvertFrom-Json
$ECR_URL = $config.ecrRepositoryUrl

Write-Host "ECR Repository: $ECR_URL" -ForegroundColor Yellow
Write-Host "Tag: $Tag" -ForegroundColor Yellow

# Check if kubectl is working
Write-Host "`nChecking Kubernetes connection..." -ForegroundColor Yellow
kubectl get nodes

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cannot connect to Kubernetes cluster" -ForegroundColor Red
    Write-Host "Make sure Docker Desktop Kubernetes is enabled or minikube is running" -ForegroundColor Yellow
    exit 1
}

# Check if k8s directory exists
if (-not (Test-Path "k8s")) {
    Write-Host "❌ k8s directory not found. Create Kubernetes manifests first." -ForegroundColor Red
    exit 1
}

# Apply Kubernetes manifests
Write-Host "`nApplying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f k8s/

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to apply Kubernetes manifests" -ForegroundColor Red
    exit 1
}

# Update deployment with new image
Write-Host "`nUpdating deployment with image: ${ECR_URL}:${Tag}" -ForegroundColor Yellow
kubectl set image deployment/churn-prediction-app churn-prediction-app="${ECR_URL}:${Tag}"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to update deployment" -ForegroundColor Red
    exit 1
}

# Wait for rollout to complete
Write-Host "`nWaiting for deployment to complete..." -ForegroundColor Yellow
kubectl rollout status deployment/churn-prediction-app --timeout=300s

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment rollout failed or timed out" -ForegroundColor Red
    exit 1
}

# Show deployment status
Write-Host "`n=== Deployment Status ===" -ForegroundColor Green
kubectl get pods -l app=churn-prediction-app
kubectl get services churn-prediction-service

Write-Host "`n✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "Your application should be accessible at: http://localhost:8080" -ForegroundColor Yellow