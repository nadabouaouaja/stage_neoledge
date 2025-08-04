# Script PowerShell pour deploiement complet
# Orchestre tout le processus : Infrastructure -> Docker -> Deploiement

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$Location = "West Europe",
    [switch]$SkipPrerequisites = $false
)

Write-Host "Deploiement complet Azure + Docker + GitHub Actions" -ForegroundColor Green
Write-Host "Localisation: $Location" -ForegroundColor Cyan
Write-Host "Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan

# 0. Verifier les prerequis (si pas skipe)
if (-not $SkipPrerequisites) {
    Write-Host "Etape 0/5 : Verification des prerequis..." -ForegroundColor Yellow
    .\check-prerequisites.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERREUR - Prerequis non satisfaits" -ForegroundColor Red
        exit 1
    }
}

# 1. Verifier la connexion Azure
Write-Host "Etape 1/5 : Verification de la connexion Azure..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Veuillez vous connecter a Azure avec 'az login'" -ForegroundColor Red
    exit 1
}

# 2. Creer l'infrastructure Azure
Write-Host "Etape 2/5 : Creation de l'infrastructure Azure..." -ForegroundColor Yellow
.\deploy-azure-free.ps1 -ResourceGroupName $ResourceGroupName -Location $Location
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Erreur lors de la creation de l'infrastructure" -ForegroundColor Red
    exit 1
}

# 3. Build et push les images Docker
Write-Host "Etape 3/5 : Build et push des images Docker..." -ForegroundColor Yellow
.\build-and-push.ps1 -ResourceGroupName $ResourceGroupName
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Erreur lors du build et push des images" -ForegroundColor Red
    exit 1
}

# 4. Deployer les applications
Write-Host "Etape 4/5 : Deploiement des applications..." -ForegroundColor Yellow
.\deploy-apps.ps1 -ResourceGroupName $ResourceGroupName
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Erreur lors du deploiement des applications" -ForegroundColor Red
    exit 1
}

# 5. Configurer GitHub Actions
Write-Host "Etape 5/5 : Configuration GitHub Actions..." -ForegroundColor Yellow
.\setup-github-secrets.ps1 -ResourceGroupName $ResourceGroupName
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Erreur lors de la configuration GitHub Actions" -ForegroundColor Red
    exit 1
}

Write-Host "Deploiement complet termine" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "1. Creez un repository GitHub" -ForegroundColor White
Write-Host "2. Poussez votre code vers GitHub" -ForegroundColor White
Write-Host "3. Configurez les secrets GitHub (voir les instructions ci-dessus)" -ForegroundColor White
Write-Host "4. Le deploiement automatique se fera a chaque push" -ForegroundColor White
Write-Host ""
Write-Host "URLs de vos applications:" -ForegroundColor Cyan
Write-Host "Backend: https://contextualimagedescriptionapp-backend.azurewebsites.net" -ForegroundColor Green
Write-Host "Frontend: https://contextualimagedescriptionapp-frontend.azurewebsites.net" -ForegroundColor Green
Write-Host "AI Service: https://contextualimagedescriptionapp-ai.azurewebsites.net" -ForegroundColor Green
