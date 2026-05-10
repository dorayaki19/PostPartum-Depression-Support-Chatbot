@echo off
TITLE PPD Diary Control Panel
SETLOCAL

echo.
echo   🌸 ========================================== 🌸
echo          POSTPARTUM DIARY - CONTROL PANEL
echo   🌸 ========================================== 🌸
echo.

:: --- CONFIGURATION ---
SET BACKEND_DIR=backend
SET FRONTEND_DIR=frontend

:: --- START BACKEND ---
echo [1/2] 🚀 Launching Backend API (FastAPI)...
start "PPD Backend" cmd /k "cd %BACKEND_DIR% && echo Starting API... && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

:: Wait a moment for backend to initialize
timeout /t 2 /nobreak > nul

:: --- START FRONTEND ---
echo [2/2] 🎨 Launching Frontend UI (React)...
start "PPD Frontend" cmd /k "cd %FRONTEND_DIR% && echo Starting React App... && npm start"

echo.
echo ✨ Success! Both services are now running in separate windows.
echo    - API: http://localhost:8000
echo    - UI:  http://localhost:3000
echo.
echo Press any key to close this control panel (Services will keep running).
pause > nul
