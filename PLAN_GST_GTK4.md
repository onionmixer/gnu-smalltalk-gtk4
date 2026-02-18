# GST Browser GTK4 마이그레이션 계획

## Context
GNU Smalltalk의 VisualGST IDE는 GTK2 기반으로 구현되어 있다. GTK2는 이미 EOL 상태이며 최신 Linux 배포판에서 지원이 중단되고 있다. GTK4로의 마이그레이션을 통해 최신 플랫폼 지원, 성능 향상(GPU 렌더링), 현대적 UI 패턴을 확보해야 한다.

## 영향 범위

마이그레이션은 다음 패키지들에 영향을 미친다:
- **packages/gtk/**: GTK 바인딩 핵심 (C 네이티브 모듈, AWK 코드 생성기, Smalltalk 래퍼)
- **packages/glib/**: GLib/GObject 브릿지 (이벤트 루프, 시그널 시스템)
- **packages/visualgst/**: VisualGST IDE (75+ Smalltalk 파일)
- **packages/blox/gtk/**: BLOX/GTK 추상화 레이어 (GtkUIManager, GtkAction 사용)
- **packages/cairo/**: Cairo 그래픽 바인딩 (GdkDrawable 경유)
- **빌드 시스템**: configure.ac, Makefile.am, m4 매크로

## 마이그레이션 전략: GTK2 → GTK3 → GTK4 (2단계 점진적 접근)

직접 GTK2→GTK4 전환은 변경량이 너무 크고 중간 테스트가 불가능하다. GTK3을 경유하는 점진적 접근을 채택한다.

---

## Phase 0: 빌드 시스템 및 바인딩 인프라 (기반 작업)

### 0-1. GObject Introspection 기반 바인딩으로 전환 검토
- 현재: AWK 스크립트(cpp.awk, structs.awk, funcs.awk, mk_enums.awk)가 GTK2 헤더를 파싱하여 Smalltalk 바인딩 자동 생성
- 문제: AWK 스크립트를 GTK3/4 헤더에 맞게 수정하는 것은 비현실적
- 해결안: 기존 packages/gir/ (GIR.st)의 GObject Introspection 지원을 활용하여 런타임 바인딩 생성
- 대안: AWK 스크립트를 GTK3/4 헤더와 호환되도록 수정 (더 보수적인 접근)

**GIR 실현 가능성 평가 (packages/gir/GIR.st, 1103 lines):**

현재 GIR 모듈은 **참조 구현** 수준이며, 프로덕션 바인딩 생성에는 추가 개발이 필요하다.

| 구성요소 | 구현 상태 | 비고 |
|----------|----------|------|
| Typelib 로딩 (GITypelib) | 완료 | `require:version:flags:error:` 동작 |
| 메타데이터 조회 (GIRepository) | 완료 | `findByName:`, `getInfo:` 동작 |
| 타입 정보 (GITypeInfo) | 완료 | 21개 primitive type tag 지원 |
| 함수 시그니처 조회 | 완료 | `getSymbol`, `getNArgs`, `getReturnType` |
| 고수준 바인딩 생성기 | **미구현** | 클래스/메서드 자동 생성 코드 없음 |
| 동적 함수 호출 래퍼 | **미구현** | `g_function_info_invoke` raw C 호출만 존재 |
| 타입 변환기 (giTypeTag → FFI) | **미구현** | Smalltalk FFI 타입과의 자동 매핑 없음 |
| 시그널/콜백 지원 | **미구현** | Smalltalk 클로저를 C 콜백으로 변환하는 코드 없음 |
| 프로퍼티 getter/setter | **미구현** | GObject 프로퍼티 자동 접근 없음 |

**결론:** GIR 기반 전환에는 약 2000-3000 줄의 추가 Smalltalk 코드가 필요하다. 단기적으로는 AWK 스크립트를 GTK4 헤더에 맞게 수정하는 것이 더 현실적이며, GIR 전환은 중장기 목표로 설정한다.

**권장 접근법 (하이브리드):**
1. **Phase 1 (GTK3):** AWK 스크립트를 GTK3 헤더와 호환되도록 수정 (structs.awk, funcs.awk의 클래스 매핑 업데이트)
2. **Phase 2 (GTK4):** AWK 스크립트로 기본 바인딩 생성 + 수동으로 누락 API 보완
3. **향후:** GIR 기반 동적 바인딩 생성기 완성

### 0-1b. GtkApplication 전환 (GTK4 필수)

GTK4에서는 `GtkApplication`이 필수이다. 현재 VisualGST는 `Gtk main` 루프를 직접 호출하는 구조이므로 전환이 필요하다.

```smalltalk
"변경 전 (GTK2/3):"
GtkWindow new: Gtk gtkWindowToplevel.
...
Gtk main.

"변경 후 (GTK4):"
app := GTK.GtkApplication new: 'org.gnu.smalltalk.visualgst' flags: 0.
app connectSignal: 'activate' to: self selector: #'onActivate:'.
app run: 0 argv: nil.
```

**영향:**
- `packages/visualgst/GtkLauncher.st` — 진입점 전면 재구성
- `packages/glib/gst-glib.c` — 2스레드 이벤트 루프를 GtkApplication 런루프와 통합
- `packages/gtk/gst-gtk.c` — `gtk_init()` 대신 `gtk_application_new()` 사용

### 0-2. configure.ac 수정
- `AM_PATH_GTK_2_0(2.0.0, ...)` → `PKG_CHECK_MODULES([GTK], [gtk+-3.0 >= 3.24])` (Phase 1)
- 이후 `PKG_CHECK_MODULES([GTK], [gtk4 >= 4.0])` (Phase 2)
- build-aux/gtk-2.0.m4 → gtk-3.0.m4 또는 pkg-config 직접 사용
- **ATK 라이브러리 분리:** GTK4에서 ATK는 별도 라이브러리가 아닌 GTK 코어에 통합됨
  - `Makefile.am` line 17의 `$(ATK_LIBS)` 제거
  - `gst-gtk.c`의 `#include <atk/atk.h>` 제거
  - `Makefile.am`의 `GTK_FILES`에서 ATK 헤더 제거

### 0-3. C 네이티브 모듈 업데이트

**`packages/gtk/gst-gtk.c` (핵심 수정 대상):**
- `gtk_init_check(&argc, &argv)` 유지 (GTK3 호환)
- `widget->window` 직접 접근 (line 213) → `gtk_widget_get_window(widget)`
- `GTK_WIDGET_STATE(widget)` (line 219) → `gtk_widget_get_state_flags(widget)`
- `GTK_WIDGET_FLAGS(widget)` (line 225) → 개별 getter 사용 (`gtk_widget_get_visible()` 등)
- `GTK_WIDGET_SET_FLAGS`/`GTK_WIDGET_UNSET_FLAGS` (lines 231, 237) → 제거 (GTK3에서 삭제됨)
- `GTK_WIDGET(wgt)->allocation` 직접 접근 (line 244) → `gtk_widget_get_allocation(widget, &alloc)`
- `GTK_DIALOG(dlg)->vbox` (line 250) → `gtk_dialog_get_content_area(dlg)`
- `GTK_DIALOG(dlg)->action_area` (line 256) → `gtk_dialog_get_action_area(dlg)` (GTK3) / 제거 (GTK4)
- `GTK_SCROLLED_WINDOW(swnd)->hscrollbar_visible` (line 262) → 정책 기반 확인
- `GTK_ADJUSTMENT(adj)->lower/upper/page_size` (lines 274-286) → `gtk_adjustment_get_lower()` 등
- `container_get/set_child_property` → GTK4에서 GtkContainer 자체가 제거됨

**`packages/gtk/placer.c` (커스텀 위젯 - 대대적 재작성 필요):**
- GTK2 스타일의 커스텀 GtkContainer 서브클래스 (기하학 관리자)
- `widget->parent`, `widget->window`, `widget->allocation`, `widget->style` 직접 접근
- `GTK_WIDGET_SET_FLAGS`, `GTK_WIDGET_NO_WINDOW`, `GTK_WIDGET_VISIBLE`, `GTK_WIDGET_REALIZED` 매크로
- `gtk_style_attach()`, `gtk_style_set_background()` → CSS 기반 스타일링
- `gtk_widget_get_colormap()` → GTK3에서 제거됨
- `gdk_window_new()`, `gdk_window_set_user_data()` → GTK4에서 GdkSurface 기반
- `gtk_widget_size_request()`, `gtk_widget_get_child_requisition()` → `gtk_widget_measure()`
- `GTK_CONTAINER(placer)->border_width` 직접 접근 → `gtk_container_get_border_width()`
- **GTK4 전환 시**: GtkContainer 상속이 불가능하므로 GtkLayoutManager 기반으로 완전 재작성

**`packages/glib/gst-gobject.c`**: GObject 브릿지는 대부분 호환 (최소 변경)
**`packages/glib/gst-glib.c`**: 이벤트 루프는 GLib 기반이므로 대부분 호환

### 0-4. Makefile.am 수정
- `packages/gtk/Makefile.am`: GTK3 pkg-config 플래그 사용
- AWK 생성 대상 파일(Structs.st, Enums.st, Funcs.st) 재생성 또는 GIR 기반으로 전환
- `GTK_FILES` 변수의 헤더 경로 업데이트

### 대상 파일
```
configure.ac
packages/gtk/Makefile.am
packages/gtk/gst-gtk.c          ← C 래퍼 함수 15개 수정 (deprecated 필드 접근)
packages/gtk/placer.c            ← 커스텀 위젯 전면 재작성 (800+ lines)
packages/gtk/placer.h
packages/glib/gst-gobject.c
packages/glib/gst-glib.c
packages/gtk/package.xml
packages/gtk/GtkDecl.st
packages/gtk/MoreStructs.st     ← GdkColor → GdkRGBA 변환
packages/gtk/MoreFuncs.st       ← GtkObject/GdkDrawable deprecated 메서드 교체
build-aux/gtk-2.0.m4 (또는 제거)
```

---

## Phase 1: GTK2 → GTK3 마이그레이션

### 1-1. 컨테이너 위젯 교체 (17+ 파일)

**GtkHBox/GtkVBox → GtkBox:**
```smalltalk
"변경 전:"
GTK.GtkHBox new: true spacing: 3
GTK.GtkVBox new: false spacing: 0

"변경 후:"
GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal homogeneous: true spacing: 3
GTK.GtkBox new: GTK.Gtk gtkOrientationVertical homogeneous: false spacing: 0
```

**GtkHPaned/GtkVPaned → GtkPaned:**
```smalltalk
"변경 전:"
GTK.GtkHPaned new
GTK.GtkVPaned new

"변경 후:"
GTK.GtkPaned new: GTK.Gtk gtkOrientationHorizontal
GTK.GtkPaned new: GTK.Gtk gtkOrientationVertical
```

**대상 파일 (VisualGST):**
```
packages/visualgst/GtkMainWindow.st
packages/visualgst/GtkNotebookWidget.st
packages/visualgst/GtkEntryDialog.st
packages/visualgst/GtkEntryWidget.st
packages/visualgst/GtkPackageBuilderWidget.st
packages/visualgst/GtkLauncher.st
packages/visualgst/Text/GtkTextWidget.st
packages/visualgst/Text/GtkTextPluginWidget.st
packages/visualgst/Text/GtkReplaceWidget.st
packages/visualgst/Text/GtkFindWidget.st
packages/visualgst/Image/GtkImageWidget.st
packages/visualgst/StBrowser/GtkClassBrowserWidget.st
packages/visualgst/Inspector/GtkInspector.st
packages/visualgst/Debugger/GtkDebugger.st
packages/visualgst/Debugger/GtkContextWidget.st
```

### 1-2. Stock Icon 교체

```smalltalk
"변경 전:"
GTK.GtkImage newFromStock: GTK.Gtk gtkStockClose size: GTK.Gtk gtkIconSizeMenu

"변경 후:"
GTK.GtkImage newFromIconName: 'window-close-symbolic' size: GTK.Gtk gtkIconSizeMenu
```

**매핑 테이블:**
| GTK2 Stock | Freedesktop Icon Name |
|---|---|
| gtkStockClose | window-close-symbolic |
| gtkStockGoBack | go-previous-symbolic |
| gtkStockGoForward | go-next-symbolic |
| gtkStockExecute | system-run-symbolic |
| gtkStockSave | document-save-symbolic |
| gtkStockOpen | document-open-symbolic |
| gtkStockFind | edit-find-symbolic |

### 1-3. Drawing 모델 변경

```smalltalk
"변경 전 (expose_event):"
connectSignal: 'expose_event' to: self selector: #'expose:event:'

expose: aGtkWidget event: aGdkEventExpose [
    aGtkWidget getWindow withContextDo: [ :cr | ... ]
]

"변경 후 (draw signal):"
connectSignal: 'draw' to: self selector: #'draw:context:'

draw: aGtkWidget context: aCairoContext [
    "Cairo context 직접 사용"
    ... Cairo drawing code ...
    ^ true
]
```

**대상 파일:**
```
packages/visualgst/Clock/GtkClock.st
packages/gtk/GtkImpl.st (예제 코드)
```

### 1-4. GtkStatusbar 교체

```smalltalk
"변경 전:"
statusBar := GTK.GtkStatusbar new.
statusBar push: 0 text: 'message'.

"변경 후: GtkBox + GtkLabel 조합"
statusBar := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal homogeneous: false spacing: 0.
statusLabel := GTK.GtkLabel new: ''.
statusBar packStart: statusLabel expand: true fill: true padding: 5.
```

**대상 파일:**
```
packages/visualgst/GtkMainWindow.st
```

### 1-5. 위젯 가시성 API 변경

```smalltalk
"GTK2: show/showAll"
widget show.
widget showAll.

"GTK3: 동일하나 set_visible 권장"
widget setVisible: true.
```

### 1-6. Deprecated Smalltalk 래퍼 교체 (GtkImpl.st, MoreFuncs.st, MoreStructs.st)

**MoreFuncs.st 수정 사항:**
- `GtkObject extend` (lines 33-76): `gtk_signal_emit*` 함수들 → `g_signal_emit*` GObject API로 교체
  - `signalEmit:args:`, `signalEmitByName:args:`, `signalNEmissions:`, `signalEmitStop:` 등
- `GdkDrawable extend` (lines 78-84): `gdk_cairo_create` → GTK3에서는 draw 시그널의 Cairo context 직접 사용
- `GtkWidget extend` (lines 87-126):
  - `getState` → `getStateFlags` (gtk_widget_get_state_flags)
  - `getFlags`/`setFlags:`/`unsetFlags:` → 개별 boolean getter/setter로 분리
- `GtkDialog extend` (lines 189-204):
  - `getVBox` → `getContentArea` (gtk_dialog_get_content_area)
  - `getActionArea` → GTK4에서 제거됨
- `GtkFileChooserDialog extend` (lines 265-275):
  - `getFilename` → GTK4에서 `GtkFileDialog` + GFile 기반으로 변경

**GtkImpl.st 수정 사항:**
- `GtkAlignment class extend` (lines 11-15): GtkAlignment 자체가 deprecated → widget margin/halign/valign 사용
- `GdkDrawable extend` (lines 19-29): `withContextDo:` + `cairoCreate` → draw signal의 context 사용
- `GtkRequisition extend` (lines 89-127): GTK3에서 `gtk_widget_get_preferred_size()` 사용

**MoreStructs.st 수정 사항:**
- `GdkColor` 구조체 (line 57) → `GdkRGBA` (float 0.0-1.0 기반 색상)
  - 필드 변경: `pixel, red, green, blue` (uint16) → `red, green, blue, alpha` (double)

### 1-7. BLOX/GTK 패키지 업데이트 (packages/blox/gtk/)

BLOX/GTK는 VisualGST와 별도로 GTK2 deprecated API를 사용하는 패키지이다.

**BloxWidgets.st 수정 사항:**
- `GTK.GtkVBox`/`GTK.GtkHBox` 사용 (lines 1339-1340, 3413) → GtkBox + orientation
- `GTK.Gtk gtkStockCancel`/`gtkStockOpen`/`gtkStockSave` (lines 4001, 4088, 4126) → icon name
- `GTK.GdkColor` 사용 (lines 971-972) → GdkRGBA
- `GTK.GtkUIManager` (lines 3359, 4340) → GTK4에서 제거됨, GMenu 기반으로 전환
- `GTK.GtkAction` (lines 4535, 4772) → GAction/GSimpleAction으로 전환

**대상 파일:**
```
packages/blox/gtk/BloxWidgets.st
packages/blox/gtk/BloxBasic.st
packages/blox/gtk/BloxText.st
```

### 1-8. 제거된 위젯 클래스 교체

**GtkArrow (example_arrow.st):**
- `GtkArrow` 위젯 완전 제거됨 → Unicode 화살표 문자 또는 아이콘 사용
- `gtkArrowUp/Down/Left/Right` 열거형 제거
- `gtkShadowIn/Out/EtchedIn/EtchedOut` 열거형 제거

**GtkHButtonBox/GtkVButtonBox (example_buttonbox.st, BloxWidgets.st):**
```smalltalk
"변경 전:"
GTK.GtkHButtonBox new.
box setLayout: GTK.Gtk gtkButtonboxSpread.

"변경 후 (GTK3):"
GTK.GtkButtonBox new: GTK.Gtk gtkOrientationHorizontal.
box setLayout: GTK.Gtk gtkButtonboxSpread.

"변경 후 (GTK4): GtkButtonBox 자체가 제거됨"
GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal homogeneous: true spacing: 5.
```

**GtkAlignment (GtkImpl.st lines 11-16):**
- `GtkAlignment new: xalign yalign: yalign xscale: xscale yscale: yscale` → 제거됨
- 대체: `widget setHalign:`, `widget setValign:`, `widget setMarginStart:` 등

**대상 파일:**
```
packages/gtk/example_arrow.st       — GtkArrow 제거
packages/gtk/example_buttonbox.st   — GtkHButtonBox/GtkVButtonBox 제거
packages/blox/gtk/BloxWidgets.st    — GtkHButtonBox 사용 (line 4218)
packages/gtk/GtkImpl.st             — GtkAlignment 래퍼 (lines 11-16)
```

### 1-9. GtkScrolledWindow API 변경

```smalltalk
"변경 전 (GTK2):"
GTK.GtkScrolledWindow new: nil vadjustment: nil.
scrolledWin addWithViewport: widget.

"변경 후 (GTK3): addWithViewport 제거"
GTK.GtkScrolledWindow new.
scrolledWin add: widget. "자동으로 GtkViewport 생성"
```

**대상 파일:**
```
packages/visualgst/Extensions.st        — withViewport: 메서드 (lines 687-696)
packages/gtk/GtkImpl.st                 — withChild: 래퍼 (lines 754-758)
packages/blox/gtk/BloxBasic.st          — addWithViewport: (line 2383)
packages/gtk/example_tree.st            — new: nil vadjustment: nil (line 80)
```

### 1-10. GtkDialog.run() 동기 호출 패턴

```smalltalk
"현재 (GTK2/3):"
result := dialog run.
"run은 내부적으로 modal loop을 실행하고 response를 반환"

"GTK4: run() 제거됨 → 비동기 패턴 필요"
dialog connectSignal: 'response' to: self selector: #'onResponse:responseId:'.
dialog show.
```

**대상 파일:**
```
packages/gtk/GtkImpl.st                 — GtkDialog.run 메서드 (lines 556-591)
packages/visualgst/GtkEntryDialog.st    — dialog run 사용
packages/visualgst/GtkLauncher.st       — 파일 다이얼로그 run
packages/blox/gtk/BloxWidgets.st        — 다이얼로그 run
```

### 1-11. 예제 및 부수 코드 업데이트

**Tetris 게임 (packages/visualgst/Tetris/):**
- `Tetris.st` line 73: `key-press-event` 시그널
- `Tetris.st` line 101: `expose_event` 시그널 → `draw` 시그널

**예제 파일 (packages/gtk/example_*.st):**
- `example_arrow.st`: GtkArrow 제거, stock icon 사용
- `example_buttonbox.st`: GtkHButtonBox/GtkVButtonBox 제거, layout 열거형 제거
- `example_entry.st`: `setFlags: Gtk gtkCanDefault` (line 148), `grabDefault` (line 149) → GTK4에서 제거
- `example_tictactoe.st`: `delete_event` 시그널 → `close-request`
- `example_tree.st`: `GtkScrolledWindow new: nil vadjustment: nil`, `GtkFrame new: nil`
- 모든 예제: `showAll` → `setVisible: true`

---

## Phase 2: GTK3 → GTK4 마이그레이션

### 2-1. 이벤트 처리 시스템 전면 교체

**GtkEventController 기반으로 전환:**

```smalltalk
"변경 전 (GTK2/3 signal):"
widget connectSignal: 'button-press-event' to: self selector: #'onButtonPress:event:'
widget connectSignal: 'key-press-event' to: self selector: #'onKeyPress:event:'

"변경 후 (GTK4 EventController):"
| gesture keyCtrl |
gesture := GTK.GtkGestureClick new.
gesture connectSignal: 'pressed' to: self selector: #'onPressed:x:y:'.
widget addController: gesture.

keyCtrl := GTK.GtkEventControllerKey new.
keyCtrl connectSignal: 'key-pressed' to: self selector: #'onKeyPressed:keycode:state:'.
widget addController: keyCtrl.
```

**이벤트 매핑:**
| GTK2/3 Signal | GTK4 Controller | Signal |
|---|---|---|
| button-press-event | GtkGestureClick | pressed |
| button-release-event | GtkGestureClick | released |
| key-press-event | GtkEventControllerKey | key-pressed |
| motion-notify-event | GtkEventControllerMotion | motion |
| scroll-event | GtkEventControllerScroll | scroll |
| focus-in-event | GtkEventControllerFocus | enter |
| focus-out-event | GtkEventControllerFocus | leave |
| delete-event | GtkWindow | close-request |
| populate-popup | GtkTextView | (GtkPopoverMenu 직접 구현) |

**대상 파일 (이벤트 사용 전체):**
```
packages/visualgst/GtkLauncher.st (key-press-event)
packages/visualgst/GtkMainWindow.st (delete-event)
packages/visualgst/StBrowser/*.st (button-press-event for popups)
packages/visualgst/Text/GtkTextWidget.st (text buffer signals)
packages/visualgst/Inspector/*.st
packages/visualgst/Debugger/*.st
packages/visualgst/Clock/GtkClock.st (expose → draw → snapshot)
```

### 2-2. 컨테이너 API 전면 변경 (가장 광범위한 변경)

GTK4에서 GtkContainer 클래스 자체가 제거되었다. 각 위젯별 child 관리 API를 사용해야 한다.

**GtkBox: packStart/packEnd → append/prepend (77+ 파일, 317 occurrences)**
```smalltalk
"변경 전 (GTK3):"
box packStart: widget expand: true fill: true padding: 0.
box packEnd: widget expand: false fill: false padding: 5.

"변경 후 (GTK4):"
box append: widget.
widget setHexpand: true.
widget setHalign: GTK.Gtk gtkAlignFill.
"padding은 widget setMarginStart:/setMarginEnd: 사용"
```

**GtkPaned: pack1/pack2 → setStartChild/setEndChild**
```smalltalk
"변경 전 (GTK3):"
paned pack1: widget1 resize: true shrink: true.
paned pack2: widget2 resize: true shrink: false.

"변경 후 (GTK4):"
paned setStartChild: widget1.
paned setResizeStartChild: true.
paned setShrinkStartChild: true.
paned setEndChild: widget2.
paned setResizeEndChild: true.
paned setShrinkEndChild: false.
```

**GtkScrolledWindow: add → setChild**
```smalltalk
"변경 전 (GTK3):"
scrolledWindow add: widget.

"변경 후 (GTK4):"
scrolledWindow setChild: widget.
```

**GtkWindow/GtkDialog: add → setChild**
```smalltalk
"변경 전 (GTK3):"
window add: mainBox.

"변경 후 (GTK4):"
window setChild: mainBox.
```

**대상 파일 (packStart/packEnd 사용 전체):**
이 변경은 VisualGST의 거의 모든 위젯 파일에 영향을 미친다 — 77+ 파일에서 317회 이상 사용.

### 2-3. Tree/List 위젯 전면 교체 (가장 큰 작업)

VisualGST는 GtkTreeView를 핵심적으로 사용한다 (클래스 브라우저, 인스펙터 등).

```smalltalk
"변경 전 (GtkTreeView + GtkTreeStore):"
model := GTK.GtkTreeStore createModelWith: {{
    GtkColumnTextType title: 'Name'.
    GtkColumnPixbufType title: 'Icon'
}}.
view := GTK.GtkTreeView createTreeWithModel: model.

"변경 후 (GtkColumnView + GListModel):"
"GListModel 기반 데이터 모델 + GtkSignalListItemFactory 기반 팩토리 사용"
"→ 이 부분은 GST의 GtkTreeModel/GtkListModel 래퍼 클래스를 완전히 재작성해야 함"
```

**영향받는 핵심 파일:**
```
packages/visualgst/GtkScrollTreeWidget.st
packages/visualgst/GtkSimpleListWidget.st
packages/visualgst/GtkTreeModel.st
packages/visualgst/GtkListModel.st
packages/visualgst/Model/GtkColumnType.st
packages/visualgst/Model/GtkColumnTextType.st
packages/visualgst/Model/GtkColumnPixbufType.st
packages/visualgst/Model/GtkColumnOOPType.st
packages/visualgst/StBrowser/GtkCategorizedNamespaceWidget.st
packages/visualgst/StBrowser/GtkCategorizedClassWidget.st
packages/visualgst/StBrowser/GtkCategoryWidget.st
packages/visualgst/StBrowser/GtkMethodWidget.st
packages/visualgst/StBrowser/GtkClassHierarchyWidget.st
packages/visualgst/Inspector/GtkInspectorWidget.st
```

### 2-4. 메뉴 시스템 교체

```smalltalk
"변경 전 (GtkMenu/GtkMenuBar):"
menu := GTK.GtkMenu new.
menuItem := GTK.GtkMenuItem new.
menu append: menuItem.

"변경 후 (GMenu + GtkPopoverMenu):"
"GMenu 모델 기반 메뉴 → GtkPopoverMenuBar로 렌더링"
menuModel := GLib.GMenu new.
menuModel appendItem: (GLib.GMenuItem new: 'Open' action: 'app.open').
menuBar := GTK.GtkPopoverMenuBar newFromModel: menuModel.
```

**대상 파일:**
```
packages/visualgst/Menus/MenuBuilder.st (핵심 재작성)
packages/visualgst/Menus/*.st (모든 메뉴 정의 클래스)
packages/visualgst/GtkMainWindow.st (메뉴바 생성)
packages/visualgst/GtkBrowsingTool.st (기본 메뉴 구조)
```

### 2-5. 다이얼로그 교체

```smalltalk
"변경 전:"
dialog := GTK.GtkFileChooserDialog new: ...
dialog := GTK.GtkMessageDialog new: ...

"변경 후 (비동기 API):"
fileDialog := GTK.GtkFileDialog new.
fileDialog openAsync: parentWindow callback: [ :result | ... ].
```

### 2-6. 툴바 교체

```smalltalk
"변경 전 (GtkToolbar):"
toolbar := GTK.GtkToolbar new.
toolItem := GTK.GtkToolButton newFromStock: 'gtk-save'.
toolbar insert: toolItem pos: -1.

"변경 후 (GtkHeaderBar 또는 일반 GtkBox):"
headerBar := GTK.GtkHeaderBar new.
button := GTK.GtkButton newFromIconName: 'document-save-symbolic'.
headerBar packStart: button.
```

### 2-7. Rendering 파이프라인 (GtkSnapshot)

```smalltalk
"변경 전 (draw signal + Cairo):"
draw: widget context: cr [
    cr moveTo: 10 y: 10.
    cr lineTo: 100 y: 100.
    cr stroke.
]

"변경 후 (GtkSnapshot):"
"GtkDrawingArea에 draw function 설정"
drawingArea setDrawFunc: [ :area :cr :width :height |
    "Cairo context는 여전히 사용 가능하지만 GtkSnapshot 경유"
    cr moveTo: 10 y: 10.
    cr lineTo: 100 y: 100.
    cr stroke.
].
```

### 2-8. showAll/hideAll 제거 (43+ 파일, 202 occurrences)

GTK4에서 `showAll()`과 `hideAll()`이 완전히 제거되었다. 위젯은 기본적으로 visible 상태이며, 개별 위젯에 `setVisible:` 호출이 필요하다.

```smalltalk
"변경 전 (GTK2/3):"
window showAll.
widget hideAll.

"변경 후 (GTK4):"
"GTK4에서 위젯은 기본적으로 visible (show 불필요)"
"숨기려면 개별 위젯에 setVisible: false 호출"
widget setVisible: false.
```

**전략:** `showAll`/`hideAll` 호출을 모두 제거하고, 특정 위젯을 숨겨야 하는 경우에만 `setVisible: false` 사용. GTK4에서는 위젯 생성 시 자동으로 visible이므로 대부분의 `show`/`showAll` 호출이 불필요해진다.

### 2-9. delete-event → close-request 시그널 변경

```smalltalk
"변경 전 (GTK2/3):"
window connectSignal: 'delete-event' to: self selector: #'onDelete:event:'.

"변경 후 (GTK4):"
window connectSignal: 'close-request' to: self selector: #'onCloseRequest:'.
```

**대상 파일:**
```
packages/visualgst/GtkMainWindow.st     — line 204
packages/visualgst/Clock/GtkClock.st    — line 175
packages/gtk/example_*.st              — 여러 파일
packages/gtk/GtkImpl.st                — GtkDialog 내 delete_event 핸들링 (line 575)
```

### 2-10. Clipboard API 비동기 전환

```smalltalk
"변경 전 (GTK2/3):"
textWidget signalEmitByName: 'copy-clipboard' args: {}.
textWidget signalEmitByName: 'paste-clipboard' args: {}.

"변경 후 (GTK4):"
clipboard := widget getClipboard.
clipboard readTextAsync: nil callback: [ :clipboard :result |
    text := clipboard readTextFinish: result ].
```

**대상 파일:**
```
packages/visualgst/Text/GtkTextWidget.st    — copy/paste/cut 시그널 (8 occurrences)
packages/visualgst/Text/GtkFindWidget.st
packages/visualgst/Text/GtkReplaceWidget.st
packages/visualgst/Commands/EditMenus/*.st  — CopyEditCommand, CutEditCommand, PasteEditCommand
```

### 2-11. gtkIconSize 상수 제거

GTK4에서 `GtkIconSize` 열거형이 제거되었다. 아이콘 크기는 CSS로 제어한다.

```smalltalk
"변경 전 (GTK2/3):"
GTK.GtkImage newFromIconName: 'icon-name' size: GTK.Gtk gtkIconSizeMenu.
GTK.GtkImage newFromIconName: 'icon-name' size: GTK.Gtk gtkIconSizeSmallToolbar.

"변경 후 (GTK4):"
GTK.GtkImage newFromIconName: 'icon-name'.
"크기는 CSS로 제어: .large-icons { -gtk-icon-size: 32px; }"
```

**대상 파일:**
```
packages/visualgst/Extensions.st           — line 338 (gtkIconSizeMenu)
packages/visualgst/GtkNotebookWidget.st    — line 96 (gtkIconSizeMenu)
packages/gtk/GtkImpl.st                    — line 1029 (gtkIconSizeSmallToolbar)
```

### 2-12. WebKit1 → WebKit2GTK 마이그레이션

VisualGST의 웹 브라우저 컴포넌트는 완전히 폐기된 WebKit 1.0을 사용한다.

```smalltalk
"변경 전 (WebKit 1.0):"
DLD addLibrary: 'libwebkit-1.0'.
webkit_web_view_new.
webkit_web_view_open: url.

"변경 후 (WebKit2GTK with GTK4):"
DLD addLibrary: 'libwebkitgtk-6.0'.
webkit_web_view_new.
webkit_web_view_load_uri: url.
```

**대상 파일:**
```
packages/visualgst/GtkWebView.st       — 전면 재작성 (libwebkit-1.0 → libwebkitgtk-6.0)
packages/visualgst/GtkWebBrowser.st    — WebView 래퍼 업데이트
packages/visualgst/GtkAssistant.st     — WebView 사용
```

### 2-13. GtkButton/GtkEntry API 변경

**GtkButton:**
```smalltalk
"변경 전:"
button := GTK.GtkButton newWithLabel: 'text'.
button setImage: anImage.
button setRelief: GTK.Gtk gtkReliefNone.

"변경 후 (GTK4):"
button := GTK.GtkButton newWithLabel: 'text'.
button setIconName: 'icon-name'.    "setImage 제거"
button addCssClass: 'flat'.         "setRelief 제거, CSS 기반"
```

**GtkEntry:**
```smalltalk
"변경 전:"
text := entry getText.
entry setFlags: GTK.Gtk gtkCanDefault.
entry grabDefault.

"변경 후 (GTK4):"
text := entry getBuffer getText.   "getText 경유 방식 변경"
"gtkCanDefault/grabDefault 제거됨"
```

### 2-14. GtkFileChooserDialog varargs 생성 패턴

```smalltalk
"변경 전 (GtkImpl.st lines 599-607):"
GtkFileChooserDialog new: aString parent: aGtkWidget
    action: aGtkFileChooserAction
    varargs: {'_Cancel'. Gtk gtkResponseCancel. aButtonLabel. Gtk gtkResponseAccept. nil}

"변경 후 (GTK4): GtkFileDialog 사용"
fileDialog := GTK.GtkFileDialog new.
fileDialog setTitle: aString.
fileDialog openAsync: parentWindow cancellable: nil callback: [ :dialog :result |
    file := dialog openFinish: result ].
```

### 2-15. GtkMessageDialog 생성 패턴

```smalltalk
"변경 전 (GtkImpl.st lines 49-84):"
GTK.GtkMessageDialog new: parentWindow flags: 0 type: Gtk gtkMessageWarning
    buttons: Gtk gtkButtonsOk message: 'Error: %1' % {errorMsg}

"변경 후 (GTK4): GtkAlertDialog 사용"
alertDialog := GTK.GtkAlertDialog new: 'Error: %1' % {errorMsg}.
alertDialog setButtons: #('OK').
alertDialog showAsync: parentWindow cancellable: nil callback: nil.
```

### 2-16. C 네이티브 모듈 GTK4 업데이트
- `gst-gtk.c`: gtk_init_check() → gtk_init() (GTK4에서 항상 성공) — **이미 수정됨**
- container_get/set_child_property 제거 (GTK4에서 없음) — **이미 수정됨**
- tree_model_get_oop → GListModel 기반으로 재작성
- list_store_set_oop → GListStore 기반으로 재작성
- 시그널 클로저 시스템은 GObject 기반이므로 대부분 유지
- accel_group 함수 제거 → GtkShortcutController 기반으로 전환 — **이미 수정됨**

---

## Phase 3: 테스트 및 안정화

### 3-1. 테스트 전략
- Phase 1 완료 후: GTK3 기반으로 전체 VisualGST 기능 테스트
- Phase 2 완료 후: GTK4 기반으로 전체 VisualGST 기능 테스트
- 각 위젯 컴포넌트별 단위 테스트
- 전체 IDE 워크플로우 통합 테스트

### 3-2. 테스트 항목
- [ ] 클래스 브라우저: 네임스페이스/클래스/카테고리/메서드 탐색
- [ ] 소스 코드 편집기: 편집, 구문 강조, 실행 취소/다시 실행
- [ ] 인스펙터: 객체 검사, 다이브, 뒤로가기
- [ ] 디버거: 중단점, 스텝, 계속, 프레임 검사
- [ ] 메뉴 시스템: 모든 메뉴 항목 동작
- [ ] 키보드 단축키: 모든 액셀러레이터
- [ ] 파일 다이얼로그: 열기, 저장, 다른 이름으로 저장
- [ ] 워크스페이스: DoIt, PrintIt, InspectIt
- [ ] 트랜스크립트: 출력 표시
- [ ] 패키지 빌더: 패키지 생성/관리

---

## 리스크 평가

| 리스크 | 심각도 | 대응 방안 |
|--------|--------|----------|
| packStart/packEnd 제거 (317회, 77+ 파일) | **최고** | sed/스크립트 기반 일괄 변환 도구 작성 |
| showAll/hideAll 제거 (202회, 43+ 파일) | **최고** | 일괄 제거 + 필요한 곳만 setVisible: false 추가 |
| GtkTreeView→GtkColumnView 변경 규모 | 높음 | 호환 래퍼 레이어 작성으로 VisualGST 코드 변경 최소화 |
| GtkApplication 필수 전환 | 높음 | GtkLauncher 진입점 재구성 + 이벤트 루프 통합 |
| AWK 코드 생성기가 GTK3/4 헤더와 비호환 | 높음 | AWK 스크립트 수정 (단기) + GIR 전환 (장기) |
| placer.c 커스텀 위젯 전면 재작성 | 높음 | GTK4에서 GtkLayoutManager 기반으로 재설계 |
| GtkDialog.run() 제거 → 비동기 전환 | 높음 | 모든 다이얼로그를 비동기 response 패턴으로 변환 |
| C 네이티브 모듈 deprecated 필드 접근 15개 | 높음 | GTK3 getter API로 교체 — **상당 부분 완료** |
| BLOX/GTK의 GtkUIManager/GtkAction 의존 | 중간 | GMenu/GAction 기반으로 전환 |
| WebKit1 → WebKit2GTK 마이그레이션 | 중간 | 전면 재작성 (격리된 모듈이므로 영향 범위 제한적) |
| 이벤트 처리 패턴 전면 변경 | 중간 | Smalltalk 레벨 호환 래퍼 작성 |
| GdkDrawable→Cairo context 전환 | 중간 | GTK3 draw 시그널에서 context 직접 전달 |
| Clipboard 비동기 API 전환 | 중간 | 텍스트 위젯의 clipboard 연산 비동기화 |
| GLib 이벤트 루프 2스레드 모델 호환 | 낮음 | GLib 기반이므로 대부분 호환 |

---

## 상대적 일정 추정

| Phase | 작업량 | 복잡도 | 주요 병목 |
|-------|--------|--------|----------|
| Phase 0: 빌드 인프라 | 중 | 높 | AWK 스크립트 수정, GtkApplication 전환 |
| Phase 1: GTK2→GTK3 | 중 | 중 | 위젯 교체, deprecated 래퍼, 제거된 클래스 |
| Phase 2: GTK3→GTK4 | **대** | **최고** | packStart(317회), showAll(202회), Tree/List, 메뉴, 비동기 다이얼로그 |
| Phase 3: 테스트/안정화 | 중 | 중 | 전체 기능 회귀 테스트 |

**Phase 2의 작업량 재평가:**
- Container API 변경 (packStart/packEnd + add → append/setChild): **약 30%**
- showAll/hideAll 제거: **약 10%**
- Tree/List 위젯과 메뉴 시스템 교체: **약 30%**
- 다이얼로그 비동기 전환 + 이벤트 컨트롤러: **약 20%**
- 기타 (Clipboard, WebKit, gtkIconSize 등): **약 10%**

---

## 핵심 수정 대상 파일 요약

### C 네이티브 코드 (4 파일)
- `packages/gtk/gst-gtk.c` — C 래퍼 함수 15개 (deprecated 필드 접근 수정)
- `packages/gtk/placer.c` — 커스텀 GtkContainer 위젯 (전면 재작성, 800+ lines)
- `packages/glib/gst-gobject.c` — GObject 브릿지 (최소 변경)
- `packages/glib/gst-glib.c` — 이벤트 루프 (최소 변경)

### 빌드 시스템 (4 파일)
- `configure.ac` — GTK2 → GTK3/4 pkg-config 전환
- `packages/gtk/Makefile.am` — 빌드 플래그, 헤더 경로 업데이트
- `packages/gtk/package.xml` — 패키지 메타데이터
- `build-aux/gtk-2.0.m4` — 제거 또는 교체

### GTK 바인딩 Smalltalk (6 파일)
- `packages/gtk/GtkDecl.st` — 클래스 선언 (GdkDrawable 등)
- `packages/gtk/GtkImpl.st` — GtkAlignment, GdkDrawable, GtkRequisition 래퍼
- `packages/gtk/MoreStructs.st` — GdkColor → GdkRGBA
- `packages/gtk/MoreFuncs.st` — GtkObject signals, widget flags, dialog vbox 등 15+ 메서드
- AWK 스크립트 5개 (`cpp.awk`, `structs.awk`, `funcs.awk`, `mk_enums.awk`, `mk_sizeof.awk`) 또는 GIR 전환

### BLOX/GTK (3 파일)
- `packages/blox/gtk/BloxWidgets.st` — GtkUIManager, GtkAction, Stock, HBox/VBox, GdkColor
- `packages/blox/gtk/BloxBasic.st`
- `packages/blox/gtk/BloxText.st`

### VisualGST (50+ 파일)
- 전체 파일 목록은 Phase별 대상 파일 참조

### 예제 및 부수 코드 (10+ 파일)
- `packages/visualgst/Tetris/Tetris.st` — expose_event, key-press-event
- `packages/visualgst/Clock/GtkClock.st` — expose_event
- `packages/gtk/example_*.st` — 각종 deprecated API 사용

## Deprecated API 완전 목록 (파일별 교차 참조)

### gst-gtk.c 내 deprecated 패턴 (15개 C 함수)
| 현재 코드 | Line | GTK3 교체 | GTK4 교체 |
|-----------|------|----------|----------|
| `widget->window` | 213 | `gtk_widget_get_window()` | `gtk_native_get_surface()` |
| `GTK_WIDGET_STATE()` | 219 | `gtk_widget_get_state_flags()` | 동일 |
| `GTK_WIDGET_FLAGS()` | 225 | 개별 getter | 동일 |
| `GTK_WIDGET_SET_FLAGS()` | 231 | 제거 | 제거 |
| `GTK_WIDGET_UNSET_FLAGS()` | 237 | 제거 | 제거 |
| `GTK_WIDGET(wgt)->allocation` | 244 | `gtk_widget_get_allocation()` | 동일 |
| `GTK_DIALOG(dlg)->vbox` | 250 | `gtk_dialog_get_content_area()` | 동일 |
| `GTK_DIALOG(dlg)->action_area` | 256 | `gtk_dialog_get_action_area()` | 제거 |
| `SCROLLED_WINDOW->hscrollbar_visible` | 262 | 정책 기반 확인 | 동일 |
| `SCROLLED_WINDOW->vscrollbar_visible` | 268 | 정책 기반 확인 | 동일 |
| `GTK_ADJUSTMENT->lower` | 274 | `gtk_adjustment_get_lower()` | 동일 |
| `GTK_ADJUSTMENT->upper` | 280 | `gtk_adjustment_get_upper()` | 동일 |
| `GTK_ADJUSTMENT->page_size` | 286 | `gtk_adjustment_get_page_size()` | 동일 |
| `container_get_child_property()` | 127 | 유지 (GTK3) | GtkContainer 제거됨 |
| `container_set_child_property()` | 146 | 유지 (GTK3) | GtkContainer 제거됨 |

### MoreFuncs.st 내 deprecated 패턴
| 현재 코드 | Line | 교체 방안 |
|-----------|------|----------|
| `GtkObject extend [signalEmit:]` | 33-76 | GObject `g_signal_emit()` 사용 |
| `GdkDrawable extend [cairoCreate]` | 78-84 | draw 시그널의 Cairo context 직접 사용 |
| `GtkWidget [getFlags/setFlags:/unsetFlags:]` | 108-124 | 개별 boolean getter 사용 |
| `GtkDialog [getVBox]` | 191-195 | `getContentArea` |
| `GtkDialog [getActionArea]` | 197-202 | GTK4에서 제거 |
| `GtkContainer [child:propertiesAt:]` | 130-146 | GTK4에서 GtkContainer 제거 |
| `GtkFileChooserDialog [getFilename]` | 265-268 | GTK4: GtkFileDialog + GFile |

### VisualGST 내 이벤트 시그널 사용 위치 (정확한 참조)
| 시그널 | 파일 | Line |
|--------|------|------|
| `expose_event` | Clock/GtkClock.st | 174 |
| `expose_event` | Tetris/Tetris.st | 101 |
| `key-press-event` | GtkLauncher.st | 346 |
| `key-press-event` | Tetris/Tetris.st | 73 |
| `delete-event` | GtkMainWindow.st | 204 |
| `delete-event` | Clock/GtkClock.st | 175 |
| `button-press-event` | GtkConcreteWidget.st | 146 |
| `button-press-event` | GtkHistoryWidget.st | 63 |
| `button-press-event` | SUnit/GtkSUnitResultWidget.st | 48 |

## 변경 규모 통계

| 변경 항목 | 발생 횟수 | 영향 파일 수 | 자동화 가능 여부 |
|-----------|----------|------------|----------------|
| `packStart:/packEnd:` → `append:` | 317 | 77+ | 스크립트로 패턴 변환 가능 |
| `showAll`/`hideAll` 제거 | 202 | 43+ | 일괄 삭제 가능 |
| `connectSignal:` 이벤트 시그널 변경 | 66 | 33+ | 수동 검토 필요 |
| `GtkHBox`/`GtkVBox` → `GtkBox` | ~30 | 17+ | 패턴 치환 가능 |
| `GtkHPaned`/`GtkVPaned` → `GtkPaned` | ~15 | 8+ | 패턴 치환 가능 |
| Stock icon → freedesktop icon name | ~20 | 10+ | 매핑 테이블로 치환 |
| `pack1:/pack2:` → `setStartChild:/setEndChild:` | ~20 | 10+ | 패턴 치환 가능 |
| GtkDialog.run() → 비동기 response | ~10 | 5+ | 수동 재구성 필요 |
| `addWithViewport:` → `setChild:` | ~5 | 4 | 수동 |

## 검증 방법
1. `autoreconf -fiv && ./configure && make -j$(nproc)` 빌드 성공
2. `make check` 테스트 통과
3. `./gst --eval "PackageLoader fileInPackage: 'VisualGST'"` 패키지 로딩
4. VisualGST IDE 실행 및 기능 테스트

## 이미 완료된 작업

### gst-gtk.c GTK4 호환 수정 (완료)
- `widget->window` → `gtk_native_get_surface()` 기반 `widget_get_surface()`
- `GTK_WIDGET_STATE()` → `gtk_widget_get_state_flags()`
- `GTK_WIDGET_FLAGS()` → 개별 getter 조합 (visible, mapped, realized, sensitive, focusable, has_focus)
- `GTK_WIDGET_SET_FLAGS/UNSET_FLAGS` → 개별 setter (set_visible, set_sensitive, set_focusable)
- `GTK_WIDGET(wgt)->allocation` → `gtk_widget_get_width()/get_height()`
- `GTK_DIALOG(dlg)->vbox` → `gtk_dialog_get_content_area()`
- `GTK_DIALOG(dlg)->action_area` 제거
- `SCROLLED_WINDOW->hscrollbar_visible` → `gtk_scrolled_window_get_policy()` 기반
- `GTK_ADJUSTMENT->lower/upper/page_size` → `gtk_adjustment_get_lower()` 등
- `gtk_init_check(&argc, &argv)` → `gtk_init_check()` (no args)
- GtkAccelGroup/GtkContainer child property 함수 제거
- `#include <gdk/gdk.h>`, `#include <atk/atk.h>` 제거

### MoreFuncs.st GTK4 호환 수정 (완료)
- `GtkObject extend` → `GLib.GObject extend` (g_signal_emit_by_name 사용)
- `GdkDrawable extend` → `GTK.GdkWindow extend` (cairoCreate)
