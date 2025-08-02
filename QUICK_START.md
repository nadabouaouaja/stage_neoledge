# 🚀 Guide de Démarrage Rapide - Déploiement Azure

## 📋 Prérequis

1. **Compte Azure** (gratuit ou payant)
2. **Windows 10/11** avec PowerShell
3. **Connexion Internet** stable

## ⚡ Déploiement en 3 étapes

### Étape 1: Préparation
```powershell
# Ouvrir PowerShell en tant qu'administrateur
# Naviguer vers le dossier du projet
cd "C:\Users\nada\Desktop\finalversionstage\ContextualImageDescriptionApp\scripts"

# Vérifier les prérequis
.\check-prerequisites.ps1
```

### Étape 2: Déploiement automatique
```powershell
# Lancer le déploiement complet (15-20 minutes)
.\deploy-complete.ps1
```

### Étape 3: Test du déploiement
```powershell
# Tester que tout fonctionne
.\test-deployment.ps1
```

## 🌐 URLs de votre application

Une fois le déploiement terminé, vos applications seront accessibles à :

- **Frontend**: `https://contextualimagedescriptionapp-frontend.azurewebsites.net`
- **Backend API**: `https://contextualimagedescriptionapp-backend.azurewebsites.net`
- **AI Service**: `https://contextualimagedescriptionapp-ai.azurewebsites.net`

## 🔧 Options avancées

### Déploiement avec paramètres personnalisés
```powershell
# Déploiement avec localisation différente
.\deploy-complete.ps1 -Location "East US" -ResourceGroupName "MonApp-RG"

# Déploiement sans vérification des prérequis
.\deploy-complete.ps1 -SkipPrerequisites
```

### Déploiement étape par étape
```powershell
# 1. Créer l'infrastructure Azure
.\deploy-azure-free.ps1

# 2. Build et push les images Docker
.\build-and-push.ps1

# 3. Déployer les applications
.\deploy-apps.ps1

# 4. Configurer GitHub Actions
.\setup-github-secrets.ps1
```

## 🧹 Nettoyage

Pour supprimer toutes les ressources Azure :
```powershell
# Nettoyage avec confirmation
.\cleanup-azure.ps1

# Nettoyage forcé (sans confirmation)
.\cleanup-azure.ps1 -Force
```

## 💰 Coûts estimés

- **Azure App Service (F1)**: Gratuit
- **Azure SQL Database (Basic)**: ~$5/mois
- **Azure Container Registry (Basic)**: ~$5/mois
- **Total**: ~$10/mois

## 🛠️ Dépannage

### Problèmes courants

1. **Erreur "Azure CLI non installé"**
   ```powershell
   winget install -e --id Microsoft.AzureCLI
   ```

2. **Erreur "Docker non démarré"**
   - Démarrer Docker Desktop
   - Attendre que Docker soit prêt

3. **Erreur de connexion Azure**
   ```powershell
   az login
   ```

4. **Applications non accessibles après déploiement**
   ```powershell
   # Attendre 5-10 minutes puis tester
   .\test-deployment.ps1
   ```

### Logs et monitoring
```powershell
# Voir les logs du backend
az webapp log tail --name contextualimagedescriptionapp-backend --resource-group ContextualImageDescriptionApp-RG

# Voir les logs du frontend
az webapp log tail --name contextualimagedescriptionapp-frontend --resource-group ContextualImageDescriptionApp-RG
```

## 📞 Support

- **Documentation complète**: `DEPLOYMENT_GUIDE.md`
- **Scripts de déploiement**: Dossier `scripts/`
- **Configuration Docker**: Fichiers `Dockerfile` dans chaque service

## 🎉 Félicitations !

Votre application ContextualImageDescriptionApp est maintenant déployée sur Azure !

### Prochaines étapes
1. Tester toutes les fonctionnalités
2. Configurer un domaine personnalisé
3. Mettre en place le monitoring
4. Configurer les sauvegardes automatiques 