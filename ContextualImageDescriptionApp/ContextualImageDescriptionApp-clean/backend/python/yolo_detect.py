import sys
import json
from ultralytics import YOLO

# Usage: python yolo_detect.py <image_path>
def detect(image_path):
    model = YOLO('yolov8x.pt')  # yolov8x is the XL model
    results = model(image_path)
    detections = []
    for result in results:
        for box in result.boxes:
            detection = {
                'label': result.names[int(box.cls[0])],
                'confidence': float(box.conf[0]),
                'bbox': [float(x) for x in box.xyxy[0].tolist()]
            }
            detections.append(detection)
    return detections

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({'error': 'No image path provided'}))
        sys.exit(1)
    image_path = sys.argv[1]
    detections = detect(image_path)
    print(json.dumps({'detections': detections})) 