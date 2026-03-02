@echo off
echo ========================================
echo   CCTV Productivity Dashboard Launcher
echo ========================================
echo.

REM Change to script directory
cd /d "%~dp0"

echo [1/3] Building and starting Docker containers...
docker-compose up --build -d

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to start containers. Please make sure Docker Desktop is running.
    pause
    exit /b 1
)

echo [2/3] Waiting for services to be ready...
echo (Data will be auto-seeded on first startup)
timeout /t 15 /nobreak > nul

echo [3/3] Opening dashboard in browser...
start http://10.140.55.22:3000

echo.
echo ========================================
echo   Dashboard is now running!
echo   Access at: http://10.140.55.22:3000
echo   Or: http://localhost:3000
echo ========================================
echo.
echo Press any key to close this window...
pause > nul
