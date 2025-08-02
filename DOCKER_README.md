# Structure Docker et Déploiement Azure

## 📁 Structure des Dockerfiles

### Backend (.NET Core)
- **Fichier** : `backend/Dockerfile`
- **Port** : 8080
- **Optimisations** : Multi-stage build, configuration Azure

### Frontend (Vue.js + nginx)
- **Fichier** : `frontend/Dockerfile`
- **Port** : 80 (nginx)
- **Optimisations** : Multi-stage build, nginx pour production

### AI Service (Python + YOLOv8)
- **Fichier** : `ai_service/Dockerfile`
- **Port** : 8000
- **Optimisations** : Dependencies système pour OpenCV

## 🚀 Déploiement

### Option 1 : Déploiement complet automatique
```powershell
.\scripts\deploy-complete.ps1
```

### Option 2 : Déploiement étape par étape
```powershell
# 1. Infrastructure Azure
.\scripts\deploy-azure-free.ps1

# 2. Build et push Docker
.\scripts\build-and-push.ps1

# 3. Déployer les applications
.\scripts\deploy-apps.ps1

# 4. Configurer GitHub Actions
.\scripts\setup-github-secrets.ps1
```

### Option 3 : Développement local
```bash
docker-compose -f docker-compose.dev.yml up
```

## 🔧 Configuration

### Variables d'environnement Azure
- **Backend** : Connection string SQL, ASPNETCORE_ENVIRONMENT
- **Frontend** : NODE_ENV, WEBSITES_PORT
- **AI Service** : PYTHONPATH, PYTHONUNBUFFERED

### GitHub Actions
- **Trigger** : Push sur main/master
- **Actions** : Build Docker → Push ACR → Deploy Azure
- **Secrets requis** : AZURE_CREDENTIALS, REGISTRY_USERNAME, REGISTRY_PASSWORD

## 📊 Services Azure créés

### Infrastructure gratuite
- **Resource Group** : ContextualImageDescriptionApp-RG
- **Container Registry** : contextualimagedescriptionappacr
- **SQL Database** : IntelliDocDb (32MB gratuit)
- **App Service Plan** : F1 (gratuit)

### Applications
- **Backend** : https://contextualimagedescriptionapp-backend.azurewebsites.net
- **Frontend** : https://contextualimagedescriptionapp-frontend.azurewebsites.net
- **AI Service** : https://contextualimagedescriptionapp-ai.azurewebsites.net

## 🐳 Images Docker

### Build local
```bash
# Backend
docker build -t backend:latest ./backend

# Frontend
docker build -t frontend:latest ./frontend

# AI Service
docker build -t ai-service:latest ./ai_service
```

### Push vers Azure
```bash
# Login ACR
az acr login --name contextualimagedescriptionappacr

# Push images
docker push contextualimagedescriptionappacr.azurecr.io/backend:latest
docker push contextualimagedescriptionappacr.azurecr.io/frontend:latest
docker push contextualimagedescriptionappacr.azurecr.io/ai-service:latest
```

## 🔍 Monitoring

### Logs Azure
```bash
# Backend logs
az webapp log tail --name contextualimagedescriptionapp-backend --resource-group ContextualImageDescriptionApp-RG

# Frontend logs
az webapp log tail --name contextualimagedescriptionapp-frontend --resource-group ContextualImageDescriptionApp-RG

# AI Service logs
az webapp log tail --name contextualimagedescriptionapp-ai --resource-group ContextualImageDescriptionApp-RG
```

### Statut des applications
```bash
az webapp list --resource-group ContextualImageDescriptionApp-RG --output table
``` 