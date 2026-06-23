@echo off
:: 윈도우 터미널 한글 깨짐 방지
chcp 65001 > nul

:: ==========================================================
:: [필수 수정] 본인 PC에 있는 고도 엔진 실행 파일의 전체 경로를 적어주세요!
:: 예시: "C:\Godot\Godot_v4.2.1-stable_win64.exe" 형태로 적으시면 됩니다.
:: ==========================================================
set GODOT_PATH="C:\Users\chungdo\Godot_v4.7-stable_win64.exe"


echo [1/3] 고도 엔진 APK 빌드 시작...
echo =========================================

:: 고도 엔진을 직접 실행하여 안드로이드 APK 빌드 명령을 내립니다.
%GODOT_PATH% --headless --export-debug "MergeGameAPK"

if %errorlevel% neq 0 (
    echo [❌] 빌드 실패! 에러를 확인하세요.
    pause
    exit /b %errorlevel%
)

echo.
echo [2/3] 스마트폰 기기 연결 확인 중...
echo =========================================
adb devices

echo.
echo [3/3] 빌드된 APK 폰으로 전송 및 실행...
echo =========================================
:: 빌드 결과물인 apk 파일명과 경로를 프로젝트 세팅에 맞게 확인해 주세요.
adb install -r "android/build/bin/Main.apk"
adb shell am start -n "org.godotengine.main/com.godot.game.GodotApp"

echo =========================================
echo [🎉] 실행 완료! 폰 화면을 확인해 보세요.
pause