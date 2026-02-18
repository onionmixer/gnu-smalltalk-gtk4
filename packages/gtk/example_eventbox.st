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

Object subclass: EventBoxExample [
    | window |

    <category: nil>
    <comment: nil>

    buttonPressed: gesture nPress: nPress x: x y: y [
	<category: 'event handling'>
	window destroy
    ]

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    open [
	<category: 'layout'>
	| label gesture |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	window setTitle: 'Event Box'.
	label := GtkLabel new: 'Click here to quit, quit, quit, quit, quit'.
	label setSizeRequest: 110 height: 20.
	label setCursorFromName: 'pointer'.
	gesture := GtkGestureClick new.
	gesture connectSignal: 'pressed' to: self selector: #'buttonPressed:nPress:x:y:'.
	label addController: gesture.
	window setChild: label.
	window show
    ]
]

]



Namespace current: GTK [
    EventBoxExample new open.
    Gtk main
]

