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
