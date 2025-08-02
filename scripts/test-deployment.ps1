# Script PowerShell pour tester le déploiement Azure
# Vérifie que toutes les applications sont accessibles et fonctionnelles

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$BackendAppName = "contextualimagedescriptionapp-backend",
    [string]$FrontendAppName = "contextualimagedescriptionapp-frontend",
    [string]$AiAppName = "contextualimagedescriptionapp-ai"
)

Write-Host "🧪 Test du déploiement Azure" -ForegroundColor Green
Write-Host "📦 Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan

# URLs des applications
$BackendUrl = "https://$BackendAppName.azurewebsites.net"
$FrontendUrl = "https://$FrontendAppName.azurewebsites.net"
$AiUrl = "https://$AiAppName.azurewebsites.net"

# 1. Vérifier le statut des App Services
Write-Host "📊 Vérification du statut des App Services..." -ForegroundColor Yellow

$BackendStatus = az webapp show --resource-group $ResourceGroupName --name $BackendAppName --query "state" --output tsv
$FrontendStatus = az webapp show --resource-group $ResourceGroupName --name $FrontendAppName --query "state" --output tsv
$AiStatus = az webapp show --resource-group $ResourceGroupName --name $AiAppName --query "state" --output tsv

Write-Host "Backend: $BackendStatus" -ForegroundColor $(if ($BackendStatus -eq "Running") { "Green" } else { "Red" })
Write-Host "Frontend: $FrontendStatus" -ForegroundColor $(if ($FrontendStatus -eq "Running") { "Green" } else { "Red" })
Write-Host "AI Service: $AiStatus" -ForegroundColor $(if ($AiStatus -eq "Running") { "Green" } else { "Red" })

# 2. Tester l'accessibilité des applications
Write-Host ""
Write-Host "🌐 Test d'accessibilité des applications..." -ForegroundColor Yellow

# Test Backend
Write-Host "🔧 Test du Backend..." -ForegroundColor Yellow
try {
    $BackendResponse = Invoke-WebRequest -Uri "$BackendUrl/health" -UseBasicParsing -TimeoutSec 30
    if ($BackendResponse.StatusCode -eq 200) {
        Write-Host "✅ Backend accessible - Status: $($BackendResponse.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Backend accessible mais status inattendu: $($BackendResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Backend non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Frontend
Write-Host "🎨 Test du Frontend..." -ForegroundColor Yellow
try {
    $FrontendResponse = Invoke-WebRequest -Uri $FrontendUrl -UseBasicParsing -TimeoutSec 30
    if ($FrontendResponse.StatusCode -eq 200) {
        Write-Host "✅ Frontend accessible - Status: $($FrontendResponse.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Frontend accessible mais status inattendu: $($FrontendResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Frontend non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test AI Service
Write-Host "🤖 Test du AI Service..." -ForegroundColor Yellow
try {
    $AiResponse = Invoke-WebRequest -Uri "$AiUrl/health" -UseBasicParsing -TimeoutSec 30
    if ($AiResponse.StatusCode -eq 200) {
        Write-Host "✅ AI Service accessible - Status: $($AiResponse.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  AI Service accessible mais status inattendu: $($AiResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ AI Service non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Vérifier la base de données
Write-Host ""
Write-Host "🗄️  Vérification de la base de données..." -ForegroundColor Yellow
try {
    $SqlServerName = "contextualimagedescriptionapp-sql"
    $DbStatus = az sql db show --resource-group $ResourceGroupName --server $SqlServerName --name IntelliDocDb --query "status" --output tsv
    Write-Host "✅ Base de données: $DbStatus" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de la vérification de la base de données" -ForegroundColor Red
}

# 4. Vérifier le registre de conteneurs
Write-Host ""
Write-Host "🐳 Vérification du registre de conteneurs..." -ForegroundColor Yellow
try {
    $AcrName = "contextualimagedescriptionappacr"
    $AcrStatus = az acr show --name $AcrName --query "provisioningState" --output tsv
    Write-Host "✅ Registre de conteneurs: $AcrStatus" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de la vérification du registre de conteneurs" -ForegroundColor Red
}

# 5. Afficher les URLs finales
Write-Host ""
Write-Host "🌐 URLs de vos applications:" -ForegroundColor Green
Write-Host "Backend API: $BackendUrl" -ForegroundColor Cyan
Write-Host "Frontend: $FrontendUrl" -ForegroundColor Cyan
Write-Host "AI Service: $AiUrl" -ForegroundColor Cyan

# 6. Test de fonctionnalité (optionnel)
Write-Host ""
Write-Host "🔍 Test de fonctionnalité..." -ForegroundColor Yellow

# Test d'une requête API simple
try {
    $ApiTestResponse = Invoke-WebRequest -Uri "$BackendUrl/api/health" -UseBasicParsing -TimeoutSec 30
    Write-Host "✅ API Backend fonctionnelle" -ForegroundColor Green
} catch {
    Write-Host "⚠️  API Backend non testée (peut être normal au premier démarrage)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Test de déploiement terminé!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Résumé:" -ForegroundColor Yellow
Write-Host "- Backend: $BackendUrl" -ForegroundColor White
Write-Host "- Frontend: $FrontendUrl" -ForegroundColor White
Write-Host "- AI Service: $AiUrl" -ForegroundColor White
Write-Host ""
Write-Host "💡 Si certaines applications ne sont pas accessibles, attendez quelques minutes et relancez ce script" -ForegroundColor Cyan
Write-Host "💡 Les applications peuvent prendre 5-10 minutes pour être complètement accessibles après le déploiement" -ForegroundColor Cyan 