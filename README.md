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

### AI Service Setup
1. Navigate to ai_service/: `cd ai_service`
2. Create and activate virtual environment:
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```
   PS: to deactivate the virtual environment: type in the cmd `deactivate`
3. Install Python dependencies: `pip install -r requirements.txt`
4. Run the AI service: `uvicorn main:app --reload`
