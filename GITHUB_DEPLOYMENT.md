# 🚀 Déploiement Azure avec GitHub Actions

Ce guide vous accompagne pour déployer votre application **ContextualImageDescriptionApp** sur Azure en utilisant GitHub Actions et votre repository [https://github.com/nadabouaouaja/stage_neoledge.git](https://github.com/nadabouaouaja/stage_neoledge.git).

## 📋 Prérequis

- ✅ Compte Azure (Azure for Students)
- ✅ Repository GitHub créé
- ✅ Azure CLI installé et configuré
- ✅ Docker Desktop installé

## 🔧 Étape 1: Configuration de l'infrastructure Azure

D'abord, créons l'infrastructure Azure nécessaire :

```powershell
# Naviguer vers le dossier scripts
cd "C:\Users\nada\Desktop\finalversionstage\ContextualImageDescriptionApp\scripts"

# Vérifier les prérequis
.\check-prerequisites.ps1

# Créer l'infrastructure Azure
.\deploy-azure-free.ps1
```

## 🔐 Étape 2: Configuration des secrets GitHub

Configurez les secrets GitHub nécessaires pour le déploiement automatique :

```powershell
# Configurer les secrets GitHub
.\setup-github-workflow.ps1
```

Ce script va :
1. Créer un service principal Azure
2. Récupérer les credentials du registre de conteneurs
3. Afficher les secrets à configurer dans GitHub

### Secrets à configurer dans GitHub

Allez dans votre repository GitHub : [https://github.com/nadabouaouaja/stage_neoledge/settings/secrets/actions](https://github.com/nadabouaouaja/stage_neoledge/settings/secrets/actions)

Ajoutez ces secrets :

| Nom du Secret | Description |
|---------------|-------------|
| `AZURE_CREDENTIALS` | Credentials du service principal Azure (JSON) |
| `ACR_USERNAME` | Nom d'utilisateur du registre de conteneurs |
| `ACR_PASSWORD` | Mot de passe du registre de conteneurs |

## 📤 Étape 3: Pousser le code vers GitHub

```powershell
# Retourner au dossier principal
cd "C:\Users\nada\Desktop\finalversionstage\ContextualImageDescriptionApp"

# Initialiser Git et pousser le code
git add .
git commit -m "Initial commit - Application ContextualImageDescriptionApp"
git branch -M main
git push -u origin main
```

## 🔄 Étape 4: Déploiement automatique

Une fois le code poussé vers GitHub :

1. **Le workflow se déclenche automatiquement** lors du push sur la branche `main`
2. **GitHub Actions** va :
   - Build les images Docker
   - Les pousser vers Azure Container Registry
   - Déployer sur Azure App Service
   - Redémarrer les services

3. **Surveillez le progrès** dans l'onglet Actions de votre repository GitHub

## 🌐 URLs de votre application

Une fois le déploiement terminé, vos applications seront accessibles à :

- **Frontend**: `https://contextualimagedescriptionapp-frontend.azurewebsites.net`
- **Backend API**: `https://contextualimagedescriptionapp-backend.azurewebsites.net`
- **AI Service**: `https://contextualimagedescriptionapp-ai.azurewebsites.net`

## 🔄 Déploiements futurs

Pour les déploiements futurs, il suffit de :

```powershell
git add .
git commit -m "Description des modifications"
git push origin main
```

Le workflow GitHub Actions se déclenchera automatiquement !

## 🛠️ Monitoring et logs

### Voir les logs du déploiement
- Allez dans l'onglet **Actions** de votre repository GitHub
- Cliquez sur le workflow "Deploy to Azure"
- Voir les logs en temps réel

### Voir les logs des applications
```powershell
# Logs du backend
az webapp log tail --name contextualimagedescriptionapp-backend --resource-group ContextualImageDescriptionApp-RG

# Logs du frontend
az webapp log tail --name contextualimagedescriptionapp-frontend --resource-group ContextualImageDescriptionApp-RG

# Logs du service AI
az webapp log tail --name contextualimagedescriptionapp-ai --resource-group ContextualImageDescriptionApp-RG
```

## 🧹 Nettoyage

Pour supprimer toutes les ressources Azure :

```powershell
cd scripts
.\cleanup-azure.ps1
```

## 🛠️ Dépannage

### Problèmes courants

1. **Erreur de permissions Azure**
   - Vérifiez que le service principal a les bonnes permissions
   - Relancez `.\setup-github-workflow.ps1`

2. **Erreur de build Docker**
   - Vérifiez que les Dockerfiles sont corrects
   - Vérifiez les logs dans GitHub Actions

3. **Applications non accessibles**
   - Attendez 5-10 minutes après le déploiement
   - Vérifiez les logs des App Services

### Commandes utiles

```powershell
# Vérifier le statut des App Services
az webapp list --resource-group ContextualImageDescriptionApp-RG

# Redémarrer un service
az webapp restart --name contextualimagedescriptionapp-backend --resource-group ContextualImageDescriptionApp-RG

# Voir les variables d'environnement
az webapp config appsettings list --name contextualimagedescriptionapp-backend --resource-group ContextualImageDescriptionApp-RG
```

## 🎉 Félicitations !

Votre application est maintenant déployée avec un pipeline CI/CD complet !

### Prochaines étapes
1. ✅ Tester toutes les fonctionnalités
2. 🔧 Configurer un domaine personnalisé
3. 📊 Mettre en place le monitoring
4. 🔒 Configurer les sauvegardes automatiques

---

**Support** : Consultez les logs GitHub Actions pour tout problème de déploiement. 