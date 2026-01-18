from fastapi import APIRouter, File, UploadFile, HTTPException
from deepface import DeepFace
import shutil
import uuid
import os
import numpy as np
import traceback

router = APIRouter()

@router.post("/verify")
async def verify(
    img1: UploadFile = File(...),
    img2: UploadFile = File(...),
    model_name: str = "Facenet512",
    detector_backend: str = "retinaface",
    distance_metric: str = "cosine",
    enforce_detection: bool = False,
    align: bool = True,
    normalization: str = "base",
    anti_spoofing: bool = False,
    threshold: str = None  # Custom threshold - akan override default (dikirim sebagai string dari FormData)
):
    img1_path = None
    img2_path = None
    try:
        # Simpan file sementara dengan nama unik
        img1_path = f"{uuid.uuid4().hex}_img1.jpg"
        img2_path = f"{uuid.uuid4().hex}_img2.jpg"

        # Validasi file exist dan readable
        with open(img1_path, "wb") as f1:
            content = await img1.read()
            if not content:
                raise ValueError("img1 file kosong")
            f1.write(content)
            
        with open(img2_path, "wb") as f2:
            content = await img2.read()
            if not content:
                raise ValueError("img2 file kosong")
            f2.write(content)

        # Log informasi file untuk debugging
        print(f"✅ File saved: {img1_path} ({os.path.getsize(img1_path)} bytes)")
        print(f"✅ File saved: {img2_path} ({os.path.getsize(img2_path)} bytes)")

        print(f"\n🔄 Starting verification with parameters:")
        print(f"   - Model: {model_name}")
        print(f"   - Detector Backend: {detector_backend}")
        print(f"   - Distance Metric: {distance_metric}")
        print(f"   - Enforce Detection: {enforce_detection}")
        print(f"   - Align: {align}")
        print(f"   - Normalization: {normalization}")
        print(f"   - Anti-spoofing: {anti_spoofing}")
        print(f"   - Custom Threshold (raw): {threshold}")
        
        # Convert threshold string to float jika ada
        threshold_float = None
        if threshold is not None:
            try:
                threshold_float = float(threshold)
                print(f"   - Converted Threshold: {threshold_float}")
            except (ValueError, TypeError):
                print(f"   - ⚠️ Failed to convert threshold '{threshold}' to float, will use default")
                threshold_float = None
        
        # Prepare verify kwargs
        verify_kwargs = {
            "img1_path": img1_path,
            "img2_path": img2_path,
            "model_name": model_name,
            "detector_backend": detector_backend,
            "distance_metric": distance_metric,
            "enforce_detection": enforce_detection,
            "align": align,
            "normalization": normalization,
            "anti_spoofing": anti_spoofing
        }
        
        # Add custom threshold if successfully converted
        if threshold_float is not None:
            verify_kwargs["threshold"] = threshold_float
            print(f"   - Using custom threshold: {threshold_float}")
        else:
            print(f"   - Using DeepFace default threshold")
        
        result = DeepFace.verify(**verify_kwargs)

        print(f"\n✅ Verification successful!")
        print(f"   - Verified: {result.get('verified', False)}")
        print(f"   - Distance: {result.get('distance', 'N/A')}")
        print(f"   - Threshold: {result.get('threshold', 'N/A')}")
        print(f"   - Model Used: {result.get('model', 'N/A')}")
        print(f"   - Detector Backend: {result.get('detector_backend', 'N/A')}")
        print(f"   - Distance Metric: {result.get('distance_metric', 'N/A')}\n")

        # Clean up
        if os.path.exists(img1_path):
            os.remove(img1_path)
        if os.path.exists(img2_path):
            os.remove(img2_path)

        return result
    except Exception as e:
        # Clean up on error
        if img1_path and os.path.exists(img1_path):
            os.remove(img1_path)
        if img2_path and os.path.exists(img2_path):
            os.remove(img2_path)
        
        error_msg = f"Verification error: {str(e)}"
        print(f"❌ {error_msg}")
        print(f"📋 Traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=400, detail=error_msg)

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
    img_path = None
    try:
        img_path = f"{uuid.uuid4().hex}_img.jpg"
        
        # Read file content
        content = await img.read()
        if not content:
            raise ValueError("img file kosong")
            
        with open(img_path, "wb") as f:
            f.write(content)

        print(f"✅ File saved: {img_path} ({os.path.getsize(img_path)} bytes)")
        print(f"🔄 Starting representation with model={model_name}, backend={detector_backend}")

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

        print(f"✅ Representation successful: {len(formatted_result)} face(s) detected")

        if os.path.exists(img_path):
            os.remove(img_path)
        return formatted_result
    except Exception as e:
        if img_path and os.path.exists(img_path):
            os.remove(img_path)
        
        error_msg = f"Representation error: {str(e)}"
        print(f"❌ {error_msg}")
        print(f"📋 Traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=400, detail=error_msg)


@router.get("/health")
async def health_check():
    """Endpoint untuk memeriksa status backend"""
    try:
        return {
            "status": "ok",
            "message": "Backend is running",
            "deepface_available": True
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "deepface_available": False
        }
