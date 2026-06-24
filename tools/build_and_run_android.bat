@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%build_android.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

call "%SCRIPT_DIR%install_android.bat"
exit /b %errorlevel%
