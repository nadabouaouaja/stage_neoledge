# Dockerfile pour le Frontend Vue.js optimisé pour Azure
FROM node:18-alpine AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer toutes les dépendances (dev + prod) pour le build
RUN npm ci

# Copier le code source
COPY . .

# Construire l'application pour la production
RUN npm run build

# Stage de production avec nginx
FROM nginx:alpine AS production

# Copier les fichiers buildés
COPY --from=build /app/dist /usr/share/nginx/html

# Copier la configuration nginx pour Azure
COPY nginx.conf /etc/nginx/nginx.conf

# Exposer le port
EXPOSE 80

# Commande pour démarrer nginx
CMD ["nginx", "-g", "daemon off;"] 