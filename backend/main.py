import json
import os
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from utils.predict import predict

BASE_DIR          = os.path.dirname(os.path.abspath(__file__))
DISEASE_INFO_PATH = os.path.join(BASE_DIR, "disease_info.json")

with open(DISEASE_INFO_PATH) as f:
    DISEASE_INFO = json.load(f)

CONFIDENCE_THRESHOLD = 0.60

app = FastAPI(title="Fish Disease Detection API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class PredictionResponse(BaseModel):
    disease: str
    confidence: float
    is_confident: bool
    severity: str
    description: str
    symptoms: list[str]
    treatment: str
    prevention: str
    urgency: str
    all_scores: dict


class DiseaseInfo(BaseModel):
    name: str
    severity: str
    description: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/diseases", response_model=list[DiseaseInfo])
def list_diseases():
    return [
        DiseaseInfo(name=name, severity=info["severity"], description=info["description"])
        for name, info in DISEASE_INFO.items()
        if name != "Healthy Fish"
    ]


@app.post("/predict", response_model=PredictionResponse)
async def predict_disease(file: UploadFile = File(...)):
    image_bytes = await file.read()
    if len(image_bytes) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Image too large. Max 10MB.")
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Empty file received.")

    result = predict(image_bytes)
    label      = result["label"]
    confidence = result["confidence"]
    info       = DISEASE_INFO.get(label, {})

    return PredictionResponse(
        disease=label,
        confidence=round(confidence * 100, 2),
        is_confident=confidence >= CONFIDENCE_THRESHOLD,
        severity=info.get("severity", "Unknown"),
        description=info.get("description", ""),
        symptoms=info.get("symptoms", []),
        treatment=info.get("treatment", ""),
        prevention=info.get("prevention", ""),
        urgency=info.get("urgency", ""),
        all_scores={k: round(v * 100, 2) for k, v in result["all_scores"].items()},
    )
