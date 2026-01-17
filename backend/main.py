"""
FastAPI Main Application
Deepface Face Verification Backend Server
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import os
import sys
import traceback

# Import routers
from routes import router as verify_router
from health_check import health_router

# Initialize FastAPI app
app = FastAPI(
    title="DeepFace Backend API",
    description="Face Verification and Recognition Service",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(verify_router)
app.include_router(health_router)

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint - API info"""
    return {
        "message": "DeepFace Backend API",
        "version": "1.0.0",
        "endpoints": {
            "verify": "/verify (POST)",
            "health": "/health (GET)",
            "readiness": "/readiness (GET)",
            "info": "/info (GET)"
        }
    }

# Startup event
@app.on_event("startup")
async def startup_event():
    """Startup event - initialize models if needed"""
    print("🚀 Starting DeepFace Backend Server...")
    print(f"✅ CORS enabled for all origins")
    print(f"📍 Health check available at /health")
    print(f"📍 Readiness check available at /readiness")

# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Shutdown event - cleanup"""
    print("🛑 Shutting down DeepFace Backend Server...")

# Exception handler
@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    """Handle general exceptions"""
    error_detail = str(exc)
    traceback.print_exc()
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": error_detail,
            "type": type(exc).__name__
        }
    )

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 5000))
    
    print(f"\n🌐 Starting server on {host}:{port}\n")
    
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info"
    )
