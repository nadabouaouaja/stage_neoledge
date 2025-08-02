import fitz  # PyMuPDF
import os

def extract_image_and_text(pdf_path):
    doc = fitz.open(pdf_path)
    images = []
    text = ""
    for page in doc:
        text += page.get_text()
        for img_index, img in enumerate(page.get_images(full=True)):
            xref = img[0]
            pix = fitz.Pixmap(doc, xref)
            if pix.n < 5:  # this is GRAY or RGB
                img_path = pdf_path + f"_page{page.number}_img{img_index}.png"
                pix.save(img_path)
                images.append(img_path)
            pix = None
    return images, text 