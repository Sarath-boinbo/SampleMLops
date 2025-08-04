# deploy-pull.ps1
param(
    [string]$Tag = "latest"
)

Write-Host "=== Pulling Latest Docker Image ===" -ForegroundColor Green

# Load configuration
if (-not (Test-Path "config.json")) {
    Write-Host "❌ config.json not found. Copy config.example.json and update it with your values." -ForegroundColor Red
    exit 1
}

$config = Get-Content "config.json" | ConvertFrom-Json
$ECR_URL = $config.ecrRepositoryUrl
$REGION = $config.region

Write-Host "ECR Repository: $ECR_URL" -ForegroundColor Yellow
Write-Host "Region: $REGION" -ForegroundColor Yellow
Write-Host "Tag: $Tag" -ForegroundColor Yellow

# Authenticate Docker to ECR
Write-Host "`nAuthenticating to ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URL

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ECR authentication failed" -ForegroundColor Red
    exit 1
}

# Pull the latest image
Write-Host "`nPulling image: ${ECR_URL}:${Tag}" -ForegroundColor Yellow
docker pull "${ECR_URL}:${Tag}"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image pulled successfully!" -ForegroundColor Green
    Write-Host "Image: ${ECR_URL}:${Tag}" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to pull image" -ForegroundColor Red
    exit 1
}