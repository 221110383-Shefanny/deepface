"""
Health Check Endpoint untuk Backend
Tambahkan ke routes.py atau main FastAPI app
"""

from fastapi import APIRouter
from datetime import datetime
import psutil
import os

health_router = APIRouter()

@health_router.get("/health")
async def health_check():
    """
    Health check endpoint untuk Kubernetes liveness probe
    Returns:
        JSON dengan status kesehatan aplikasi
    """
    try:
        # Check memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        
        # Check disk usage
        disk = psutil.disk_usage('/')
        disk_percent = disk.percent
        
        # Check CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Status determination
        status = "healthy"
        issues = []
        
        if memory_percent > 90:
            status = "degraded"
            issues.append(f"High memory usage: {memory_percent}%")
        
        if disk_percent > 90:
            status = "degraded"
            issues.append(f"High disk usage: {disk_percent}%")
        
        if cpu_percent > 95:
            status = "degraded"
            issues.append(f"High CPU usage: {cpu_percent}%")
        
        response = {
            "status": status,
            "timestamp": datetime.utcnow().isoformat(),
            "system": {
                "memory_percent": round(memory_percent, 2),
                "disk_percent": round(disk_percent, 2),
                "cpu_percent": round(cpu_percent, 2),
            },
            "issues": issues,
            "service": "deepface-backend"
        }
        
        return response
        
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat(),
            "service": "deepface-backend"
        }


@health_router.get("/readiness")
async def readiness_check():
    """
    Readiness probe untuk Kubernetes
    Check jika aplikasi siap menerima traffic
    """
    try:
        # Import deepface untuk check jika model bisa di-load
        from deepface import DeepFace
        
        # Quick test untuk ensure DeepFace tersedia
        return {
            "ready": True,
            "timestamp": datetime.utcnow().isoformat(),
            "service": "deepface-backend"
        }
    except Exception as e:
        return {
            "ready": False,
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat(),
            "service": "deepface-backend"
        }


@health_router.get("/info")
async def info():
    """
    Info endpoint untuk debugging
    """
    return {
        "service": "deepface-backend",
        "version": "1.0.0",
        "environment": os.getenv("FLASK_ENV", "development"),
        "timestamp": datetime.utcnow().isoformat()
    }
