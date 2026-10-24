@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_bot.ps1"
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if not "%EXIT_CODE%"=="0" echo Bot baslatilamadi. Yukaridaki hata mesajini kontrol edin.
pause
exit /b %EXIT_CODE%
