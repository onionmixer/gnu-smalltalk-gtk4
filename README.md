# GNU Smalltalk — GTK4 Migration Fork

This is a fork of [GNU Smalltalk](https://www.gnu.org/software/smalltalk/) (version 3.2.94) with the GTK bindings and VisualGST IDE migrated from GTK2 to GTK4.

> **Original project**: https://www.gnu.org/software/smalltalk/
> **Original source**: https://alpha.gnu.org/gnu/smalltalk/

## What Changed

The original GNU Smalltalk ships with GTK2-based bindings and a Smalltalk IDE called VisualGST. GTK2 has been EOL since 2011 and is no longer available on modern Linux distributions. This fork migrates the entire GTK stack through GTK2 → GTK3 → GTK4, making the IDE usable on current systems.

### Migration Summary

| Layer | Changes |
|-------|---------|
| **Build system** | `gtk4 >= 4.0` via pkg-config, ATK dependency removed |
| **C native module** (`gst-gtk.c`) | All 15 deprecated struct field accesses replaced with GTK4 API |
| **Layout manager** (`placer.c`) | Rewritten from GtkContainer subclass to GtkLayoutManager |
| **AWK code generators** | Updated to parse GTK4 headers and generate correct bindings |
| **Container API** | `packStart`/`packEnd` → `append`/`prepend`, `add` → `setChild` |
| **Event system** | `button-press-event` → `GtkGestureClick`, `key-press-event` → `GtkEventControllerKey` |
| **Tree/List widgets** | `GtkTreeView` → `GtkListView` + `GtkTreeListModel` + `GtkSignalListItemFactory` |
| **Menu system** | `GtkMenu`/`GtkMenuBar` → `GMenu`/`GtkPopoverMenuBar` |
| **Drawing** | `expose-event`/`draw` → `GtkDrawingArea` with draw function |
| **Application** | `GtkApplication` singleton with lazy init + register-and-hold pattern |
| **Keyboard shortcuts** | `GtkAccelGroup` → `GtkShortcutController` + `GtkShortcut` |
| **Dialogs** | `GtkDialog.run()` → async `showModalOnAnswer:` pattern |
| **VisualGST IDE** | 40+ Smalltalk files updated for GTK4 widget API |

### VisualGST IDE Features (verified)

- Class browser with namespace/class/category/method navigation
- Source code editor with undo/redo
- Workspace and Transcript
- Toolbar with Cut/Copy/Paste/Undo/Redo/DoIt/PrintIt/InspectIt/DebugIt/AcceptIt
- Keyboard shortcuts (Ctrl+D, Ctrl+P, Ctrl+I, Ctrl+S, etc.)
- GUI debugger with console fallback
- Inspector
- Sidebar panels (Implementor, Sender, History, Package Builder)
- Tab management with close confirmation
- Tetris

## Build

### Prerequisites

- GTK4 development libraries (`libgtk-4-dev` on Debian/Ubuntu)
- GLib 2.x development libraries
- Standard C build tools (gcc, make, autoconf, automake, libtool)
- GNU Smalltalk build dependencies (libffi, libsigsegv, libreadline, etc.)
- **Optional**: WebKit2GTK (`libwebkitgtk-6.0-4`) for the built-in web browser and GTK documentation assistant in VisualGST

### Build from Source

```bash
autoreconf -fiv       # only needed after configure.ac changes
./configure
make -j$(nproc)
make check            # 132 tests expected (3 skipped)
```

### Build Debian/Ubuntu Packages

A complete `debian/` packaging directory is included for building `.deb` packages:

```bash
sudo apt install devscripts debhelper libgtk-4-dev libffi-dev \
  libsigsegv-dev libreadline-dev libgmp-dev libltdl-dev \
  libglib2.0-dev libcairo2-dev libsqlite3-dev libgdbm-dev \
  libexpat1-dev zlib1g-dev libncurses-dev gawk bison flex \
  pkg-config zip texinfo

dpkg-buildpackage -us -uc -b
```

This produces 12 binary packages:

| Package | Description |
|---------|-------------|
| `gnu-smalltalk` | Interpreter and CLI tools |
| `libgst7` | VM shared library |
| `libgst-dev` | Development headers and pkg-config |
| `gnu-smalltalk-common` | Shared class library (.star files) |
| `gnu-smalltalk-browser` | VisualGST IDE (GTK4) |
| `gnu-smalltalk-doc` | Documentation (info format) |
| `libgtk4-gst` | GTK4/GLib/Cairo/BLOX bindings |
| `libsqlite3-gst` | SQLite3 database binding |
| `libgdbm-gst` | GDBM database binding |
| `libexpat-gst` | Expat XML parsing binding |
| `libncurses-gst` | NCurses terminal binding |
| `zlib-gst` | Zlib compression binding |

**Optional WebKit support**: Install `libwebkitgtk-6.0-4` to enable the Smallzilla web browser and GTK documentation assistant within VisualGST. WebKit is loaded dynamically at runtime — if the library is not present, VisualGST works normally without the web browsing features.

### Run VisualGST

```bash
LTDL_LIBRARY_PATH="packages/gtk/.libs:packages/glib/.libs:packages/cairo/.libs" \
  ./gst -f start_vgst.st
```

Or use the provided script:

```bash
./start_vgst.sh
```

## Project Structure

```
libgst/             VM core (bytecode interpreter, GC, JIT)
kernel/             Core Smalltalk class library
packages/
  gtk/              GTK4 bindings (C wrappers + AWK-generated Smalltalk)
  glib/             GLib/GObject bridge (event loop, signals)
  visualgst/        VisualGST IDE (75+ Smalltalk files)
  blox/gtk/         BLOX widget toolkit (higher-level GTK wrapper)
  cairo/            Cairo graphics bindings
  ...               40+ additional packages
```

## Known Limitations

- **Dialog widgets**: `GtkFileChooserDialog` and `GtkMessageDialog` are deprecated in GTK4 but still functional. Migration to `GtkFileDialog`/`GtkAlertDialog` requires GTK 4.10+.
- **WebKit**: `GtkWebView`/`GtkWebBrowser` migrated to WebKit2GTK (`libwebkitgtk-6.0`). The library is loaded dynamically at runtime — if not installed, web browsing features are simply hidden from the Tools menu. Falls back to `libwebkit2gtk-4.1` if `libwebkitgtk-6.0` is unavailable.
- **GTK warnings**: `g_regex_match_full: assertion 'string != NULL' failed` is a GTK4 CSS theme engine internal issue, not caused by this project.

## About GNU Smalltalk

GNU Smalltalk is an implementation that closely follows the Smalltalk-80 language as described in the book *Smalltalk-80: the Language and its Implementation* by Adele Goldberg and David Robson.

Unlike other Smalltalks (including Smalltalk-80), GNU Smalltalk emphasizes Smalltalk's rapid prototyping features rather than the graphical and easy-to-use nature of the programming environment. The goal of the GNU Smalltalk project is to produce a complete system to be used to write your scripts in a clear, aesthetically pleasing, and philosophically appealing programming language.

## License

GNU Smalltalk is free software distributed under the GNU General Public License v2 or later. See [COPYING](COPYING) for details.

VisualGST is distributed under the MIT License. See individual file headers in `packages/visualgst/` for details.
