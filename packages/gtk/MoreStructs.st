"======================================================================
|
|   Smalltalk Gtk+ bindings (declarations of some CStructs needing fields)
|
 ======================================================================"

"======================================================================
|
| Copyright 2004, 2008, 2009 Free Software Foundation, Inc.
| Written by Robert Collins.
|
| This file is part of the GNU Smalltalk class library.
| It contains manual struct definitions the automatic logic fails to create
|
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
|
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"



"FIXME: passing #cObjectPtr should be smarter or something"



CStruct subclass: GtkTreeModelPointer [

    <category: 'GTK'>
    <comment: nil>
    <declaration: #(#(#model #(#ptr #GtkTreeModel ) ) )>
]



CStruct subclass: GtkRequisition [

    <category: 'GTK'>
    <comment: nil>
    <declaration: #(#(#width #int ) #(#height #int ) )>
]



"GTK4: GdkColor removed. Use GdkRGBA instead."

CStruct subclass: GdkRGBA [

    <category: 'GDK'>
    <comment: 'GTK4 color representation using doubles (0.0-1.0).'>
    <declaration: #(#(#red #double) #(#green #double) #(#blue #double) #(#alpha #double))>

    GdkRGBA class >> red: r green: g blue: b alpha: a [
	<category: 'instance creation'>
	| rgba |
	rgba := self new.
	rgba red value: r.
	rgba green value: g.
	rgba blue value: b.
	rgba alpha value: a.
	^rgba
    ]

    GdkRGBA class >> red: r green: g blue: b [
	<category: 'instance creation'>
	^self red: r green: g blue: b alpha: 1.0
    ]
]


"GTK4: GdkEvent* structs are opaque objects accessed through getter
 functions (gdk_event_get_position, gdk_button_event_get_button, etc.).
 The old CStruct declarations have been removed."


"GTK4 list widget classes missing from auto-generated Structs.st.
 These are needed for the GtkListView/GtkColumnView based list widgets."

GLib.GObject variableWordSubclass: #GListModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'GLib'!

GLib.GObject variableWordSubclass: #GListStore
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'GLib'!

GLib.GObject variableWordSubclass: #GtkSingleSelection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkMultiSelection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkStringList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkStringObject
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"GTK4 menu classes: fix class hierarchy from auto-generated Structs.st.
 GtkPopoverMenu inherits from GtkPopover (to get popup, setHasArrow: etc).
 GtkPopoverMenuBar inherits from GtkWidget."

GtkPopover variableWordSubclass: #GtkPopoverMenu
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkPopoverMenuBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"GTK4 tree widget classes missing from auto-generated Structs.st.
 These are needed for the GtkTreeListModel-based tree widgets."

GLib.GObject variableWordSubclass: #GtkTreeListModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkTreeListRow
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkTreeExpander
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"=====================================================================
 GTK4 opaque type hierarchy fixups.

 In GTK4 many types became opaque (no public struct), so the AWK code
 generator in structs.awk defaults their parent to CObject.  Here we
 re-declare them with the correct GObject-based parent class.  This
 file is loaded AFTER Structs.st, so these declarations override the
 auto-generated ones.
 =====================================================================
"


"--- GIO: Action / Menu model types ---"

GLib.GObject variableWordSubclass: #GSimpleAction
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GMenuModel variableWordSubclass: #GMenu
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GMenuItem
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GNotification
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- EventController hierarchy ---"

GLib.GObject variableWordSubclass: #GtkEventController
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkEventControllerKey
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkEventControllerFocus
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkEventControllerScroll
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkEventControllerMotion
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkEventControllerLegacy
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkDropControllerMotion
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkShortcutController
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkPadController
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkDropTarget
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkEventController variableWordSubclass: #GtkDropTargetAsync
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- Gesture hierarchy ---"

GtkEventController variableWordSubclass: #GtkGesture
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGesture variableWordSubclass: #GtkGestureSingle
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkGestureClick
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkGestureDrag
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkGestureSwipe
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkGesturePan
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkGestureLongPress
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkGestureStylus
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGestureSingle variableWordSubclass: #GtkDragSource
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGesture variableWordSubclass: #GtkGestureRotate
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkGesture variableWordSubclass: #GtkGestureZoom
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- ListItemFactory hierarchy ---"

GLib.GObject variableWordSubclass: #GtkListItemFactory
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkListItemFactory variableWordSubclass: #GtkSignalListItemFactory
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkListItemFactory variableWordSubclass: #GtkBuilderListItemFactory
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkListItem
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- ListView / ColumnView / ListBase ---"

GtkWidget variableWordSubclass: #GtkListBase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkListBase variableWordSubclass: #GtkListView
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkListBase variableWordSubclass: #GtkGridView
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkColumnView
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkColumnViewColumn
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- Common widget types (opaque in GTK4) ---"

GtkWidget variableWordSubclass: #GtkNotebook
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkLabel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkScrolledWindow
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkSeparator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkImage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkScrollbar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkPaned
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkOverlay
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkRevealer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkSearchEntry
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkSearchBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkSwitch
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkSpinButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkSpinner
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkStack
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkStackSwitcher
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkStackSidebar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkHeaderBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkActionBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkInfoBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkFlowBox
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkListBox
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkCalendar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkMenuButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkViewport
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkProgressBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkLevelBar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkCenterBox
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkAspectFrame
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkExpander
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkPasswordEntry
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkButton variableWordSubclass: #GtkLinkButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkButton variableWordSubclass: #GtkLockButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkColorButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkFontButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkComboBox variableWordSubclass: #GtkComboBoxText
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- Dialog subclasses ---"

GtkWindow variableWordSubclass: #GtkAboutDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWindow variableWordSubclass: #GtkAssistant
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWindow variableWordSubclass: #GtkShortcutsWindow
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkDialog variableWordSubclass: #GtkColorChooserDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkDialog variableWordSubclass: #GtkFontChooserDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkDialog variableWordSubclass: #GtkFileChooserDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkDialog variableWordSubclass: #GtkAppChooserDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkAppChooserWidget
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkAppChooserButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkColorChooserWidget
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkFontChooserWidget
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkFileChooserWidget
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- Shortcut types ---"

GLib.GObject variableWordSubclass: #GtkShortcut
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkShortcutTrigger
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkShortcutAction
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkShortcutLabel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkBox variableWordSubclass: #GtkShortcutsGroup
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkBox variableWordSubclass: #GtkShortcutsSection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GtkWidget variableWordSubclass: #GtkShortcutsShortcut
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- Misc GObject types ---"

GLib.GObject variableWordSubclass: #GtkLayoutManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkBuilder
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkSettings
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkIconTheme
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkIconPaintable
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkEntryCompletion
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkTreeSelection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkFileFilter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkNotebookPage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkStackPage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkAssistantPage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkTooltip
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkPrintSettings
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkPageSetup
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GtkPrintContext
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GInitiallyUnowned variableWordSubclass: #GtkTreeViewColumn
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"--- GDK types ---"

GLib.GObject variableWordSubclass: #GdkClipboard
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkDisplay
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkDisplayManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkSurface
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkDevice
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GdkDevice variableWordSubclass: #GdkDevicePad
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkFrameClock
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkDrag
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkDrop
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkCursor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkMonitor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkDrawContext
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GdkDrawContext variableWordSubclass: #GdkGLContext
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GdkDrawContext variableWordSubclass: #GdkCairoContext
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkTexture
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GdkTexture variableWordSubclass: #GdkGLTexture
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GdkTexture variableWordSubclass: #GdkMemoryTexture
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib.GObject variableWordSubclass: #GdkPixbuf
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!
