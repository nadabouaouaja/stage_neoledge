import requests

def generate_description_with_ollama(prompt, model="llama3"):
    url = "http://localhost:11434/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }
    response = requests.post(url, json=payload)
    response.raise_for_status()
    return response.json()["response"]

def generate_description(image_path, objects, text):
    prompt = (
        "Décris l'image en 10 mots, sans expliquer ni introduire, juste la description. "
        f"Objets détectés: {', '.join(objects)}. Texte extrait: {text[:200]}"
    )
    return generate_description_with_ollama(prompt) 