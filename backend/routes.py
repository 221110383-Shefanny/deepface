from fastapi import APIRouter, File, UploadFile, HTTPException
from deepface import DeepFace
import shutil
import uuid
import os
import numpy as np

router = APIRouter()

@router.post("/verify")
async def verify(
    img1: UploadFile = File(...),
    img2: UploadFile = File(...),
    model_name: str = "Facenet512",
    detector_backend: str = "retinaface",
    distance_metric: str = "cosine",
    enforce_detection: bool = True,
    align: bool = True,
    normalization: str = "base",
    anti_spoofing: bool = False
):
    try:
        # Simpan file sementara dengan nama unik
        img1_path = f"{uuid.uuid4().hex}_img1.jpg"
        img2_path = f"{uuid.uuid4().hex}_img2.jpg"

        with open(img1_path, "wb") as f1:
            shutil.copyfileobj(img1.file, f1)
        with open(img2_path, "wb") as f2:
            shutil.copyfileobj(img2.file, f2)

        result = DeepFace.verify(
            img1_path=img1_path,
            img2_path=img2_path,
            model_name=model_name,
            detector_backend=detector_backend,
            distance_metric=distance_metric,
            enforce_detection=enforce_detection,
            align=align,
            normalization=normalization,
            anti_spoofing=anti_spoofing
        )

        os.remove(img1_path)
        os.remove(img2_path)

        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/represent")
async def represent(
    img: UploadFile = File(...),
    model_name: str = "Facenet512",
    detector_backend: str = "retinaface",
    enforce_detection: bool = True,
    align: bool = True,
    normalization: str = "base",
    anti_spoofing: bool = False
):
    try:
        img_path = f"{uuid.uuid4().hex}_img.jpg"
        with open(img_path, "wb") as f:
            shutil.copyfileobj(img.file, f)

        result = DeepFace.represent(
            img_path=img_path,
            model_name=model_name,
            detector_backend=detector_backend,
            enforce_detection=enforce_detection,
            align=align,
            normalization=normalization,
            anti_spoofing=anti_spoofing
        )

        formatted_result = []
        for face in result:
            embedding = face.get("embedding")
            if isinstance(embedding, np.ndarray):
                embedding = embedding.tolist()

            formatted_result.append({
                "facial_area": face.get("facial_area"),
                "embedding": embedding
            })

        os.remove(img_path)
        return formatted_result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
