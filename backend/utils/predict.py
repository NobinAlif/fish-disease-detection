import io
import json
import os
import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow.keras.applications.mobilenet_v2 import (
    MobileNetV2,
    preprocess_input as imagenet_preprocess,
    decode_predictions,
)

BASE_DIR    = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH  = os.path.join(BASE_DIR, "model", "fish_disease_model.h5")
LABELS_PATH = os.path.join(BASE_DIR, "model", "class_labels.json")

# The disease classifier has no "not a fish" class of its own — it's a
# closed-set 7-way softmax over disease buckets, so any input (including a
# hand or face) gets forced into one of them. As a pre-filter, run a
# generic ImageNet classifier and reject only when it is *confident*
# (>NON_FISH_CONFIDENCE) about a specific class that has nothing to do with
# fish. We don't require it to positively recognize "fish": this dataset is
# close-up macro photos of skin/fins/gills that ImageNet often can't
# confidently name either (real fish photos routinely score <30% on their
# own top guess), so treating "ImageNet doesn't say fish" alone as
# disqualifying would reject a lot of legitimate photos too.
FISH_KEYWORDS = (
    "fish", "shark", "ray", "eel", "trout", "salmon", "goldfish", "tench",
    "gar", "puffer", "sturgeon", "anemone", "lionfish", "coho", "barracouta",
    "loach", "carp",
)
NON_FISH_CONFIDENCE = 0.45

_model = None
_labels = None
_gate_model = None

def _load():
    global _model, _labels, _gate_model
    if _model is None:
        _model = tf.keras.models.load_model(MODEL_PATH)
    if _labels is None:
        with open(LABELS_PATH) as f:
            _labels = json.load(f)  # {"0": "Bacterial Red disease", ...}
    if _gate_model is None:
        _gate_model = MobileNetV2(weights="imagenet")

def preprocess(img: Image.Image) -> np.ndarray:
    resized = img.resize((224, 224))
    arr = np.array(resized, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)

def _looks_like_fish(img: Image.Image) -> bool:
    arr = np.array(img.resize((224, 224)), dtype=np.float32)
    arr = imagenet_preprocess(np.expand_dims(arr, axis=0))
    preds = _gate_model.predict(arr, verbose=0)
    name, score = decode_predictions(preds, top=1)[0][0][1:3]
    is_fish_class = any(keyword in name.replace("_", " ").lower() for keyword in FISH_KEYWORDS)
    return is_fish_class or score <= NON_FISH_CONFIDENCE

def predict(image_bytes: bytes) -> dict:
    _load()
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    is_fish = _looks_like_fish(img)

    arr = preprocess(img)
    preds = _model.predict(arr, verbose=0)[0]
    top_idx = int(np.argmax(preds))
    confidence = float(preds[top_idx])
    label = _labels[str(top_idx)]
    all_scores = {_labels[str(i)]: round(float(preds[i]), 4) for i in range(len(preds))}
    return {"label": label, "confidence": confidence, "all_scores": all_scores, "is_fish": is_fish}
