# Script PowerShell pour build et push les images Docker vers Azure
# Optimisé pour Azure Container Registry

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$AcrName = "contextualimagedescriptionappacr"
)

Write-Host "🐳 Build et push des images Docker vers Azure" -ForegroundColor Green

# 1. Vérifier la connexion Azure
Write-Host "📋 Vérification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Veuillez vous connecter à Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# 2. Login au registre de conteneurs
Write-Host "🔐 Login au registre de conteneurs..." -ForegroundColor Yellow
az acr login --name $AcrName
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur de login au registre de conteneurs" -ForegroundColor Red
    exit 1
}

# 3. Obtenir l'URL du registre
$AcrLoginServer = az acr show --name $AcrName --query loginServer --output tsv
Write-Host "📦 URL du registre: $AcrLoginServer" -ForegroundColor Cyan

# 4. Build et push l'image backend
Write-Host "🔧 Build de l'image backend..." -ForegroundColor Yellow
Set-Location "..\backend"
docker build -t $AcrLoginServer/backend:latest .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image backend buildée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du build de l'image backend" -ForegroundColor Red
    exit 1
}

Write-Host "📤 Push de l'image backend..." -ForegroundColor Yellow
docker push $AcrLoginServer/backend:latest
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image backend poussée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du push de l'image backend" -ForegroundColor Red
    exit 1
}

# 5. Build et push l'image frontend
Write-Host "🎨 Build de l'image frontend..." -ForegroundColor Yellow
Set-Location "..\frontend"
docker build -t $AcrLoginServer/frontend:latest .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image frontend buildée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du build de l'image frontend" -ForegroundColor Red
    exit 1
}

Write-Host "📤 Push de l'image frontend..." -ForegroundColor Yellow
docker push $AcrLoginServer/frontend:latest
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image frontend poussée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du push de l'image frontend" -ForegroundColor Red
    exit 1
}

# 6. Build et push l'image AI service
Write-Host "🤖 Build de l'image AI service..." -ForegroundColor Yellow
Set-Location "..\ai_service"
docker build -t $AcrLoginServer/ai-service:latest .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image AI service buildée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du build de l'image AI service" -ForegroundColor Red
    exit 1
}

Write-Host "📤 Push de l'image AI service..." -ForegroundColor Yellow
docker push $AcrLoginServer/ai-service:latest
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image AI service poussée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du push de l'image AI service" -ForegroundColor Red
    exit 1
}

# 7. Retourner au répertoire scripts
Set-Location "..\scripts"

Write-Host "🎉 Build et push terminés!" -ForegroundColor Green
Write-Host "Images disponibles:" -ForegroundColor Yellow
Write-Host "- Backend: $AcrLoginServer/backend:latest" -ForegroundColor Cyan
Write-Host "- Frontend: $AcrLoginServer/frontend:latest" -ForegroundColor Cyan
Write-Host "- AI Service: $AcrLoginServer/ai-service:latest" -ForegroundColor Cyan

Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Déployer les applications sur Azure App Service" -ForegroundColor White
Write-Host "2. Configurer les variables d'environnement" -ForegroundColor White
Write-Host "3. Tester les applications" -ForegroundColor White 