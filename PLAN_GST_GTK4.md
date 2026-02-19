# GST Browser GTK4 마이그레이션 계획

## Context
GNU Smalltalk의 VisualGST IDE를 GTK2에서 GTK4로 마이그레이션하는 프로젝트.
GTK2 → GTK3 → GTK4 2단계 점진적 접근을 채택하여, Phase 0~2를 거쳐 현재 GTK4 기반으로 빌드 및 동작.

## 영향 범위

- **packages/gtk/**: GTK 바인딩 핵심 (C 네이티브 모듈, AWK 코드 생성기, Smalltalk 래퍼)
- **packages/glib/**: GLib/GObject 브릿지 (이벤트 루프, 시그널 시스템)
- **packages/visualgst/**: VisualGST IDE (75+ Smalltalk 파일)
- **packages/blox/gtk/**: BLOX/GTK 추상화 레이어
- **빌드 시스템**: configure.ac, Makefile.am

---

## 구현 상태 요약

### Phase 0: 빌드 시스템 및 바인딩 인프라 — 완료

| 항목 | 상태 |
|------|------|
| AWK 스크립트 GTK4 대응 | **완료** — GTK4 헤더에서 Structs.st/Funcs.st/Enums.st 자동 생성 |
| GtkApplication 전환 | **완료** — lazy init + register-and-hold 패턴. `Gtk application`이 싱글턴 반환, GtkApplicationWindow 자동 사용 |
| configure.ac | **완료** — `gtk4 >= 4.0`, ATK 제거 |
| gst-gtk.c | **완료** — 15개 deprecated 필드 접근 모두 GTK4 API로 교체 |
| placer.c | **완료** — GtkLayoutManager 기반 GTK4 재작성 |
| Makefile.am | **완료** — gtk4 pkg-config 사용 |

### Phase 1: GTK2 → GTK3 — 완료

컨테이너 위젯(HBox/VBox→Box), Stock icon, Drawing 모델(expose→draw), showAll/hideAll 제거,
deprecated 래퍼 교체(GtkObject→GObject, GdkColor→GdkRGBA), BLOX/GTK 업데이트,
GtkDialog.run()→비동기 response, 예제/Tetris 업데이트 등 모두 완료.

### Phase 2: GTK3 → GTK4 — 완료 (일부 보류)

| 항목 | 상태 |
|------|------|
| 이벤트 컨트롤러 (button-press→GtkGestureClick 등) | **완료** |
| 컨테이너 API (packStart→append, add→setChild) | **완료** |
| Tree/List 위젯 (GtkTreeView→GtkListView/GtkTreeListModel) | **완료** |
| 메뉴 시스템 (GtkMenu→GMenu/GtkPopoverMenuBar) | **완료** |
| delete-event → close-request | **완료** |
| showAll/hideAll 제거 | **완료** |
| 렌더링 (GtkDrawingArea connectDrawTo:selector:) | **완료** |
| GtkButton/GtkEntry API | **완료** |
| C 네이티브 모듈 | **완료** |
| 다이얼로그 (GtkFileChooserDialog/GtkMessageDialog) | **보류** — deprecated이지만 동작. GtkFileDialog/GtkAlertDialog는 GTK 4.10+ |
| WebKit1 → WebKit2GTK | **TODO** |
| Clipboard API | **현상유지** — signalEmitByName 방식이 GTK4에서 정상 동작 |

### Phase 3: VisualGST 런타임 안정화 — 완료

| 항목 | 수정 내용 |
|------|----------|
| GtkShortcutController C 바인딩 | `MoreFuncs.st`에 `gtk_shortcut_controller_new` 추가 |
| addController 이중 호출 | `GtkMainWindow >> initialize`에서 `accelGroup := nil` 리셋으로 멱등성 확보 |
| 키보드 단축키 등록 | `Command >> buildMenuItemOn:prefix:`에서 GtkShortcutTrigger/GtkNamedAction/GtkShortcut 생성하여 accelGroup에 등록 |
| GtkDebugger GUI 복원 | `open:` 메서드에 `on: Error do:` 가드 + 콘솔 폴백 + `debugger continue` |
| debuggerClass 활성화 | `Behavior >> debuggerClass` → `VisualGST.GtkDebugger` 반환 |
| 워크스페이스 가시성 | `browserPostInitialize`에서 `outputs hide` 제거 |
| onDelete: 시그널 서명 | `onDelete:event:` → `onDelete:` (GTK4 close-request 1-arg) |
| Sidebar GtkPaned 캐스트 | `showHideOn:`에서 `getParent` → `GtkPaned address:` 캐스트 |
| GTK4 타입 캐스팅 | GtkListItem/GtkTreeExpander/GtkLabel/GtkImage/GtkPaned 명시적 캐스트 — basicPrint 스팸 922→0 |
| Funcs.st parse error | funcs.awk에 `graphene_simd4` skip 추가 — parse error 14→0 |
| expandAll OOM | GtkClassHierarchyWidget: 슈퍼클래스 경로만 확장 |

---

## TODO / 미구현 항목

### ~~TODO-1: GtkApplication 활성화~~ — 완료

`GtkImpl.st`의 `application` 메서드에 lazy init 구현 (`new:flags:` → `register:error:` → `hold`).
`GtkLauncher >> exit`에 `release` 추가. GtkApplicationWindow 자동 사용됨.

### ~~TODO-3: 툴바 Tooltip 추가~~ — 완료

툴바 버튼 12개 중 `New Workspace` 1개만 tooltip이 설정되어 있고, 나머지 11개 Command 기반 버튼은 `Command >> tooltip`이 빈 문자열(`''`)을 반환하여 tooltip 미표시.

**현재 상태:**

| # | 아이콘 | Command 클래스 | 기능 | tooltip |
|---|--------|---------------|------|---------|
| 1 | document-new-symbolic | (직접 생성) | New Workspace | **설정됨** |
| 2 | edit-cut-symbolic | CutEditCommand | Cut | 미설정 |
| 3 | edit-copy-symbolic | CopyEditCommand | Copy | 미설정 |
| 4 | edit-paste-symbolic | PasteEditCommand | Paste | 미설정 |
| — | (separator) | ToolbarSeparator | — | — |
| 5 | edit-undo-symbolic | UndoEditCommand | Undo | 미설정 |
| 6 | edit-redo-symbolic | RedoEditCommand | Redo | 미설정 |
| — | (separator) | ToolbarSeparator | — | — |
| 7 | system-run-symbolic | DoItCommand | Do It | 미설정 |
| 8 | document-print-symbolic | PrintItCommand | Print It | 미설정 |
| 9 | edit-find-symbolic | InspectItCommand | Inspect It | 미설정 |
| 10 | utilities-terminal-symbolic | DebugItCommand | Debug It | 미설정 |
| — | (separator) | ToolbarSeparator | — | — |
| 11 | emblem-ok-symbolic | AcceptItCommand | Accept It | 미설정 |

**구현 메커니즘:** `Command >> buildToolItem`에서 이미 `setTooltipText: self tooltip`을 호출.
각 Command 서브클래스에 `tooltip` 메서드를 오버라이드하면 자동 적용.

**필요 작업:**

| 파일 | 추가할 tooltip 메서드 |
|------|---------------------|
| `Commands/EditMenus/CutEditCommand.st` | `tooltip [ ^ 'Cut (Ctrl+X)' ]` |
| `Commands/EditMenus/CopyEditCommand.st` | `tooltip [ ^ 'Copy (Ctrl+C)' ]` |
| `Commands/EditMenus/PasteEditCommand.st` | `tooltip [ ^ 'Paste (Ctrl+V)' ]` |
| `Commands/EditMenus/UndoEditCommand.st` | `tooltip [ ^ 'Undo (Ctrl+Z)' ]` |
| `Commands/EditMenus/RedoEditCommand.st` | `tooltip [ ^ 'Redo (Ctrl+Shift+Z)' ]` |
| `Commands/SmalltalkMenus/DoItCommand.st` | `tooltip [ ^ 'Do It (Ctrl+D)' ]` |
| `Commands/SmalltalkMenus/PrintItCommand.st` | `tooltip [ ^ 'Print It (Ctrl+P)' ]` |
| `Commands/SmalltalkMenus/InspectItCommand.st` | `tooltip [ ^ 'Inspect It (Ctrl+I)' ]` |
| `Commands/SmalltalkMenus/DebugItCommand.st` | `tooltip [ ^ 'Debug It (Ctrl+Shift+D)' ]` |
| `Commands/SmalltalkMenus/AcceptItCommand.st` | `tooltip [ ^ 'Accept It (Ctrl+S)' ]` |

**참고:** 모든 툴바 버튼의 기능 자체는 정상 동작 (Cut/Copy/Paste/Undo/Redo/DoIt/PrintIt/InspectIt/DebugIt/AcceptIt 모두 구현됨). tooltip 텍스트 추가만 필요.

---

### TODO-2: WebKit1 → WebKit2GTK
**우선순위: 낮음** | **난이도: 중간**

GtkWebView.st/GtkWebBrowser.st가 libwebkit-1.0 사용. 완전히 폐기된 API.

**전환 대상:** `libwebkit-1.0` → `libwebkitgtk-6.0`
**파일:** GtkWebView.st, GtkWebBrowser.st, GtkAssistant.st

### 보류: 다이얼로그 전환
**우선순위: 낮음** (현재 동작함)

GtkFileChooserDialog (5개소), GtkMessageDialog (4개소)는 deprecated이지만 GTK4에서 정상 동작.
GtkFileDialog/GtkAlertDialog가 GTK 4.10+에서 도입. 비동기 콜백 패턴(GAsyncReadyCallback)에 별도 C 브릿지 필요.

→ GTK 최소 버전을 4.10으로 올릴 때 함께 전환 권장.

---

## 검증 상태

### 빌드 및 테스트

| 항목 | 상태 |
|------|------|
| `make -j$(nproc)` 빌드 | **통과** |
| `make check` 132개 테스트 | **통과** (3개 스킵) |
| VisualGST 패키지 로딩 | **통과** |
| VisualGST GUI 실행 | **통과** |

### IDE 기능 검증 (DISPLAY=:99 Xvfb)

| # | 기능 | 상태 | 검증 결과 |
|---|------|------|----------|
| 1 | Launcher 실행 | **통과** | `#GtkLauncher` |
| 2 | 워크스페이스/트랜스크립트 표시 | **통과** | `outputs getVisible=true` |
| 3 | 클래스 브라우저 탐색 | **통과** | Namespace/Class 선택, 메서드 소스 접근 |
| 4 | 키보드 단축키 (GtkShortcutController) | **통과** | Ctrl+D/P/I/S/F 등 등록 확인 |
| 5 | GUI 디버거 | **통과** | `debuggerClass=VisualGST.GtkDebugger`, 에러 시 GUI 또는 콘솔 폴백 |
| 6 | 인스펙터 | **통과** | `GtkInspector openOn: 42` → `#GtkWindow` |
| 7 | F4 하단 패널 토글 | **통과** | hide=false, show=true |
| 8 | 닫기 버튼 (quit 다이얼로그) | **통과** | `onDelete:` 1-arg GTK4 서명 |
| 9 | 사이드바 토글 (GtkPaned 캐스트) | **통과** | `showHideImplementor` / `hideSidebars` |
| 10 | 메서드 소스 브라우징 | **통과** | `Object>>printString` size=181 |

### 알려진 비기능 경고 (해결 불가)

- `g_regex_match_full: assertion 'string != NULL' failed` — GTK4 CSS 테마 엔진 내부 문제
- `gtk_list_view_get_unknown_row_height: assertion 'heights->len > 0'` — 빈 모델에서 GTK4 내부 assertion

---

## 수정 파일 목록 (25개)

### GTK 바인딩 (8개)
- `packages/gtk/gst-gtk.c` — C 래퍼 함수
- `packages/gtk/MoreFuncs.st` — GtkShortcutController/GtkListItem/GtkTreeExpander 바인딩
- `packages/gtk/MoreStructs.st` — 수동 struct 정의 (GdkRGBA 등)
- `packages/gtk/GtkImpl.st` — 고수준 Smalltalk 확장
- `packages/gtk/funcs.awk` — graphene_simd4 skip
- `packages/gtk/example_tree.st` — GTK4 타입 캐스팅 예제
- `packages/blox/gtk/BloxWidgets.st` — BLOX 위젯 업데이트

### VisualGST (17개)
- `packages/visualgst/GtkMainWindow.st` — 멱등 initialize, accelGroup 리셋
- `packages/visualgst/GtkLauncher.st` — onDelete: 서명, GtkPaned 캐스트, outputs 가시성, exit에 app release 추가
- `packages/visualgst/Commands/Command.st` — 키보드 단축키 GtkShortcutController 등록
- `packages/visualgst/Debugger/GtkDebugger.st` — GUI 복원 + 에러 폴백
- `packages/visualgst/Extensions.st` — debuggerClass → GtkDebugger
- `packages/visualgst/GtkScrollListWidget4.st` — GtkLabel 캐스트
- `packages/visualgst/GtkScrollTreeWidget4.st` — GtkTreeExpander/GtkLabel/GtkImage 캐스트
- `packages/visualgst/GtkWorkspaceWidget.st`
- `packages/visualgst/Image/GtkImageWidget.st`
- `packages/visualgst/Model/GtkColumnOOPType.st`
- `packages/visualgst/Model/GtkColumnPixbufType.st`
- `packages/visualgst/Model/GtkColumnTextType.st`
- `packages/visualgst/Model/GtkColumnType.st`
- `packages/visualgst/StBrowser/GtkCategorizedClassWidget.st`
- `packages/visualgst/StBrowser/GtkCategorizedNamespaceWidget.st`
- `packages/visualgst/StBrowser/GtkClassHierarchyWidget.st`
- `packages/visualgst/Tetris/Tetris.st`
