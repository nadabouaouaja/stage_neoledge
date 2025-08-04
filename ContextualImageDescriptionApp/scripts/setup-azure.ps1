# Script PowerShell pour configurer Azure
# Exécuter en tant qu'administrateur

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$Location = "West Europe",
    [string]$SqlPassword = "YourStrong@Passw0rd123!"
)

Write-Host "🚀 Configuration Azure pour ContextualImageDescriptionApp" -ForegroundColor Green

# 1. Vérifier la connexion Azure
Write-Host "📋 Vérification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Veuillez vous connecter à Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# 2. Créer le groupe de ressources
Write-Host "📦 Création du groupe de ressources..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Groupe de ressources créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le groupe de ressources existe déjà" -ForegroundColor Yellow
}

# 3. Créer le registre de conteneurs
Write-Host "🐳 Création du registre de conteneurs..." -ForegroundColor Yellow
$AcrName = "contextualimagedescriptionappacr"
az acr create --resource-group $ResourceGroupName --name $AcrName --sku Basic
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Registre de conteneurs créé" -ForegroundColor Green
    az acr update -n $AcrName --admin-enabled true
} else {
    Write-Host "⚠️  Le registre de conteneurs existe déjà" -ForegroundColor Yellow
}

# 4. Créer le serveur SQL
Write-Host "🗄️  Création du serveur SQL..." -ForegroundColor Yellow
$SqlServerName = "contextualimagedescriptionapp-sql"
az sql server create --name $SqlServerName --resource-group $ResourceGroupName --location $Location --admin-user sqladmin --admin-password $SqlPassword
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Serveur SQL créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le serveur SQL existe déjà" -ForegroundColor Yellow
}

# 5. Créer la base de données
Write-Host "📊 Création de la base de données..." -ForegroundColor Yellow
az sql db create --resource-group $ResourceGroupName --server $SqlServerName --name IntelliDocDb --service-objective Basic
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Base de données créée" -ForegroundColor Green
} else {
    Write-Host "⚠️  La base de données existe déjà" -ForegroundColor Yellow
}

# 6. Configurer le pare-feu SQL
Write-Host "🔥 Configuration du pare-feu SQL..." -ForegroundColor Yellow
az sql server firewall-rule create --resource-group $ResourceGroupName --server $SqlServerName --name AllowAll --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
Write-Host "✅ Pare-feu SQL configuré" -ForegroundColor Green

# 7. Créer le plan App Service
Write-Host "🌐 Création du plan App Service..." -ForegroundColor Yellow
$AppServicePlanName = "ContextualImageDescriptionApp-Plan"
az appservice plan create --name $AppServicePlanName --resource-group $ResourceGroupName --sku B1 --is-linux
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Plan App Service créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le plan App Service existe déjà" -ForegroundColor Yellow
}

# 8. Créer l'App Service pour le backend
Write-Host "🔧 Création de l'App Service backend..." -ForegroundColor Yellow
$BackendAppName = "contextualimagedescriptionapp-backend"
az webapp create --resource-group $ResourceGroupName --plan $AppServicePlanName --name $BackendAppName --deployment-local-git
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service backend créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  L'App Service backend existe déjà" -ForegroundColor Yellow
}

# 9. Afficher les informations de connexion
Write-Host "📋 Informations de connexion:" -ForegroundColor Green
Write-Host "Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Serveur SQL: $SqlServerName.database.windows.net" -ForegroundColor Cyan
Write-Host "Base de données: IntelliDocDb" -ForegroundColor Cyan
Write-Host "App Service backend: $BackendAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host "Registre de conteneurs: $AcrName.azurecr.io" -ForegroundColor Cyan

# 10. Obtenir les credentials ACR
Write-Host "🔑 Credentials du registre de conteneurs:" -ForegroundColor Yellow
az acr credential show --name $AcrName

Write-Host "🎉 Configuration Azure terminée!" -ForegroundColor Green
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Créer un repository GitHub" -ForegroundColor White
Write-Host "2. Configurer les secrets GitHub" -ForegroundColor White
Write-Host "3. Pousser le code et déployer" -ForegroundColor White 