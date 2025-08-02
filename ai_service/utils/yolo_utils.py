from ultralytics import YOLO

def detect_objects(image_path, model_path='yolov8x.pt'):
    model = YOLO(model_path)
    results = model(image_path)
    objects = set()
    for r in results:
        for c in r.boxes.cls:
            objects.add(model.names[int(c)])
    return list(objects) 