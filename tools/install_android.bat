@echo off
chcp 65001 > nul
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "APK_PATH=%PROJECT_DIR%\dist\android\MergeCoreMVP0.00.0.apk"
set "PACKAGE_NAME=com.example.mergecoremvp"

if not exist "%APK_PATH%" (
    echo [오류] APK 파일이 없습니다. 먼저 build_android.bat 를 실행하세요.
    echo        경로: %APK_PATH%
    exit /b 1
)

echo [1/2] 연결된 Android 기기 확인...
echo =========================================
adb devices

echo.
echo [2/2] APK 설치 및 실행...
echo =========================================
adb install -r "%APK_PATH%"
if %errorlevel% neq 0 (
    echo [실패] APK 설치에 실패했습니다.
    exit /b %errorlevel%
)

adb shell am start -n "%PACKAGE_NAME%/com.godot.game.GodotApp"

echo =========================================
echo [완료] 앱 실행 요청을 보냈습니다. 기기 화면을 확인하세요.
endlocal
