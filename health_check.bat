@echo off
REM Quick test script untuk verify backend & frontend

echo.
echo ===================================
echo   DeepFace Application Health Check
echo ===================================
echo.

REM Check Backend
echo [1/3] Checking Backend on http://localhost:5000...
timeout /t 1 /nobreak >nul

curl -s http://localhost:5000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Backend is running!
    curl -s http://localhost:5000/health
    echo.
) else (
    echo [✗] Backend is NOT running
    echo Please start backend with: python backend/app.py
    echo.
)

REM Check Frontend
echo [2/3] Checking Frontend on http://localhost:3000...
timeout /t 1 /nobreak >nul

curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Frontend is running!
    echo Open: http://localhost:3000
    echo.
) else (
    echo [✗] Frontend is NOT running
    echo Please start frontend with: npm start
    echo.
)

REM Check Docker
echo [3/3] Checking Docker...
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Docker is installed
    echo To run with Docker: docker-compose up
    echo.
) else (
    echo [✗] Docker is not installed
    echo.
)

echo ===================================
echo   Health Check Complete
echo ===================================
echo.
pause
