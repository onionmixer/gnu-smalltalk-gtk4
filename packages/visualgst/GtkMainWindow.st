"======================================================================
|
| GtkMainWindow class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

Smalltalk.Object subclass: GtkMainWindow [
    | window container menuBar toolBar centralWidget statusBar statusLabel accelGroup actionGroup menuModel actionCounter |

    GtkMainWindow class >> open	[
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    show;
	    postInitialize;
	    yourself
    ]

    GtkMainWindow class >> openSized: aPoint [
	<category: 'user interface'>
	
	^ (self new)
	    initialize;
	    resize: aPoint;
	    show;
	    postInitialize;
	    yourself
    ]

    centralWidget [
	<category: 'accessing'>

	^ centralWidget
    ]

    centralWidget: aGtkWidget [
	<category: 'accessing'>

	centralWidget := aGtkWidget
    ]

    container [
	<category: 'accessing'>

	^ container ifNil: [ container := GTK.GtkBox new: GTK.Gtk gtkOrientationVertical spacing: 0 ]
    ]

    accelGroup [
	<category: 'accessing'>

	^ accelGroup ifNil: [ accelGroup := GTK.GtkShortcutController new ]
    ]

    actionGroup [
	<category: 'accessing'>

	^ actionGroup ifNil: [
	    actionGroup := GTK.GSimpleActionGroup new.
	    window insertActionGroup: 'win' group: actionGroup.
	    actionGroup ]
    ]

    menuModel [
	<category: 'accessing'>

	^ menuModel ifNil: [ menuModel := GTK.GMenu new ]
    ]

    menuBar [
	<category: 'accessing'>

	^ menuBar ifNil: [ menuBar := GTK.GtkPopoverMenuBar newFromModel: self menuModel ]
    ]

    statusBar [
	<category: 'accessing'>

	^ statusBar ifNil: [
	    statusLabel := GTK.GtkLabel new: ''.
	    statusLabel setHalign: GTK.Gtk gtkAlignStart.
	    statusLabel setHexpand: true.
	    statusBar := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 0.
	    statusBar append: statusLabel.
	    statusBar ]
    ]

    statusBar: aGtkStatusBar [
	<category: 'accessing'>

	statusBar := aGtkStatusBar
    ]

    title [
	<category: 'accessing'>

	^ window title
    ]

    title: aString [
	<category: 'accessing'>

	window setTitle: aString
    ]

    toolBar [
	<category: 'accessing'>

	^ toolBar ifNil: [ toolBar := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 2 ]
    ]

    toolBar: aGtkToolBar [
	<category: 'accessing'>

	toolBar := aGtkToolBar
    ]

    aboutGst [
	<category: 'events'>

	(GTK.GtkAboutDialog new)
	    setProgramName: 'GNU Smalltalk';
	    setVersion: (Smalltalk version =~ 'version (.*)' at: 1);
	    setLicense: 'GNU Smalltalk is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later version.

GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  

Please consult the GNU Smalltalk source code for additional permissions
that are specific to this version of GNU Smalltalk.';
	    setWebsite: 'http://smalltalk.gnu.org/';
	    showModalDestroy
    ]

    close [
	<category: 'events'>

	window hide
    ]

    initialize [
	<category: 'intialization'>
	
	window := GTK.GtkWindow new.
	window addController: self accelGroup.
        self
            title: self windowTitle;
            createMenus;
            createToolbar;
            createStatusBar;
            centralWidget: self buildCentralWidget.
    ]

    buildCentralWidget [
	<category: 'initialization'>
        ^nil
    ]

    createStatusBar [
        <category: 'user interface'>

        self statusMessage: self windowTitle
    ]

    windowTitle [
	<category: 'initialization'>
        ^self class name
    ]

    createToolbar [
	<category: 'initialization'>
    ]

    createMenus [
	<category: 'initialization'>
    ]

    postInitialize [
	<category: 'initialization'>

        window
            connectSignal: 'close-request' to: self selector: #'onDelete:'
    ]

    onDelete: aGtkWidget [
	<category: 'events'>

        window hide.
        ^ true
    ]

    nextActionName [
	<category: 'menubar'>

	actionCounter := (actionCounter ifNil: [0]) + 1.
	^ 'a', actionCounter printString
    ]

    menuItem: aLabel target: aTarget selector: aSelector [
	<category: 'menubar'>

	| actionName action |
	actionName := self nextActionName.
	action := GTK.GSimpleAction new: actionName parameterType: nil.
	action connectSignal: 'activate' to: aTarget selector: aSelector.
	self actionGroup insert: action.
	^ GTK.GMenuItem new: aLabel detailedAction: 'win.', actionName
    ]

    addMenuItem: aString withSubmenu: aGMenuItemArray [
	<category: 'menubar'>

	| submenu section |
	submenu := GTK.GMenu new.
	section := GTK.GMenu new.
	aGMenuItemArray do: [ :each |
	    each isNil
		ifTrue: [
		    submenu appendSection: nil section: section.
		    section := GTK.GMenu new ]
		ifFalse: [ section appendItem: each ] ].
	section getNItems > 0 ifTrue: [
	    submenu appendSection: nil section: section ].
	self menuModel appendSubmenu: aString submenu: submenu
    ]

    createMainMenu: anArray [
	<category: 'menubar'>

	anArray do: [ :each |
	    self addMenuItem: each first withSubmenu: (self perform: each second) ]
    ]

    statusMessage: aString [
	<category: 'statusbar'>

	self statusBar.
	statusLabel setText: aString
    ]

    appendSeparator [
	<category: 'toolbar'>

	self toolBar append: (GTK.GtkSeparator new: GTK.Gtk gtkOrientationVertical)
    ]

    appendToolItem: aGtkWidget [
	<category: 'toolbar'>

	self toolBar append: aGtkWidget
    ]

    appendWidget: aGtkWidget [
	<category: 'toolbar'>

	self toolBar append: aGtkWidget
    ]

    resize: aPoint [
	<category: 'user interface'>

	window resize: aPoint x height: aPoint y
    ]

    show [
	{menuBar->false. toolBar->false. centralWidget->true. statusBar->false} do: [ :each |
	    each key ifNotNil: [ self container
		append: each key ] ].

	window
	    setChild: self container;
	    show
    ]

    focusedWidget [
        <category: 'focus'>

        self subclassResponsibility
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [ ^ self ].
        ^ widget perform: aSymbol
    ]

    onFocusPerform: aSymbol with: anObject [
        <category: 'widget'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [ ^ self ].
        ^ widget perform: aSymbol with: anObject
    ]
]
