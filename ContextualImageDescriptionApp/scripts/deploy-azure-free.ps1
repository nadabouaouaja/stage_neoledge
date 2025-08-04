# Script PowerShell pour déploiement gratuit Azure
# Optimisé pour Azure for Students

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$Location = "West Europe",
    [string]$SqlPassword = "YourStrong@Passw0rd123!"
)

Write-Host "🚀 Déploiement gratuit Azure pour ContextualImageDescriptionApp" -ForegroundColor Green

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

# 3. Créer le registre de conteneurs (gratuit)
Write-Host "🐳 Création du registre de conteneurs gratuit..." -ForegroundColor Yellow
$AcrName = "contextualimagedescriptionappacr"
az acr create --resource-group $ResourceGroupName --name $AcrName --sku Basic --admin-enabled true
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Registre de conteneurs créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le registre de conteneurs existe déjà" -ForegroundColor Yellow
}

# 4. Créer le serveur SQL (gratuit - 32MB)
Write-Host "🗄️  Création du serveur SQL gratuit..." -ForegroundColor Yellow
$SqlServerName = "contextualimagedescriptionapp-sql"
az sql server create --name $SqlServerName --resource-group $ResourceGroupName --location $Location --admin-user sqladmin --admin-password $SqlPassword
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Serveur SQL créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le serveur SQL existe déjà" -ForegroundColor Yellow
}

# 5. Créer la base de données (gratuit - 32MB)
Write-Host "📊 Création de la base de données gratuite..." -ForegroundColor Yellow
az sql db create --resource-group $ResourceGroupName --server $SqlServerName --name IntelliDocDb --service-objective Basic --max-size 32MB
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Base de données créée" -ForegroundColor Green
} else {
    Write-Host "⚠️  La base de données existe déjà" -ForegroundColor Yellow
}

# 6. Configurer le pare-feu SQL
Write-Host "🔥 Configuration du pare-feu SQL..." -ForegroundColor Yellow
az sql server firewall-rule create --resource-group $ResourceGroupName --server $SqlServerName --name AllowAll --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
Write-Host "✅ Pare-feu SQL configuré" -ForegroundColor Green

# 7. Créer le plan App Service (gratuit - F1)
Write-Host "🌐 Création du plan App Service gratuit..." -ForegroundColor Yellow
$AppServicePlanName = "ContextualImageDescriptionApp-Plan"
az appservice plan create --name $AppServicePlanName --resource-group $ResourceGroupName --sku F1 --is-linux
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Plan App Service gratuit créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le plan App Service existe déjà" -ForegroundColor Yellow
}

# 8. Créer l'App Service pour le backend
Write-Host "🔧 Création de l'App Service backend..." -ForegroundColor Yellow
$BackendAppName = "contextualimagedescriptionapp-backend"
az webapp create --resource-group $ResourceGroupName --plan $AppServicePlanName --name $BackendAppName --deployment-local-git --runtime "DOTNETCORE:6.0"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service backend créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  L'App Service backend existe déjà" -ForegroundColor Yellow
}

# 9. Créer l'App Service pour le frontend
Write-Host "🎨 Création de l'App Service frontend..." -ForegroundColor Yellow
$FrontendAppName = "contextualimagedescriptionapp-frontend"
az webapp create --resource-group $ResourceGroupName --plan $AppServicePlanName --name $FrontendAppName --deployment-local-git --runtime "NODE:18-lts"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service frontend créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  L'App Service frontend existe déjà" -ForegroundColor Yellow
}

# 10. Créer l'App Service pour le service AI
Write-Host "🤖 Création de l'App Service AI service..." -ForegroundColor Yellow
$AiAppName = "contextualimagedescriptionapp-ai"
az webapp create --resource-group $ResourceGroupName --plan $AppServicePlanName --name $AiAppName --deployment-local-git --runtime "PYTHON:3.9"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service AI service créé" -ForegroundColor Green
} else {
    Write-Host "⚠️  L'App Service AI service existe déjà" -ForegroundColor Yellow
}

# 11. Configurer les variables d'environnement
Write-Host "⚙️  Configuration des variables d'environnement..." -ForegroundColor Yellow

# Variables pour le backend
$BackendConnectionString = "Server=tcp:$SqlServerName.database.windows.net,1433;Initial Catalog=IntelliDocDb;Persist Security Info=False;User ID=sqladmin;Password=$SqlPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az webapp config appsettings set --resource-group $ResourceGroupName --name $BackendAppName --settings `
    "ConnectionStrings__DefaultConnection=$BackendConnectionString" `
    "ASPNETCORE_ENVIRONMENT=Production" `
    "WEBSITES_PORT=8080"

# Variables pour le frontend
az webapp config appsettings set --resource-group $ResourceGroupName --name $FrontendAppName --settings `
    "NODE_ENV=production" `
    "WEBSITES_PORT=80"

# Variables pour le service AI
az webapp config appsettings set --resource-group $ResourceGroupName --name $AiAppName --settings `
    "PYTHONPATH=/app" `
    "PYTHONUNBUFFERED=1" `
    "WEBSITES_PORT=8000"

Write-Host "✅ Variables d'environnement configurées" -ForegroundColor Green

# 12. Afficher les informations de connexion
Write-Host "📋 Informations de connexion:" -ForegroundColor Green
Write-Host "Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Serveur SQL: $SqlServerName.database.windows.net" -ForegroundColor Cyan
Write-Host "Base de données: IntelliDocDb" -ForegroundColor Cyan
Write-Host "App Service backend: https://$BackendAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host "App Service frontend: https://$FrontendAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host "App Service AI: https://$AiAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host "Registre de conteneurs: $AcrName.azurecr.io" -ForegroundColor Cyan

# 13. Obtenir les credentials ACR
Write-Host "🔑 Credentials du registre de conteneurs:" -ForegroundColor Yellow
az acr credential show --name $AcrName

Write-Host "🎉 Configuration Azure gratuite terminée!" -ForegroundColor Green
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Build et push des images Docker" -ForegroundColor White
Write-Host "2. Déployer les applications" -ForegroundColor White
Write-Host "3. Configurer les domaines personnalisés" -ForegroundColor White 