"======================================================================
|
| GtkScrollTreeWidget4 class definition
|
| GTK4 tree view wrapper replacing GtkScrollTreeWidget for TREE mode.
| Uses GtkListView + GtkTreeListModel + GtkTreeExpander +
| GtkSingleSelection + GtkSignalListItemFactory.
| Provides API compatible with old GtkTreeView-based tree consumers.
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

GtkConcreteWidget subclass: GtkScrollTreeWidget4 [

    | listView selectionModel model columnTypes factory |

    GtkScrollTreeWidget4 class >> createTreeWithModel: anArray [
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
	model := GtkTreeModel4 new.
	self buildListView.
	self mainWidget: (GTK.GtkScrolledWindow withChild: listView).
    ]

    buildListView [
	<category: 'user interface'>

	factory := GTK.GtkSignalListItemFactory new.
	factory connectSignal: 'setup' to: self selector: #'onSetup:listItem:'.
	factory connectSignal: 'bind' to: self selector: #'onBind:listItem:'.
	selectionModel := GTK.GtkSingleSelection new: model treeListModel.
	listView := GTK.GtkListView new: selectionModel factory: factory.
    ]

    onSetup: aFactory listItem: aListItem [
	"Create the widget tree for a tree item row:
	 GtkTreeExpander > GtkLabel (or GtkBox with icon for multi-column)."
	<category: 'factory callbacks'>

	| expander child |
	expander := GTK.Gtk treeExpanderNew.
	(self hasIconColumn)
	    ifTrue: [
		| box image label |
		box := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 4.
		image := GTK.GtkImage new.
		label := GTK.GtkLabel new: ''.
		label setHalign: GTK.Gtk gtkAlignStart.
		box append: image.
		box append: label.
		child := box ]
	    ifFalse: [
		child := GTK.GtkLabel new: ''.
		child setHalign: GTK.Gtk gtkAlignStart ].
	expander setChild: child.
	aListItem setChild: expander.
    ]

    onBind: aFactory listItem: aListItem [
	"Bind data to a tree item row."
	<category: 'factory callbacks'>

	| row stringObj idStr id stItem contents expander |
	row := aListItem getItem.
	row ifNil: [ ^ self ].
	stringObj := GTK.Gtk treeListRowGetItem: row.
	stringObj ifNil: [ ^ self ].
	idStr := GTK.Gtk stringObjectGetString: stringObj.
	id := idStr asInteger.
	stItem := model idToItem at: id ifAbsent: [ nil ].
	stItem ifNil: [ ^ self ].
	contents := model contentsBlock value: stItem.
	expander := aListItem getChild.
	(self hasIconColumn)
	    ifTrue: [
		| box image label |
		box := expander getChild.
		image := box getFirstChild.
		label := image getNextSibling.
		contents size > 0 ifTrue: [
		    (contents first) ifNotNil: [ :icon |
			image setFromPixbuf: icon ] ].
		contents size > 1 ifTrue: [
		    label setLabel: (contents at: 2) displayString ] ]
	    ifFalse: [
		| label |
		label := expander getChild.
		label setLabel: contents first displayString ].
	expander setListRow: row.
    ]

    hasIconColumn [
	"Check if the column types include a pixbuf/icon column."
	<category: 'private'>

	columnTypes ifNil: [ ^ false ].
	columnTypes do: [ :col |
	    col do: [ :spec |
		spec == GtkColumnPixbufType ifTrue: [ ^ true ] ] ].
	^ false
    ]

    "--- Accessors ---"

    model [
	"Return the GtkTreeModel4 instance."
	<category: 'accessing'>

	^ model
    ]

    treeView [
	"Return the list view widget (compatibility)."
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

    "--- Selection API ---"

    selection [
	"Return the currently selected Smalltalk object."
	<category: 'selection'>

	| pos row stringObj idStr id |
	pos := selectionModel getSelected.
	pos < 0 ifTrue: [ ^ nil ].
	row := GTK.Gtk treeListModelGetRow: model treeListModel position: pos.
	row ifNil: [ ^ nil ].
	stringObj := GTK.Gtk treeListRowGetItem: row.
	stringObj ifNil: [ ^ nil ].
	idStr := GTK.Gtk stringObjectGetString: stringObj.
	id := idStr asInteger.
	^ model idToItem at: id ifAbsent: [ nil ]
    ]

    select: anObject [
	"Select the row containing anObject."
	<category: 'selection'>

	| idx |
	idx := model findIndex: anObject.
	idx >= 0 ifTrue: [ selectionModel setSelected: idx ]
    ]

    hasSelectedItem [
	<category: 'selection'>

	| pos |
	pos := selectionModel getSelected.
	^ pos >= 0 and: [ pos < (GList modelGetNItems: model treeListModel) ]
    ]

    unselectAll [
	<category: 'selection'>

	selectionModel setCanUnselect: true.
	selectionModel setSelected: -1
    ]

    "--- Tree operations ---"

    expandAll [
	"Expand all rows in the tree."
	<category: 'tree operations'>

	| n changed |
	"Iterate until no more rows can be expanded.
	 Expanding a row inserts its children, increasing the count."
	changed := true.
	[ changed ] whileTrue: [
	    changed := false.
	    n := GList modelGetNItems: model treeListModel.
	    0 to: n - 1 do: [ :i |
		| row |
		row := model treeListModel getRow: i.
		(row notNil and: [ row isExpandable and: [ row getExpanded not ] ])
		    ifTrue: [
			row setExpanded: true.
			changed := true ] ] ]
    ]

    collapseRow: anObject [
	"Collapse the row for the given Smalltalk object."
	<category: 'tree operations'>

	| idx row |
	idx := model findIndex: anObject.
	idx < 0 ifTrue: [ ^ self ].
	row := model treeListModel getRow: idx.
	row ifNotNil: [ row setExpanded: false ]
    ]

    expandRow: anObject openAll: openAll [
	"Expand the row for the given Smalltalk object."
	<category: 'tree operations'>

	| idx row |
	idx := model findIndex: anObject.
	idx < 0 ifTrue: [ ^ self ].
	row := model treeListModel getRow: idx.
	row ifNotNil: [
	    row setExpanded: true.
	    openAll ifTrue: [ self expandAll ] ]
    ]

    "--- Compatibility shims ---"

    getSelection [
	"Return a selection proxy (self) compatible with old GtkTreeSelection API."
	<category: 'compatibility'>

	^ self
    ]

    setMode: aMode [
	"Selection mode is always single/browse. No-op."
	<category: 'compatibility'>
    ]

    getModel [
	"Return the model (compatibility with old treeView getModel pattern)."
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
