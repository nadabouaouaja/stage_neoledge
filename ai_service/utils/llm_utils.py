import requests

def generate_description_with_ollama(prompt, model="gemma:2b"):
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
        f"<system>You are a direct analyzer. NEVER use phrases like 'Sure, here's', 'Here is', or any introductions. Respond with ONLY the description.</system>\n"
        f"Objects: {', '.join(objects)}. Text: {text[:300]}. "
        "Contextual description in 10 words:"
    )
    return generate_description_with_ollama(prompt, "gemma:2b") 