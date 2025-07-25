from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
import os
import fitz  # PyMuPDF
from ultralytics import YOLO
import subprocess

app = FastAPI()

# Chemin absolu vers le dossier uploads du backend .NET
UPLOAD_DIR = os.path.abspath(os.path.join(
    os.path.dirname(__file__),
    '..', 'IntelliDocBackend', 'uploads'
))

def detect_objects(image_path):
    model = YOLO('yolov8x.pt')  # ou yolov8n.pt pour plus rapide
    results = model(image_path)
    detected = []
    for result in results:
        for box in result.boxes:
            detected.append({
                'label': result.names[int(box.cls[0])],
                'confidence': float(box.conf[0]),
                'bbox': [float(x) for x in box.xyxy[0].tolist()]
            })
    return detected

def generate_with_ollama(prompt: str) -> str:
    """
    Appelle Ollama CLI pour générer du texte avec LLaMA 3
    """
    result = subprocess.run(
        ['ollama', 'run', 'llama3', prompt],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    if result.returncode != 0:
        raise RuntimeError(f"Ollama error: {result.stderr}")
    return result.stdout.strip()

@app.get("/analyze-pdf")
async def analyze_pdf(pdf_filename: str = Query(..., description="Nom du fichier PDF à analyser")):
    pdf_path = os.path.join(UPLOAD_DIR, pdf_filename)
    if not os.path.isfile(pdf_path):
        return JSONResponse({"error": "Fichier PDF non trouvé"}, status_code=404)

    # Dossier pour les images extraites
    images_dir = os.path.join(os.path.dirname(pdf_path), "extracted_images", os.path.splitext(pdf_filename)[0])
    os.makedirs(images_dir, exist_ok=True)

    # Extraction des images et du texte
    doc = fitz.open(pdf_path)
    image_paths = []
    full_text = []
    for page_index in range(len(doc)):
        page = doc[page_index]
        # Texte
        full_text.append(page.get_text())
        # Images
        images = page.get_images(full=True)
        for img_index, img in enumerate(images):
            xref = img[0]
            base_image = doc.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]
            image_filename = f"page{page_index+1}_img{img_index+1}.{image_ext}"
            image_path = os.path.join(images_dir, image_filename)
            with open(image_path, "wb") as img_file:
                img_file.write(image_bytes)
            image_paths.append(image_path)
    doc.close()

    # Détection d'objets sur chaque image extraite
    all_detections = {}
    for image_path in image_paths:
        detections = detect_objects(image_path)
        all_detections[os.path.basename(image_path)] = detections

    # Construction du prompt pour Ollama
    objets_uniques = set()
    for detections in all_detections.values():
        for obj in detections:
            objets_uniques.add(obj['label'])
    prompt = (
        f"Texte extrait du PDF : {full_text[:500]}...\n"  # Limite le texte si besoin
        f"Objets détectés : {', '.join(objets_uniques)}.\n"
        "Génère une description précise et contextuelle de la scène en une ou deux phrases."
    )

    # Appel à Ollama/LLaMA 3
    try:
        description = generate_with_ollama(prompt)
    except Exception as e:
        description = f"Erreur lors de la génération avec Ollama : {e}"

    return JSONResponse({
        "message": "PDF trouvé, texte, images, objets détectés, description générée",
        "pdf_path": pdf_path,
        "texte": "\n".join(full_text),
        "images_extraites": image_paths,
        "objets_detectes": all_detections,
        "description": description
    })
