# Guide de Déploiement Azure - ContextualImageDescriptionApp

## 🚀 Vue d'ensemble

Ce guide vous accompagne étape par étape pour déployer votre application sur Azure en utilisant GitHub Actions et Docker.

## 📋 Prérequis

### 1. Comptes requis
- [x] Compte GitHub
- [x] Compte Azure (gratuit ou payant)
- [x] Azure CLI installé

### 2. Outils à installer
```bash
# Installer Azure CLI
# Windows (PowerShell en tant qu'administrateur)
winget install -e --id Microsoft.AzureCLI

# Installer Docker Desktop
# Télécharger depuis https://www.docker.com/products/docker-desktop
```

## 🔧 Étape 1: Préparation Azure

### 1.1 Connexion à Azure
```bash
# Ouvrir PowerShell et se connecter
az login
```

### 1.2 Créer un groupe de ressources
```bash
# Créer un groupe de ressources
az group create --name ContextualImageDescriptionApp-RG --location "West Europe"

# Vérifier la création
az group list --output table
```

### 1.3 Créer un registre de conteneurs Azure (ACR)
```bash
# Créer le registre
az acr create --resource-group ContextualImageDescriptionApp-RG \
    --name contextualimagedescriptionappacr --sku Basic

# Activer l'accès admin
az acr update -n contextualimagedescriptionappacr --admin-enabled true

# Obtenir les informations de connexion
az acr credential show --name contextualimagedescriptionappacr
```

### 1.4 Créer une base de données SQL Azure
```bash
# Créer un serveur SQL
az sql server create \
    --name contextualimagedescriptionapp-sql \
    --resource-group ContextualImageDescriptionApp-RG \
    --location "West Europe" \
    --admin-user sqladmin \
    --admin-password "YourStrong@Passw0rd123!"

# Créer la base de données
az sql db create \
    --resource-group ContextualImageDescriptionApp-RG \
    --server contextualimagedescriptionapp-sql \
    --name IntelliDocDb \
    --service-objective Basic

# Configurer le pare-feu (autoriser toutes les IP)
az sql server firewall-rule create \
    --resource-group ContextualImageDescriptionApp-RG \
    --server contextualimagedescriptionapp-sql \
    --name AllowAll \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255
```

### 1.5 Créer Azure App Service pour le backend
```bash
# Créer un plan App Service
az appservice plan create \
    --name ContextualImageDescriptionApp-Plan \
    --resource-group ContextualImageDescriptionApp-RG \
    --sku B1 \
    --is-linux

# Créer l'application web pour le backend
az webapp create \
    --resource-group ContextualImageDescriptionApp-RG \
    --plan ContextualImageDescriptionApp-Plan \
    --name contextualimagedescriptionapp-backend \
    --deployment-local-git
```

## 🔧 Étape 2: Configuration GitHub

### 2.1 Créer un repository GitHub
1. Allez sur [GitHub.com](https://github.com)
2. Cliquez sur "New repository"
3. Nommez-le `ContextualImageDescriptionApp`
4. Choisissez "Public" ou "Private"
5. Cliquez sur "Create repository"

### 2.2 Pousser votre code vers GitHub
```bash
# Dans votre dossier de projet
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/VOTRE_USERNAME/ContextualImageDescriptionApp.git
git push -u origin main
```

### 2.3 Configurer les secrets GitHub

Allez dans votre repository GitHub → Settings → Secrets and variables → Actions

Ajoutez ces secrets :

| Nom du Secret | Valeur |
|---------------|--------|
| `AZURE_RESOURCE_GROUP` | `ContextualImageDescriptionApp-RG` |
| `AZURE_LOCATION` | `West Europe` |
| `AZURE_DNS_NAME` | `contextualimagedescriptionapp` |
| `AZURE_APP_NAME_BACKEND` | `contextualimagedescriptionapp-backend` |
| `AZURE_CREDENTIALS` | (voir étape 2.4) |

### 2.4 Créer les credentials Azure

```bash
# Créer un service principal Azure
az ad sp create-for-rbac --name "ContextualImageDescriptionApp" \
    --role contributor \
    --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/ContextualImageDescriptionApp-RG \
    --sdk-auth
```

Copiez la sortie JSON complète dans le secret `AZURE_CREDENTIALS`.

### 2.5 Obtenir le profil de publication

```bash
# Obtenir le profil de publication pour le backend
az webapp deployment list-publishing-profiles \
    --resource-group ContextualImageDescriptionApp-RG \
    --name contextualimagedescriptionapp-backend \
    --xml
```

Copiez le contenu XML dans le secret `AZURE_WEBAPP_PUBLISH_PROFILE_BACKEND`.

## 🔧 Étape 3: Configuration de l'application

### 3.1 Mettre à jour les URLs de production

Dans `frontend/src/api/api.js` :
```javascript
const api = axios.create({
  baseURL: process.env.NODE_ENV === 'production' 
    ? 'https://contextualimagedescriptionapp-backend.azurewebsites.net'
    : 'http://localhost:5047',
});
```

### 3.2 Mettre à jour la configuration du backend

Dans `backend/IntelliDocBackend/appsettings.Production.json` :
```json
{
  "ConnectionStrings": {
    "IntelliDocDb": "Server=tcp:contextualimagedescriptionapp-sql.database.windows.net,1433;Initial Catalog=IntelliDocDb;Persist Security Info=False;User ID=sqladmin;Password=YourStrong@Passw0rd123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  },
  "Jwt": {
    "Key": "VotreCléSecrèteTrèsLongueEtComplexe",
    "Issuer": "https://contextualimagedescriptionapp-backend.azurewebsites.net",
    "Audience": "https://contextualimagedescriptionapp-frontend.azurewebsites.net"
  }
}
```

### 3.3 Mettre à jour l'AI Service

Dans `ai_service/main.py`, ajoutez CORS pour la production :
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifiez vos domaines
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 🔧 Étape 4: Déploiement

### 4.1 Pousser les modifications
```bash
git add .
git commit -m "Configure for Azure deployment"
git push
```

### 4.2 Vérifier le déploiement
1. Allez dans votre repository GitHub
2. Cliquez sur l'onglet "Actions"
3. Vous verrez le workflow "Deploy to Azure" en cours d'exécution
4. Attendez que tous les jobs soient terminés (✓ vert)

### 4.3 Vérifier les services déployés
```bash
# Vérifier les conteneurs ACI
az container list --resource-group ContextualImageDescriptionApp-RG

# Vérifier l'App Service
az webapp list --resource-group ContextualImageDescriptionApp-RG

# Vérifier la base de données
az sql db list --resource-group ContextualImageDescriptionApp-RG \
    --server contextualimagedescriptionapp-sql
```

## 🌐 Étape 5: Configuration finale

### 5.1 URLs de votre application
- **Frontend**: `https://contextualimagedescriptionapp.westeurope.azurecontainer.io`
- **Backend**: `https://contextualimagedescriptionapp-backend.azurewebsites.net`
- **AI Service**: `https://contextualimagedescriptionapp-ai.westeurope.azurecontainer.io`

### 5.2 Tester l'application
1. Ouvrez l'URL du frontend
2. Testez l'inscription/connexion
3. Testez l'upload et l'analyse de documents

### 5.3 Monitoring
```bash
# Voir les logs du backend
az webapp log tail --name contextualimagedescriptionapp-backend \
    --resource-group ContextualImageDescriptionApp-RG

# Voir les logs des conteneurs
az container logs --name frontend-container \
    --resource-group ContextualImageDescriptionApp-RG
```

## 🔧 Étape 6: Optimisations (optionnel)

### 6.1 Configurer un domaine personnalisé
```bash
# Ajouter un domaine personnalisé
az webapp config hostname add \
    --webapp-name contextualimagedescriptionapp-backend \
    --resource-group ContextualImageDescriptionApp-RG \
    --hostname votre-domaine.com
```

### 6.2 Configurer SSL
```bash
# Activer HTTPS
az webapp update --https-only true \
    --name contextualimagedescriptionapp-backend \
    --resource-group ContextualImageDescriptionApp-RG
```

### 6.3 Configurer la mise à l'échelle automatique
```bash
# Configurer l'autoscaling pour le backend
az monitor autoscale create \
    --resource-group ContextualImageDescriptionApp-RG \
    --resource contextualimagedescriptionapp-backend \
    --resource-type Microsoft.Web/sites \
    --name autoscale-backend \
    --min-count 1 \
    --max-count 3 \
    --count 1
```

## 🛠️ Dépannage

### Problèmes courants

1. **Erreur de connexion à la base de données**
   - Vérifiez que le serveur SQL est accessible
   - Vérifiez les credentials dans les secrets

2. **Erreur de build Docker**
   - Vérifiez que tous les Dockerfiles sont corrects
   - Vérifiez les dépendances dans requirements.txt

3. **Erreur de déploiement**
   - Vérifiez les secrets GitHub
   - Vérifiez les permissions Azure

### Commandes utiles
```bash
# Redémarrer un service
az webapp restart --name contextualimagedescriptionapp-backend

# Voir les variables d'environnement
az webapp config appsettings list --name contextualimagedescriptionapp-backend

# Supprimer tout (en cas de problème)
az group delete --name ContextualImageDescriptionApp-RG --yes
```

## 💰 Estimation des coûts

- **Azure Container Instances**: ~$20-30/mois
- **Azure App Service**: ~$10-15/mois
- **Azure SQL Database**: ~$5-10/mois
- **Azure Container Registry**: ~$5/mois

**Total estimé**: ~$40-60/mois

## 🎉 Félicitations !

Votre application est maintenant déployée sur Azure ! 

### Prochaines étapes
1. Configurer un domaine personnalisé
2. Mettre en place le monitoring
3. Configurer les sauvegardes
4. Optimiser les performances

### Support
- [Documentation Azure](https://docs.microsoft.com/azure/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker](https://docs.docker.com/) 