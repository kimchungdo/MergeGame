# MergeCoreMVP — Cursor Agent 가이드

Godot 4.7 기반 모바일 머지 게임 MVP 프로젝트입니다.  
에이전트는 작업 전 이 문서를 읽고 아래 디렉터리 규칙과 경로 규칙을 따르세요.

## 프로젝트 개요

| 항목 | 값 |
|------|-----|
| 엔진 | Godot 4.7 (Mobile) |
| 언어 | GDScript |
| 메인 씬 | `scenes/main.tscn` (UID: `uid://cdwmd26spkavh`) |
| 해상도 | 1080×1920 (세로, 모바일) |
| Android export preset | `MergeGameAPK` |

## 디렉터리 구조

```
merge-core-mvp/
├── project.godot          # Godot 프로젝트 설정 (루트에 유지)
├── export_presets.cfg     # Android export 설정 (루트에 유지)
│
├── docs/                  # 프로젝트 문서
│   └── AGENTS.md          # 이 문서 — 에이전트용 프로젝트 가이드
│
├── scenes/                # .tscn 씬 파일만
│   ├── main.tscn          # 메인 씬 (그리드, UI)
│   └── item.tscn          # 머지 아이템 씬
│
├── scripts/               # .gd 스크립트만
│   ├── main.gd            # 그리드 로직, 아이템 생성·이동·머지
│   └── item.gd            # MergeItem 클래스, 드래그·레벨업
│
├── assets/                # 게임 리소스 (이미지, 사운드, 폰트)
│   ├── sprites/
│   ├── audio/
│   └── fonts/
│
├── tools/                 # 빌드·배포 스크립트 (Windows .bat)
│   ├── build_android.bat
│   ├── install_android.bat
│   ├── build_and_run_android.bat
│   ├── godot_path.local.bat.example
│   └── godot_path.local.bat   # 로컬 Godot 경로 (Git 제외)
│
└── dist/                  # 빌드 산출물 (Git 제외)
    └── android/
        └── MergeCoreMVP0.00.0.apk
```

### 폴더 역할 요약

| 폴더 | Git 추적 | 용도 |
|------|----------|------|
| `docs/` | O | 프로젝트·에이전트 문서 |
| `scenes/` | O | 씬(`.tscn`) 전용 |
| `scripts/` | O | GDScript(`.gd`) 전용 |
| `assets/` | O | 스프라이트·오디오·폰트 등 리소스 |
| `tools/` | O (일부 제외) | Android 빌드/설치 배치 파일 |
| `dist/` | X | APK 등 배포 산출물 |
| `.godot/` | X | Godot 에디터 캐시 |
| `android/` | X | Godot Gradle 빌드 시 자동 생성 |
| `.cursor/`, `.vscode/` | X | 로컬 IDE·에이전트 설정 |

## 경로·참조 규칙

Godot 리소스 경로는 `res://` 기준입니다.

| 리소스 | 올바른 경로 |
|--------|-------------|
| 메인 씬 | `res://scenes/main.tscn` |
| 아이템 씬 | `res://scenes/item.tscn` |
| 메인 스크립트 | `res://scripts/main.gd` |
| 아이템 스크립트 | `res://scripts/item.gd` |

### 에이전트가 지켜야 할 규칙

1. **새 씬은 `scenes/`, 새 스크립트는 `scripts/`에 추가** — 프로젝트 루트에 `.gd`/`.tscn`을 두지 않습니다.
2. **파일 이동 시 참조 갱신** — `.tscn`의 `ext_resource path`, `.gd`의 `preload()`/`load()` 경로를 함께 수정합니다.
3. **UID 유지** — Godot 4는 `.uid` 파일과 씬 UID를 사용합니다. 파일 이동 시 `.uid` 파일도 같이 옮기고, 가능하면 Godot 에디터에서 이동해 참조가 자동 갱신되게 합니다.
4. **APK는 `dist/android/`에만** — 루트나 `apk/` 같은 임의 폴더에 산출물을 두지 않습니다.
5. **`export_presets.cfg`의 `export_path`** — 현재 `dist/android/MergeCoreMVP0.00.0.apk`로 설정되어 있습니다. APK 파일명을 바꿀 때는 `tools/*.bat`의 `APK_PATH`도 함께 수정합니다.

## 게임 코드 구조

```
main.gd (scenes/main.tscn)
  ├── 9×7 그리드 보드 관리
  ├── 아이템 랜덤 생성 (빈 칸)
  └── request_move_item() — 이동·머지 판정

item.gd (scenes/item.tscn, class_name MergeItem)
  ├── 드래그 앤 드롭
  ├── get_node("/root/Main")으로 main.gd 호출
  └── level_up(), ITEM_DATA 기반 비주얼
```

- `main.gd`는 `preload("res://scenes/item.tscn")`으로 아이템 씬을 로드합니다.
- `item.tscn`은 `res://scripts/item.gd`를 스크립트로 참조합니다.
- `main.tscn`은 `res://scripts/main.gd`를 스크립트로 참조합니다.

## Android 빌드

### 사전 요구사항

- Godot 4.7 (export templates, Android SDK/NDK 설정 완료)
- `adb` (Android SDK platform-tools)
- `tools/godot_path.local.bat` — `godot_path.local.bat.example`을 복사해 `GODOT_PATH` 설정

### 스크립트

| 파일 | 동작 |
|------|------|
| `tools/build_android.bat` | headless export → `dist/android/MergeCoreMVP0.00.0.apk` |
| `tools/install_android.bat` | APK 설치 후 앱 실행 |
| `tools/build_and_run_android.bat` | 위 두 단계 연속 실행 |

### Export 설정 (`export_presets.cfg`)

- Preset 이름: `MergeGameAPK`
- 출력 경로: `dist/android/MergeCoreMVP0.00.0.apk`
- 패키지명: `com.example.mergecoremvp` (`package/unique_name="com.example.$genname"`)
- 설치 스크립트 실행 액티비티: `com.example.mergecoremvp/com.godot.game.GodotApp`

패키지명을 변경하면 `tools/install_android.bat`의 `PACKAGE_NAME`도 맞춰 수정하세요.

## Git 제외 대상 (`.gitignore`)

- `.godot/`, `android/`, `dist/`
- `*.apk`, `*.apk.idsig`, `*.aab`
- `tools/godot_path.local.bat`
- `.cursor/`, `.vscode/` (로컬 IDE·에이전트 설정)
- `bin/`, `build/`, `*.log`

**바이너리 산출물(APK)은 커밋하지 않습니다.**

## 에이전트 작업 시 체크리스트

- [ ] 씬/스크립트를 올바른 폴더(`scenes/`, `scripts/`)에 배치했는가?
- [ ] `res://` 경로 참조를 모두 갱신했는가?
- [ ] APK·빌드 산출물을 `dist/` 밖에 두지 않았는가?
- [ ] `export_presets.cfg`와 `tools/*.bat`의 APK 경로가 일치하는가?
- [ ] 불필요한 루트 파일(`.gd`, `.tscn`)을 새로 만들지 않았는가?

## 관련 설정 파일

| 파일 | 설명 |
|------|------|
| `project.godot` | 앱 이름, 메인 씬 UID, 디스플레이·렌더링 설정 |
| `export_presets.cfg` | Android export preset 전체 설정 |
| `.vscode/settings.json` | VS Code/Cursor용 Godot 에디터 경로 (로컬, Git 제외) |
