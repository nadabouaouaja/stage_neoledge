from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
import os
from fastapi.middleware.cors import CORSMiddleware

from utils.pdf_utils import extract_image_and_text
from utils.yolo_utils import detect_objects
from utils.llm_utils import generate_description_with_ollama, generate_description

UPLOADS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../IntelliDocBackend/uploads'))

app = FastAPI()

# Ajout du middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Ou spécifie ["http://localhost:8081"] pour plus de sécurité
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/analyze-pdf/{document_id}")
def analyze_pdf(document_id: int, fileName: str = Query(...)):
    pdf_path = fileName
    if not os.path.exists(pdf_path):
        return JSONResponse({"error": "Fichier PDF non trouvé."}, status_code=404)
    # 2. Extraction image et texte
    images, text = extract_image_and_text(pdf_path)
    if not images:
        return JSONResponse({"error": "Aucune image trouvée dans le PDF."}, status_code=404)
    image_path = images[0]  # Un seul image comme tu l'as précisé
    # 3. Détection objets
    objects = detect_objects(image_path)
    # 4. Génération description via Ollama
    description = generate_description(image_path, objects, text)
    # 5. Retourne tout au frontend
    return JSONResponse({
        "description": description,
        "objects": objects,
        "text": text,
        "image_path": image_path
    })