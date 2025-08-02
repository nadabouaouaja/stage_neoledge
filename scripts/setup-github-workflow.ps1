# Script PowerShell pour configurer les secrets GitHub Actions
# Configure automatiquement les secrets nécessaires pour le déploiement Azure

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$GitHubRepo = "nadabouaouaja/stage_neoledge"
)

Write-Host "Configuration des secrets GitHub Actions pour le deploiement Azure" -ForegroundColor Green
Write-Host "Repository: $GitHubRepo" -ForegroundColor Cyan

# 1. Verifier la connexion Azure
Write-Host "Verification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Veuillez vous connecter a Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# 2. Obtenir les informations du registre de conteneurs
Write-Host "Recuperation des informations du registre de conteneurs..." -ForegroundColor Yellow
$AcrName = "contextualimagedescriptionappacr"
$AcrCredentials = az acr credential show --name $AcrName --query "username" --output tsv
$AcrPassword = az acr credential show --name $AcrName --query "passwords[0].value" --output tsv

if (-not $AcrCredentials -or -not $AcrPassword) {
    Write-Host "ERREUR - Impossible de recuperer les credentials du registre de conteneurs" -ForegroundColor Red
    exit 1
}

Write-Host "OK - Credentials ACR recuperes" -ForegroundColor Green

# 3. Creer un service principal Azure pour GitHub Actions
Write-Host "Creation du service principal Azure..." -ForegroundColor Yellow
$SubscriptionId = az account show --query id --output tsv
$SpName = "GitHubActions-ContextualImageDescriptionApp"

# Supprimer l'ancien service principal s'il existe
az ad sp delete --id "http://$SpName" 2>$null

# Creer le nouveau service principal
$SpOutput = az ad sp create-for-rbac --name $SpName --role contributor --scopes "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName" --sdk-auth --output json | ConvertFrom-Json

if (-not $SpOutput) {
    Write-Host "ERREUR - Impossible de creer le service principal" -ForegroundColor Red
    exit 1
}

Write-Host "OK - Service principal cree" -ForegroundColor Green

# 4. Afficher les secrets a configurer
Write-Host ""
Write-Host "=== SECRETS GITHUB A CONFIGURER ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Allez dans votre repository GitHub:" -ForegroundColor Cyan
Write-Host "https://github.com/$GitHubRepo/settings/secrets/actions" -ForegroundColor White
Write-Host ""
Write-Host "Ajoutez ces secrets:" -ForegroundColor Yellow
Write-Host ""

# Secret AZURE_CREDENTIALS
Write-Host "1. AZURE_CREDENTIALS" -ForegroundColor Green
Write-Host "Valeur:" -ForegroundColor Cyan
$AzureCredentials = @{
    clientId = $SpOutput.clientId
    clientSecret = $SpOutput.clientSecret
    subscriptionId = $SpOutput.subscriptionId
    tenantId = $SpOutput.tenantId
} | ConvertTo-Json -Depth 10
Write-Host $AzureCredentials -ForegroundColor White
Write-Host ""

# Secret ACR_USERNAME
Write-Host "2. ACR_USERNAME" -ForegroundColor Green
Write-Host "Valeur: $AcrCredentials" -ForegroundColor White
Write-Host ""

# Secret ACR_PASSWORD
Write-Host "3. ACR_PASSWORD" -ForegroundColor Green
Write-Host "Valeur: $AcrPassword" -ForegroundColor White
Write-Host ""

# 5. Instructions pour configurer les secrets
Write-Host "=== INSTRUCTIONS ===" -ForegroundColor Yellow
Write-Host "1. Ouvrez votre repository GitHub dans le navigateur" -ForegroundColor White
Write-Host "2. Allez dans Settings > Secrets and variables > Actions" -ForegroundColor White
Write-Host "3. Cliquez sur 'New repository secret'" -ForegroundColor White
Write-Host "4. Ajoutez chaque secret avec son nom et sa valeur" -ForegroundColor White
Write-Host "5. Sauvegardez chaque secret" -ForegroundColor White
Write-Host ""

# 6. Tester la configuration
Write-Host "=== TEST DE LA CONFIGURATION ===" -ForegroundColor Yellow
Write-Host "Une fois les secrets configures, vous pouvez:" -ForegroundColor White
Write-Host "1. Pousser votre code vers GitHub" -ForegroundColor White
Write-Host "2. Le workflow se declenchera automatiquement" -ForegroundColor White
Write-Host "3. Surveillez le progres dans l'onglet Actions" -ForegroundColor White
Write-Host ""

Write-Host "URLs de votre application apres deploiement:" -ForegroundColor Green
Write-Host "Backend: https://contextualimagedescriptionapp-backend.azurewebsites.net" -ForegroundColor Cyan
Write-Host "Frontend: https://contextualimagedescriptionapp-frontend.azurewebsites.net" -ForegroundColor Cyan
Write-Host "AI Service: https://contextualimagedescriptionapp-ai.azurewebsites.net" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "N'oubliez pas de configurer les secrets GitHub avant de pousser votre code." -ForegroundColor Yellow 