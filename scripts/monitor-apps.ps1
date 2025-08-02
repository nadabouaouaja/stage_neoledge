# Script PowerShell pour monitorer les applications Azure
# Affiche le statut en temps réel des services déployés

param(
    [string]$ResourceGroupName = "ContextualImageDescriptionApp-RG",
    [string]$BackendAppName = "contextualimagedescriptionapp-backend",
    [string]$FrontendAppName = "contextualimagedescriptionapp-frontend",
    [string]$AiAppName = "contextualimagedescriptionapp-ai",
    [int]$RefreshInterval = 30
)

Write-Host "📊 Monitoring des applications Azure" -ForegroundColor Green
Write-Host "📦 Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "⏱️  Intervalle de rafraîchissement: $RefreshInterval secondes" -ForegroundColor Cyan
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le monitoring" -ForegroundColor Yellow
Write-Host ""

# URLs des applications
$BackendUrl = "https://$BackendAppName.azurewebsites.net"
$FrontendUrl = "https://$FrontendAppName.azurewebsites.net"
$AiUrl = "https://$AiAppName.azurewebsites.net"

# Fonction pour afficher le statut d'une application
function Show-AppStatus {
    param(
        [string]$AppName,
        [string]$AppUrl,
        [string]$ServiceType
    )
    
    # Obtenir le statut Azure
    try {
        $AzureStatus = az webapp show --resource-group $ResourceGroupName --name $AppName --query "state" --output tsv
    } catch {
        $AzureStatus = "Unknown"
    }
    
    # Tester l'accessibilité
    try {
        $Response = Invoke-WebRequest -Uri $AppUrl -UseBasicParsing -TimeoutSec 10
        $HttpStatus = $Response.StatusCode
        $ResponseTime = $Response.BaseResponse.ResponseTime
        $Accessible = "✅"
    } catch {
        $HttpStatus = "N/A"
        $ResponseTime = "N/A"
        $Accessible = "❌"
    }
    
    # Afficher le statut
    Write-Host "$ServiceType" -ForegroundColor Cyan -NoNewline
    Write-Host " ($AppName)" -ForegroundColor White -NoNewline
    Write-Host " - Azure: " -NoNewline
    Write-Host $AzureStatus -ForegroundColor $(if ($AzureStatus -eq "Running") { "Green" } else { "Red" }) -NoNewline
    Write-Host " - HTTP: " -NoNewline
    Write-Host "$HttpStatus" -ForegroundColor $(if ($HttpStatus -eq 200) { "Green" } else { "Yellow" }) -NoNewline
    Write-Host " - $Accessible" -ForegroundColor $(if ($Accessible -eq "✅") { "Green" } else { "Red" })
}

# Fonction pour afficher les métriques
function Show-Metrics {
    Write-Host ""
    Write-Host "📈 Métriques des applications:" -ForegroundColor Yellow
    
    # CPU et mémoire pour chaque application
    $apps = @($BackendAppName, $FrontendAppName, $AiAppName)
    
    foreach ($app in $apps) {
        try {
            $metrics = az monitor metrics list --resource-group $ResourceGroupName --resource "/subscriptions/$(az account show --query id --output tsv)/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$app" --metric "CpuPercentage,MemoryPercentage" --interval PT1M --output json | ConvertFrom-Json
            
            Write-Host "🔧 $app" -ForegroundColor Cyan
            if ($metrics.value) {
                foreach ($metric in $metrics.value) {
                    $metricName = $metric.name.value
                    $metricValue = $metric.timeseries[0].data[0].average
                    if ($metricValue) {
                        Write-Host "   $metricName`: $([math]::Round($metricValue, 2))%" -ForegroundColor White
                    }
                }
            }
        } catch {
            Write-Host "   Métriques non disponibles" -ForegroundColor Yellow
        }
    }
}

# Fonction pour afficher les logs récents
function Show-RecentLogs {
    Write-Host ""
    Write-Host "📝 Logs récents:" -ForegroundColor Yellow
    
    $apps = @($BackendAppName, $FrontendAppName, $AiAppName)
    
    foreach ($app in $apps) {
        Write-Host "🔧 $app" -ForegroundColor Cyan
        try {
            $logs = az webapp log tail --name $app --resource-group $ResourceGroupName --provider docker --lines 3 2>$null
            if ($logs) {
                $logs | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
            } else {
                Write-Host "   Aucun log récent" -ForegroundColor Gray
            }
        } catch {
            Write-Host "   Logs non disponibles" -ForegroundColor Yellow
        }
    }
}

# Boucle principale de monitoring
try {
    while ($true) {
        # Effacer l'écran
        Clear-Host
        
        # Afficher l'heure
        $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "🕐 $currentTime" -ForegroundColor Green
        Write-Host "📊 Monitoring des applications Azure" -ForegroundColor Green
        Write-Host "📦 Groupe de ressources: $ResourceGroupName" -ForegroundColor Cyan
        Write-Host ""
        
        # Afficher le statut des applications
        Write-Host "🌐 Statut des applications:" -ForegroundColor Yellow
        Show-AppStatus -AppName $BackendAppName -AppUrl $BackendUrl -ServiceType "🔧 Backend"
        Show-AppStatus -AppName $FrontendAppName -AppUrl $FrontendUrl -ServiceType "🎨 Frontend"
        Show-AppStatus -AppName $AiAppName -AppUrl $AiUrl -ServiceType "🤖 AI Service"
        
        # Afficher les métriques (toutes les 2 minutes)
        if ((Get-Date).Second -lt 30) {
            Show-Metrics
        }
        
        # Afficher les logs récents (toutes les 5 minutes)
        if ((Get-Date).Minute % 5 -eq 0 -and (Get-Date).Second -lt 30) {
            Show-RecentLogs
        }
        
        # Afficher les URLs
        Write-Host ""
        Write-Host "🌐 URLs des applications:" -ForegroundColor Green
        Write-Host "Backend: $BackendUrl" -ForegroundColor Cyan
        Write-Host "Frontend: $FrontendUrl" -ForegroundColor Cyan
        Write-Host "AI Service: $AiUrl" -ForegroundColor Cyan
        
        Write-Host ""
        Write-Host "🔄 Rafraîchissement dans $RefreshInterval secondes... (Ctrl+C pour arrêter)" -ForegroundColor Yellow
        
        # Attendre
        Start-Sleep -Seconds $RefreshInterval
    }
} catch {
    Write-Host ""
    Write-Host "🛑 Monitoring arrêté" -ForegroundColor Yellow
} 