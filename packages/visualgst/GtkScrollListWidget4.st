"======================================================================
|
| GtkScrollListWidget4 class definition
|
| GTK4 list view wrapper replacing GtkScrollTreeWidget for LIST mode.
| Uses GtkListView + GtkSingleSelection + GtkSignalListItemFactory.
| Provides API compatible with old GtkTreeView-based consumers.
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

GtkConcreteWidget subclass: GtkScrollListWidget4 [

    | listView selectionModel model columnTypes factory |

    GtkScrollListWidget4 class >> createListWithModel: anArray [
	<category: 'instance creation'>

	^ self basicNew
	    columnTypes: anArray;
	    initialize;
	    yourself
    ]

    columnTypes: anArray [
	<category: 'accessing'>

	columnTypes := anArray
    ]

    initialize [
	<category: 'initialization'>

	popupMenu := [ :value | ].
	model := GtkListModel4 new.
	model columnTypes: columnTypes.
	self buildListView.
	self mainWidget: (GTK.GtkScrolledWindow withChild: listView).
    ]

    buildListView [
	<category: 'user interface'>

	factory := GTK.GtkSignalListItemFactory new.
	factory connectSignal: 'setup' to: self selector: #'onSetup:listItem:'.
	factory connectSignal: 'bind' to: self selector: #'onBind:listItem:'.
	selectionModel := GTK.GtkSingleSelection new: model stringList.
	listView := GTK.GtkListView new: selectionModel factory: factory.
    ]

    onSetup: aFactory listItem: aListItem [
	"Create the widget for a list item row."
	<category: 'factory callbacks'>

	| label |
	label := GTK.GtkLabel new: ''.
	label setHalign: GTK.Gtk gtkAlignStart.
	aListItem setChild: label.
    ]

    onBind: aFactory listItem: aListItem [
	"Bind data to a list item row."
	<category: 'factory callbacks'>

	| pos label contents |
	pos := aListItem getPosition.
	label := aListItem getChild.
	contents := model contentsAt: pos.
	label setLabel: contents first displayString.
    ]

    model [
	"Return the GtkListModel4 instance."
	<category: 'accessing'>

	^ model
    ]

    treeView [
	"Return the list view widget (compatibility with GtkConcreteWidget)."
	<category: 'accessing'>

	^ listView
    ]

    listView [
	<category: 'accessing'>

	^ listView
    ]

    selectionModel [
	<category: 'accessing'>

	^ selectionModel
    ]

    "--- Selection API (compatible with old GtkTreeView extensions) ---"

    selection [
	"Return the currently selected Smalltalk object."
	<category: 'selection'>

	| pos |
	pos := selectionModel getSelected.
	(pos < 0 or: [ pos >= model size ]) ifTrue: [ ^ nil ].
	^ model itemAt: pos
    ]

    select: anObject [
	"Select the row containing anObject."
	<category: 'selection'>

	| idx |
	idx := model findIndex: anObject.
	idx >= 0 ifTrue: [ selectionModel setSelected: idx ]
    ]

    selectNth: n [
	"Select the n-th item (1-based, for compatibility)."
	<category: 'selection'>

	(n >= 1 and: [ n <= model size ])
	    ifTrue: [ selectionModel setSelected: n - 1 ]
    ]

    selectFirstItem [
	<category: 'selection'>

	model size > 0 ifTrue: [ selectionModel setSelected: 0 ]
    ]

    selectLastItem [
	<category: 'selection'>

	model size > 0 ifTrue: [ selectionModel setSelected: model size - 1 ]
    ]

    hasSelectedItem [
	<category: 'selection'>

	| pos |
	pos := selectionModel getSelected.
	^ pos >= 0 and: [ pos < model size ]
    ]

    hasSelectedValue [
	"Alias for hasSelectedItem."
	<category: 'selection'>

	^ self hasSelectedItem
    ]

    selectedIndex [
	"Return the 1-based index of the selected item."
	<category: 'selection'>

	self hasSelectedItem ifFalse: [ self error: 'Nothing is selected' ].
	^ selectionModel getSelected + 1
    ]

    unselectAll [
	<category: 'selection'>

	selectionModel setCanUnselect: true.
	selectionModel setSelected: -1
    ]

    "--- Compatibility shims ---"

    getSelection [
	"Return a selection proxy that responds to setMode:, connectSignal:to:selector:,
	 and unselectAll. Delegates to selectionModel."
	<category: 'compatibility'>

	^ self
    ]

    setMode: aMode [
	"Selection mode is always single/browse for GtkSingleSelection. No-op."
	<category: 'compatibility'>
    ]

    getModel [
	"Return the model (compatibility with old treeView getModel)."
	<category: 'compatibility'>

	^ model
    ]

    connectSignal: aString to: anObject selector: aSymbol [
	"Connect signal. Map 'changed' to 'selection-changed' on selectionModel."
	<category: 'compatibility'>

	aString = 'changed'
	    ifTrue: [ selectionModel connectSignal: 'selection-changed' to: anObject selector: aSymbol ]
	    ifFalse: [ listView connectSignal: aString to: anObject selector: aSymbol ]
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	"Connect signal with user data."
	<category: 'compatibility'>

	aString = 'changed'
	    ifTrue: [ selectionModel connectSignal: 'selection-changed' to: anObject selector: aSymbol userData: userData ]
	    ifFalse: [ listView connectSignal: aString to: anObject selector: aSymbol userData: userData ]
    ]
]
