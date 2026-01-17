@echo off
REM Script untuk menjalankan aplikasi DeepFace Face Verification

echo.
echo ===================================
echo   DeepFace Face Verification App
echo ===================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Docker detected
    echo.
    echo Pilih cara untuk menjalankan aplikasi:
    echo.
    echo 1. Docker Compose (Recommended - most easy)
    echo 2. Manual Mode (Backend + Frontend separate)
    echo 3. Exit
    echo.
    set /p choice="Pilih (1/2/3): "
    
    if "%choice%"=="1" goto docker_mode
    if "%choice%"=="2" goto manual_mode
    if "%choice%"=="3" goto exit
    goto invalid_choice
) else (
    echo [✗] Docker tidak terdeteksi
    echo.
    echo Jalankan aplikasi secara manual:
    echo.
    goto manual_mode
)

:docker_mode
echo.
echo ===================================
echo   Starting with Docker Compose
echo ===================================
echo.
cd /d "%~dp0"
docker-compose up
goto exit

:manual_mode
echo.
echo ===================================
echo   Manual Mode - Terminal 1: Backend
echo ===================================
echo.
echo Jalankan backend di terminal baru:
echo.
echo   cd backend
echo   pip install -r requirements.txt
echo   python app.py
echo.
echo Backend akan berjalan di: http://localhost:5000
echo.
echo ===================================
echo   Manual Mode - Terminal 2: Frontend
echo ===================================
echo.
echo Setelah backend berjalan, buka terminal baru dan jalankan:
echo.
echo   cd frontend
echo   npm install
echo   npm start
echo.
echo Frontend akan berjalan di: http://localhost:3000
echo.
pause
goto exit

:invalid_choice
echo.
echo [✗] Pilihan tidak valid
echo.
goto exit

:exit
echo.
echo Exit. Goodbye!
echo.
pause
