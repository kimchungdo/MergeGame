@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "APK_PATH=%PROJECT_DIR%\dist\android\MergeCoreMVP0.00.0.apk"

call "%SCRIPT_DIR%godot_path.local.bat" 2>nul
if not defined GODOT_PATH (
    echo [오류] tools\godot_path.local.bat 파일이 없거나 GODOT_PATH가 설정되지 않았습니다.
    echo        godot_path.local.bat.example 을 참고해 godot_path.local.bat 를 만드세요.
    exit /b 1
)

if not exist "%GODOT_PATH%" (
    echo [오류] Godot 실행 파일을 찾을 수 없습니다: %GODOT_PATH%
    exit /b 1
)

if not exist "%PROJECT_DIR%\dist\android" mkdir "%PROJECT_DIR%\dist\android"

echo [1/1] Android APK 빌드 중...
echo =========================================
"%GODOT_PATH%" --headless --path "%PROJECT_DIR%" --export-debug "MergeGameAPK"

if %errorlevel% neq 0 (
    echo [실패] 빌드 중 오류가 발생했습니다.
    exit /b %errorlevel%
)

if not exist "%APK_PATH%" (
    echo [실패] APK 파일이 생성되지 않았습니다: %APK_PATH%
    exit /b 1
)

echo =========================================
echo [완료] 빌드 성공: %APK_PATH%
endlocal
