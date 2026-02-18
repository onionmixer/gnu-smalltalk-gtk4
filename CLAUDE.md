# GNU Smalltalk - Project Context

## Overview

GNU Smalltalk (GST) is an implementation of the Smalltalk-80 language. It includes a bytecode interpreter, generational garbage collector, JIT compiler (via GNU Lightning), and a rich set of packages including GTK GUI bindings.

- Version: 3.2.92
- Language: C (VM core), Smalltalk (libraries/packages), AWK (code generators)
- Build system: Autoconf/Automake/Libtool
- License: GPL v2+

## Build Instructions

```bash
autoreconf -fiv    # regenerate build system (only after configure.ac changes)
./configure        # detect dependencies
make -j$(nproc)    # build
make check         # run tests (132 tests expected)
```

## Project Structure

```
libgst/           - VM core (bytecode interpreter, GC, JIT, OOP system)
kernel/           - Core Smalltalk class library (loaded into gst.im image)
lib-src/          - C support libraries (snprintfv, etc.)
packages/         - Extension packages:
  gtk/            - GTK3 bindings (C wrappers + AWK-generated Smalltalk)
  glib/           - GLib/GObject bridge (gst-gobject.c, gst-glib.c)
  gir/            - GObject Introspection (reference only, not production)
  blox/gtk/       - BLOX widget toolkit (higher-level GTK wrapper)
  visualgst/      - VisualGST IDE (Smalltalk-based GTK IDE)
  cairo/          - Cairo graphics bindings
  sockets/        - Network socket library
  dbi/            - Database interface
  dbd-sqlite/     - SQLite driver
  seaside/        - Seaside web framework port
  sunit/          - SUnit testing framework
  xml/            - XML parsing (Expat, SAX, DOM)
  ...             - 40+ additional packages
doc/              - Documentation (Texinfo)
tests/            - Test suite (Autotest)
examples/         - Standalone examples
```

## GTK Binding Architecture

The GTK package (`packages/gtk/`) uses a layered architecture:

### C Layer
- **gst-gtk.c** - Wrapper functions exposing GTK API to Smalltalk via `defineCFunc`. Provides accessor wrappers for struct fields not directly accessible from Smalltalk FFI.
- **placer.c/placer.h** - Custom `GtkContainer` subclass implementing rubber-sheet geometry management for BLOX.
- **gst-gobject.c** (in `packages/glib/`) - GObject bridge: GValue conversion, signal connection via GClosure, type registration.
- **gst-glib.c** (in `packages/glib/`) - Two-threaded GLib event loop integration.

### AWK Code Generators
- **cpp.awk** - C preprocessor wrapper for extracting GTK header content
- **structs.awk** - Parses GTK headers to generate `Structs.st` (class hierarchy, struct field accessors)
- **funcs.awk** - Parses GTK headers to generate `Funcs.st` (C function bindings)
- **mk_enums.awk** - Generates `Enums.st` (enum/flag constants)
- **mk_sizeof.awk** - Generates struct size information
- **mkorder.awk** - Determines header processing order via `pkg-config`

Generated files (`Structs.st`, `Funcs.st`, `Enums.st`) are built during `make` and should not be edited manually.

### Smalltalk Layer
- **MoreFuncs.st** - Manual C function bindings (wrappers defined in gst-gtk.c)
- **MoreStructs.st** - Manual struct definitions (GdkRGBA, etc.)
- **GtkImpl.st** - Higher-level Smalltalk extensions to GTK classes

### Smalltalk FFI Syntax
```smalltalk
methodName [
    <cCall: 'c_function_name' returning: #type args: #(#type1 #type2)>
]
```
Return/arg types: `#int`, `#boolean`, `#string`, `#void`, `#self`, `#cObject`, `#smalltalk`, `#{ClassName}`, `#double`

## Current GTK Migration Status

**Completed: GTK2 → GTK3 migration** (see commit history)
- Build system targets `gtk+-3.0 >= 3.24`
- C code uses GTK3 accessor functions (no direct struct field access)
- Deprecated widgets replaced (GtkHBox→GtkBox, GtkArrow→GtkImage, etc.)
- Stock icons replaced with freedesktop icon names
- GtkObject signals migrated to GObject signal API

**Planned: GTK3 → GTK4 migration** (see `PLAN_GST_GTK4.md`)
- Major items: GtkContainer removal, placer.c rewrite, showAll/hideAll removal, packStart/packEnd→append/prepend, event controller migration, GtkTreeView→GtkColumnView

## Key Conventions

- Smalltalk source files use `.st` extension
- VisualGST files are organized by feature (Commands/, Text/, Inspector/, etc.)
- GTK enum constants accessed via `GTK.Gtk gtkConstantName` (e.g., `Gtk gtkOrientationVertical`)
- GTK class hierarchy generated from headers; manual extensions go in `MoreFuncs.st`, `MoreStructs.st`, `GtkImpl.st`
- Test suite is Autotest-based in `tests/` directory
