import io
import json
import os
import numpy as np
from PIL import Image
import tensorflow as tf

BASE_DIR    = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH  = os.path.join(BASE_DIR, "model", "fish_disease_model.h5")
LABELS_PATH = os.path.join(BASE_DIR, "model", "class_labels.json")

_model = None
_labels = None

def _load():
    global _model, _labels
    if _model is None:
        _model = tf.keras.models.load_model(MODEL_PATH)
    if _labels is None:
        with open(LABELS_PATH) as f:
            _labels = json.load(f)  # {"0": "Bacterial Red disease", ...}

def preprocess(image_bytes: bytes) -> np.ndarray:
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((224, 224))
    arr = np.array(img, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)

def predict(image_bytes: bytes) -> dict:
    _load()
    arr = preprocess(image_bytes)
    preds = _model.predict(arr, verbose=0)[0]
    top_idx = int(np.argmax(preds))
    confidence = float(preds[top_idx])
    label = _labels[str(top_idx)]
    all_scores = {_labels[str(i)]: round(float(preds[i]), 4) for i in range(len(preds))}
    return {"label": label, "confidence": confidence, "all_scores": all_scores}
