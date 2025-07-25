# ContextualImageDescriptionApp
A simplified web application for document management with AI-powered image object detection and contextual description generation.

## Technologies
- **Backend**: .NET, C#, Python (YOLO, LLM)
- **Frontend**: Vue.js, Node.js
- **Database**: SQL Server
- **Tools**: Git, GitHub, Azure DevOps, Docker

## Get Started
### Frontend Setup
1. Navigate to frontend/: `cd frontend`
2. Install dependencies: `npm install`
3. Run dev server: `npm run serve`

### Backend Setup
1. Navigate to backend/IntelliDocBackend/: `cd backend/IntelliDocBackend/`
2. Install dependencies: `dotnet restore`
3. Apply database migrations to create the database and tables: `dotnet ef database update`
4. Run the backend: `dotnet run`
