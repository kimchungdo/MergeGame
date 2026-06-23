@echo off
echo =========================================
echo [1/3] 고도 엔진 APK 빌드 시작...
echo =========================================
# 본인의 고도 엔진 실행 파일 경로로 대체 가능
godot --headless --export-debug "Android" "apk/MergeGame.apk"

if %errorlevel% neq 0 (
    echo [❌] 빌드 실패! 에러를 확인하세요.
    pause
    exit /b %errorlevel%
)

echo.
echo =========================================
echo [2/3] 연결된 안드로이드 폰에 설치 중... (USB 연결 확인)
echo =========================================
# -r 옵션은 기존 앱이 있으면 지우지 않고 덮어씌우는(replace) 옵션입니다.
adb install -r "apk/MergeGame.apk"

if %errorlevel% neq 0 (
    echo [❌] 폰에 설치 실패! USB 디버깅 연결을 확인하세요.
    pause
    exit /b %errorlevel%
)

echo.
echo =========================================
echo [3/3] 폰에서 게임 자동 실행!
echo =========================================
# 내 게임을 폰에서 강제로 켜는 명령어입니다. (패키지명은 고도 프로젝트 설정에서 확인 가능)
# 기본 패키지명 구조는 org.godotengine.프로젝트이름 입니다.
adb shell am start -n "org.godotengine.mergegame/com.godot.game.GodotApp"

echo [ can ] 모든 작업 완료! 
pause