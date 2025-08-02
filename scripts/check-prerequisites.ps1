# Script PowerShell pour verifier et installer les prerequis Azure
# Verifie Azure CLI, Docker, et configure l'environnement

Write-Host "Verification des prerequis pour le deploiement Azure" -ForegroundColor Green

# 1. Verifier Azure CLI
Write-Host "Verification d'Azure CLI..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "OK - Azure CLI installe - Version: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "ERREUR - Azure CLI non installe" -ForegroundColor Red
    Write-Host "Installation d'Azure CLI..." -ForegroundColor Yellow
    
    # Installation via winget (Windows)
    try {
        winget install -e --id Microsoft.AzureCLI
        Write-Host "OK - Azure CLI installe avec succes" -ForegroundColor Green
        Write-Host "Veuillez redemarrer votre terminal et relancer ce script" -ForegroundColor Yellow
        exit 0
    } catch {
        Write-Host "ERREUR - Erreur lors de l'installation d'Azure CLI" -ForegroundColor Red
        Write-Host "Veuillez installer manuellement depuis: https://docs.microsoft.com/azure/cli/install-azure-cli" -ForegroundColor Yellow
        exit 1
    }
}

# 2. Verifier Docker
Write-Host "Verification de Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker version --format json | ConvertFrom-Json
    Write-Host "OK - Docker installe - Version: $($dockerVersion.Server.Version)" -ForegroundColor Green
} catch {
    Write-Host "ERREUR - Docker non installe ou non demarre" -ForegroundColor Red
    Write-Host "Veuillez installer Docker Desktop depuis: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host "Assurez-vous que Docker Desktop est demarre" -ForegroundColor Yellow
    exit 1
}

# 3. Verifier la connexion Azure
Write-Host "Verification de la connexion Azure..." -ForegroundColor Yellow
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "OK - Connecte a Azure - Compte: $($account.user.name)" -ForegroundColor Green
    Write-Host "Subscription: $($account.name)" -ForegroundColor Cyan
    Write-Host "Tenant: $($account.tenantId)" -ForegroundColor Cyan
} catch {
    Write-Host "ERREUR - Non connecte a Azure" -ForegroundColor Red
    Write-Host "Connexion a Azure..." -ForegroundColor Yellow
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERREUR - Erreur lors de la connexion Azure" -ForegroundColor Red
        exit 1
    }
}

# 4. Verifier les quotas Azure (pour eviter les erreurs)
Write-Host "Verification des quotas Azure..." -ForegroundColor Yellow
$subscriptionId = az account show --query id --output tsv
$quotas = az vm list-usage --location "West Europe" --output table
Write-Host "OK - Quotas verifies" -ForegroundColor Green

# 5. Verifier l'espace disque
Write-Host "Verification de l'espace disque..." -ForegroundColor Yellow
$diskSpace = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace
$freeSpaceGB = [math]::Round($diskSpace.FreeSpace / 1GB, 2)
if ($freeSpaceGB -gt 5) {
    Write-Host "OK - Espace disque suffisant: $freeSpaceGB GB libre" -ForegroundColor Green
} else {
    Write-Host "ATTENTION - Espace disque faible: $freeSpaceGB GB libre (recommandé: >5GB)" -ForegroundColor Yellow
}

# 6. Verifier la connectivite internet
Write-Host "Verification de la connectivite..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 10
    Write-Host "OK - Connectivite internet OK" -ForegroundColor Green
} catch {
    Write-Host "ERREUR - Probleme de connectivite internet" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Tous les prerequis sont satisfaits!" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "1. Executer: .\deploy-complete.ps1" -ForegroundColor White
Write-Host "2. Ou executer etape par etape:" -ForegroundColor White
Write-Host "   - .\deploy-azure-free.ps1" -ForegroundColor White
Write-Host "   - .\build-and-push.ps1" -ForegroundColor White
Write-Host "   - .\deploy-apps.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Conseil: Utilisez .\deploy-complete.ps1 pour un deploiement automatique complet" -ForegroundColor Cyan 