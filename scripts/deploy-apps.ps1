# Script PowerShell pour déployer les applications sur Azure App Service
# Optimisé pour les images Docker

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$AcrName = "contextualimagedescriptionappacr",
    [string]$BackendAppName = "contextualimagedescriptionapp-backend",
    [string]$FrontendAppName = "contextualimagedescriptionapp-frontend"
)

Write-Host "🚀 Déploiement des applications sur Azure App Service" -ForegroundColor Green

# 1. Vérifier la connexion Azure
Write-Host "📋 Vérification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Veuillez vous connecter à Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# 2. Obtenir l'URL du registre
$AcrLoginServer = az acr show --name $AcrName --query loginServer --output tsv
Write-Host "📦 URL du registre: $AcrLoginServer" -ForegroundColor Cyan

# 3. Obtenir les credentials ACR
Write-Host "🔑 Récupération des credentials ACR..." -ForegroundColor Yellow
$AcrCredentials = az acr credential show --name $AcrName --query "username" --output tsv
$AcrPassword = az acr credential show --name $AcrName --query "passwords[0].value" --output tsv

# 4. Configurer l'App Service backend pour Docker
Write-Host "🔧 Configuration de l'App Service backend..." -ForegroundColor Yellow
az webapp config container set --resource-group $ResourceGroupName --name $BackendAppName `
    --docker-custom-image-name "$AcrLoginServer/backend:latest" `
    --docker-registry-server-url "https://$AcrLoginServer" `
    --docker-registry-server-user $AcrCredentials `
    --docker-registry-server-password $AcrPassword

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service backend configuré" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la configuration du backend" -ForegroundColor Red
    exit 1
}

# 5. Configurer l'App Service frontend pour Docker
Write-Host "🎨 Configuration de l'App Service frontend..." -ForegroundColor Yellow
az webapp config container set --resource-group $ResourceGroupName --name $FrontendAppName `
    --docker-custom-image-name "$AcrLoginServer/frontend:latest" `
    --docker-registry-server-url "https://$AcrLoginServer" `
    --docker-registry-server-user $AcrCredentials `
    --docker-registry-server-password $AcrPassword

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service frontend configuré" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la configuration du frontend" -ForegroundColor Red
    exit 1
}

# 6. Redémarrer les applications
Write-Host "🔄 Redémarrage des applications..." -ForegroundColor Yellow
az webapp restart --resource-group $ResourceGroupName --name $BackendAppName
az webapp restart --resource-group $ResourceGroupName --name $FrontendAppName

# 7. Attendre que les applications soient prêtes
Write-Host "⏳ Attente du démarrage des applications..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 8. Vérifier le statut des applications
Write-Host "📊 Vérification du statut des applications..." -ForegroundColor Yellow

$BackendStatus = az webapp show --resource-group $ResourceGroupName --name $BackendAppName --query "state" --output tsv
$FrontendStatus = az webapp show --resource-group $ResourceGroupName --name $FrontendAppName --query "state" --output tsv

Write-Host "Backend status: $BackendStatus" -ForegroundColor Cyan
Write-Host "Frontend status: $FrontendStatus" -ForegroundColor Cyan

# 9. Afficher les URLs des applications
Write-Host "🌐 URLs des applications:" -ForegroundColor Green
Write-Host "Backend: https://$BackendAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host "Frontend: https://$FrontendAppName.azurewebsites.net" -ForegroundColor Cyan

# 10. Tester les applications
Write-Host "🧪 Test des applications..." -ForegroundColor Yellow
try {
    $BackendResponse = Invoke-WebRequest -Uri "https://$BackendAppName.azurewebsites.net/health" -UseBasicParsing -TimeoutSec 30
    Write-Host "✅ Backend accessible" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend pas encore accessible (normal au premier démarrage)" -ForegroundColor Yellow
}

try {
    $FrontendResponse = Invoke-WebRequest -Uri "https://$FrontendAppName.azurewebsites.net" -UseBasicParsing -TimeoutSec 30
    Write-Host "✅ Frontend accessible" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Frontend pas encore accessible (normal au premier démarrage)" -ForegroundColor Yellow
}

Write-Host "🎉 Déploiement terminé!" -ForegroundColor Green
Write-Host "Les applications peuvent prendre quelques minutes pour être complètement accessibles." -ForegroundColor Yellow 