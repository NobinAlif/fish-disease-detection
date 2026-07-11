import io
import json
import os
import numpy as np
from PIL import Image
import tensorflow as tf

BASE_DIR    = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH  = os.path.join(BASE_DIR, "model", "fish_disease_model.h5")
LABELS_PATH = os.path.join(BASE_DIR, "model", "class_labels.json")

# The disease classifier has no "not a fish" class of its own — it's a
# closed-set 7-way softmax over disease buckets, so any input (including a
# hand or face) gets forced into one of them with some confidence score.
# A real fish photo, even a blurry one, tends to at least weakly match one
# bucket; an unrelated subject usually leaves the model with no bucket to
# lean toward, so its top score sits close to the uniform baseline (1/7 =
# ~14%). Treat predictions at or below that floor as "not a fish" rather
# than naming a disease.
NOT_FISH_CONFIDENCE = 0.25

_model = None
_labels = None

def _load():
    global _model, _labels
    if _model is None:
        _model = tf.keras.models.load_model(MODEL_PATH)
    if _labels is None:
        with open(LABELS_PATH) as f:
            _labels = json.load(f)  # {"0": "Bacterial Red disease", ...}

def preprocess(img: Image.Image) -> np.ndarray:
    resized = img.resize((224, 224))
    arr = np.array(resized, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)

def predict(image_bytes: bytes) -> dict:
    _load()
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    arr = preprocess(img)

    preds = _model.predict(arr, verbose=0)[0]
    top_idx = int(np.argmax(preds))
    confidence = float(preds[top_idx])
    label = _labels[str(top_idx)]
    all_scores = {_labels[str(i)]: round(float(preds[i]), 4) for i in range(len(preds))}
    is_fish = confidence > NOT_FISH_CONFIDENCE
    return {"label": label, "confidence": confidence, "all_scores": all_scores, "is_fish": is_fish}
