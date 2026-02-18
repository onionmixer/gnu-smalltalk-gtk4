"======================================================================
|
|   Smalltalk Gtk+ bindings examples
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
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


PackageLoader fileInPackage: 'GTK'.


Namespace current: GTK [

Object subclass: ButtonBoxExample [
    
    <category: nil>
    <comment: nil>

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    open [
	<category: 'layout'>
	| window mainVBox hbox vbox frameHorz frameVert |
	window := GtkWindow new.
	window setTitle: 'Button Boxes'.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	mainVBox := GtkBox new: Gtk gtkOrientationVertical spacing: 0.
	window setChild: mainVBox.
	frameHorz := GtkFrame new: 'Horizontal Button Boxes'.
	mainVBox append: frameHorz.
	vbox := GtkBox new: Gtk gtkOrientationVertical spacing: 0.
	frameHorz setChild: vbox.
	vbox
	    append: (GtkButtonBox
		    createButtonBox: 'Spread (spacing 40)'
		    orientation: Gtk gtkOrientationHorizontal
		    spacing: 40
		    layout: Gtk gtkButtonboxSpread).
	vbox
	    append: (GtkButtonBox
		    createButtonBox: 'Edge (spacing 30)'
		    orientation: Gtk gtkOrientationHorizontal
		    spacing: 30
		    layout: Gtk gtkButtonboxEdge).
	vbox
	    append: (GtkButtonBox
		    createButtonBox: 'Start (spacing 20)'
		    orientation: Gtk gtkOrientationHorizontal
		    spacing: 20
		    layout: Gtk gtkButtonboxStart).
	vbox
	    append: (GtkButtonBox
		    createButtonBox: 'End (spacing 10)'
		    orientation: Gtk gtkOrientationHorizontal
		    spacing: 10
		    layout: Gtk gtkButtonboxEnd).
	frameVert := GtkFrame new: 'Vertical Button Boxes'.
	mainVBox append: frameVert.
	hbox := GtkBox new: Gtk gtkOrientationHorizontal spacing: 0.
	frameVert setChild: hbox.
	hbox
	    append: (GtkButtonBox
		    createButtonBox: 'Spread (spacing 5)'
		    orientation: Gtk gtkOrientationVertical
		    spacing: 5
		    layout: Gtk gtkButtonboxSpread).
	hbox
	    append: (GtkButtonBox
		    createButtonBox: 'Edge (spacing 30)'
		    orientation: Gtk gtkOrientationVertical
		    spacing: 30
		    layout: Gtk gtkButtonboxEdge).
	hbox
	    append: (GtkButtonBox
		    createButtonBox: 'Start (spacing 20)'
		    orientation: Gtk gtkOrientationVertical
		    spacing: 20
		    layout: Gtk gtkButtonboxStart).
	hbox
	    append: (GtkButtonBox
		    createButtonBox: 'End (spacing 20)'
		    orientation: Gtk gtkOrientationVertical
		    spacing: 20
		    layout: Gtk gtkButtonboxEnd).
	window show
    ]
]

]



GTK.GtkButtonBox class extend [

    createButtonBox: title orientation: orientation spacing: spacing layout: layout [
	<category: 'creating button boxes'>
	| box frame button |
	frame := GtkFrame new: title.
	box := self new: orientation.
	frame setChild: box.
	box setLayout: layout.
	box setSpacing: spacing.
	button := GtkButton newWithLabel: 'OK'.
	box append: button.
	button := GtkButton newWithLabel: 'Cancel'.
	box append: button.
	button := GtkButton newWithLabel: 'Help'.
	box append: button.
	^frame
    ]

]



Namespace current: GTK [
    ButtonBoxExample new open.
    Gtk main
]

