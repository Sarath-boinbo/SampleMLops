# deploy-full.ps1
param(
    [string]$Tag = "latest"
)

Write-Host "=== Full Deployment Process ===" -ForegroundColor Cyan
Write-Host "Tag: $Tag" -ForegroundColor Cyan

# Step 1: Pull latest image
Write-Host "`n--- Step 1: Pulling Image ---" -ForegroundColor Cyan
& .\deploy-pull.ps1 -Tag $Tag

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Image pull failed, stopping deployment" -ForegroundColor Red
    exit 1
}

# Step 2: Deploy to Kubernetes
Write-Host "`n--- Step 2: Deploying to Kubernetes ---" -ForegroundColor Cyan
& .\deploy-k8s.ps1 -Tag $Tag

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Kubernetes deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 Full deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Application URL: http://localhost:8080" -ForegroundColor Yellow
Write-Host "📊 MLflow UI: http://$((Get-Content 'config.json' | ConvertFrom-Json).mlflowInstanceIp):5000" -ForegroundColor Yellow