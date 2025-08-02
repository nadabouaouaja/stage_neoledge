# Script PowerShell pour configurer les secrets GitHub Actions
# Nécessaire pour le déploiement Azure automatique

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$AcrName = "contextualimagedescriptionappacr"
)

Write-Host "🔐 Configuration des secrets GitHub Actions" -ForegroundColor Green

# 1. Vérifier la connexion Azure
Write-Host "📋 Vérification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Veuillez vous connecter à Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# 2. Créer un service principal pour GitHub Actions
Write-Host "🔑 Création du service principal..." -ForegroundColor Yellow
$ServicePrincipalName = "github-actions-sp"
$ServicePrincipal = az ad sp create-for-rbac --name $ServicePrincipalName --role contributor --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName --sdk-auth

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Service principal créé" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la création du service principal" -ForegroundColor Red
    exit 1
}

# 3. Obtenir les credentials ACR
Write-Host "🔑 Récupération des credentials ACR..." -ForegroundColor Yellow
$AcrCredentials = az acr credential show --name $AcrName --query "username" --output tsv
$AcrPassword = az acr credential show --name $AcrName --query "passwords[0].value" --output tsv

# 4. Afficher les secrets à configurer
Write-Host "📋 Secrets à configurer dans GitHub:" -ForegroundColor Green
Write-Host ""
Write-Host "1. AZURE_CREDENTIALS:" -ForegroundColor Cyan
Write-Host $ServicePrincipal -ForegroundColor Yellow
Write-Host ""
Write-Host "2. REGISTRY_USERNAME:" -ForegroundColor Cyan
Write-Host $AcrCredentials -ForegroundColor Yellow
Write-Host ""
Write-Host "3. REGISTRY_PASSWORD:" -ForegroundColor Cyan
Write-Host $AcrPassword -ForegroundColor Yellow
Write-Host ""

# 5. Instructions pour configurer les secrets
Write-Host "📝 Instructions pour configurer les secrets:" -ForegroundColor Green
Write-Host "1. Allez sur votre repository GitHub" -ForegroundColor White
Write-Host "2. Cliquez sur Settings > Secrets and variables > Actions" -ForegroundColor White
Write-Host "3. Cliquez sur 'New repository secret'" -ForegroundColor White
Write-Host "4. Ajoutez les 3 secrets ci-dessus" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Configuration terminée!" -ForegroundColor Green
Write-Host "Une fois les secrets configurés, le workflow GitHub Actions fonctionnera automatiquement." -ForegroundColor Yellow 