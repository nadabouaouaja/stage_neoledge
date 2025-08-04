# Script PowerShell pour nettoyer les ressources Azure
# Supprime toutes les ressources créées pour le projet

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [switch]$Force = $false
)

Write-Host "🧹 Nettoyage des ressources Azure" -ForegroundColor Green
Write-Host "📦 Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan

# Vérifier la connexion Azure
Write-Host "📋 Vérification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Veuillez vous connecter à Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# Vérifier si le groupe de ressources existe
Write-Host "🔍 Vérification de l'existence du groupe de ressources..." -ForegroundColor Yellow
$ResourceGroupExists = az group exists --name $ResourceGroupName --output tsv
if ($ResourceGroupExists -eq "false") {
    Write-Host "⚠️  Le groupe de ressources '$ResourceGroupName' n'existe pas" -ForegroundColor Yellow
    exit 0
}

# Afficher les ressources qui vont être supprimées
Write-Host "📋 Ressources qui vont être supprimées:" -ForegroundColor Yellow
az resource list --resource-group $ResourceGroupName --output table

# Demander confirmation (sauf si -Force est utilisé)
if (-not $Force) {
    Write-Host ""
    Write-Host "⚠️  ATTENTION: Cette action va supprimer TOUTES les ressources du groupe '$ResourceGroupName'" -ForegroundColor Red
    Write-Host "📋 Cela inclut:" -ForegroundColor Yellow
    Write-Host "   - App Services (Backend, Frontend, AI Service)" -ForegroundColor White
    Write-Host "   - Base de données SQL" -ForegroundColor White
    Write-Host "   - Registre de conteneurs" -ForegroundColor White
    Write-Host "   - Plan App Service" -ForegroundColor White
    Write-Host "   - Toutes les données associées" -ForegroundColor White
    Write-Host ""
    
    $confirmation = Read-Host "Êtes-vous sûr de vouloir continuer? (oui/non)"
    if ($confirmation -ne "oui") {
        Write-Host "❌ Nettoyage annulé" -ForegroundColor Yellow
        exit 0
    }
}

# Supprimer le groupe de ressources (cela supprime tout)
Write-Host "🗑️  Suppression du groupe de ressources '$ResourceGroupName'..." -ForegroundColor Yellow
az group delete --name $ResourceGroupName --yes --no-wait

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Suppression du groupe de ressources initiée" -ForegroundColor Green
    Write-Host "⏳ La suppression peut prendre plusieurs minutes..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Pour vérifier le statut de la suppression:" -ForegroundColor Cyan
    Write-Host "az group show --name $ResourceGroupName" -ForegroundColor White
} else {
    Write-Host "❌ Erreur lors de la suppression du groupe de ressources" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Nettoyage terminé!" -ForegroundColor Green
Write-Host "💡 Toutes les ressources ont été supprimées" -ForegroundColor Cyan 