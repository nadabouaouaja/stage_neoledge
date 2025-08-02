# Dockerfile pour le Backend .NET Core optimisé pour Azure
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 8080

# Configuration pour Azure App Service
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["IntelliDocBackend/IntelliDocBackend.csproj", "IntelliDocBackend/"]
RUN dotnet restore "IntelliDocBackend/IntelliDocBackend.csproj"
COPY . .
WORKDIR "/src/IntelliDocBackend"
RUN dotnet build "IntelliDocBackend.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "IntelliDocBackend.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "IntelliDocBackend.dll"] 