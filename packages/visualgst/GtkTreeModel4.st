"======================================================================
|
| GtkTreeModel4 class definition
|
| GTK4 tree model wrapper using GtkTreeListModel + GtkStringList.
| Provides the same API as GtkTreeModel but uses GTK4 GtkTreeListModel
| with a C bridge for child model creation callbacks.
|
| Each Smalltalk item is assigned a unique integer ID, stored as a string
| in GtkStringList instances. The C bridge extracts the ID from the
| GtkStringObject and emits 'gst-create-children' with the integer ID.
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

Object subclass: GtkTreeModel4 [

    | childrenBlock contentsBlock item
      nextId idToItem itemToId itemToParent
      rootItems rootStringList
      childItems childStringLists
      treeListModel |

    GtkTreeModel4 class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	nextId := 1.
	idToItem := Dictionary new.
	itemToId := IdentityDictionary new.
	itemToParent := IdentityDictionary new.
	rootItems := OrderedCollection new.
	childItems := IdentityDictionary new.
	childStringLists := IdentityDictionary new.
	rootStringList := GTK.GtkStringList new.
	treeListModel := GTK.GtkTreeListModel
	    newWithRoot: rootStringList passthrough: false autoexpand: false.
	treeListModel connectCreateChildren: self selector: #'onCreateChildren:id:'.
    ]

    "--- Accessors ---"

    childrenBlock: aBlock [
	<category: 'accessing'>

	childrenBlock := aBlock
    ]

    childrenBlock [
	<category: 'accessing'>

	^ childrenBlock
    ]

    contentsBlock: aBlock [
	<category: 'accessing'>

	contentsBlock := aBlock
    ]

    contentsBlock [
	<category: 'accessing'>

	^ contentsBlock
    ]

    item: anObject [
	<category: 'accessing'>

	item := anObject
    ]

    item [
	<category: 'accessing'>

	^ item
    ]

    treeListModel [
	<category: 'accessing'>

	^ treeListModel
    ]

    rootStringList [
	<category: 'accessing'>

	^ rootStringList
    ]

    idToItem [
	<category: 'accessing'>

	^ idToItem
    ]

    "--- ID management ---"

    assignId: anItem [
	"Assign a unique integer ID to an item and register it."
	<category: 'private'>

	| id |
	id := nextId.
	nextId := nextId + 1.
	idToItem at: id put: anItem.
	itemToId at: anItem put: id.
	^ id
    ]

    "--- Signal callback ---"

    onCreateChildren: aModel id: anId [
	"Called by the C bridge when GtkTreeListModel needs child models.
	 Returns a GtkStringList of child IDs, or nil for leaf nodes."
	<category: 'private'>

	| stItem children childList items |
	stItem := idToItem at: anId ifAbsent: [ ^ nil ].
	children := childrenBlock value: stItem.
	(children isNil or: [ children isEmpty ]) ifTrue: [ ^ nil ].
	childList := GTK.GtkStringList new.
	items := OrderedCollection new.
	children do: [ :each |
	    | id |
	    id := self assignId: each.
	    childList append: id printString.
	    items add: each.
	    itemToParent at: each put: stItem ].
	childStringLists at: stItem put: childList.
	childItems at: stItem put: items.
	^ childList
    ]

    "--- Model operations ---"

    refresh [
	<category: 'model'>

	| n children |
	self clearMappings.
	n := GList modelGetNItems: rootStringList.
	n > 0 ifTrue: [ rootStringList splice: 0 nRemovals: n additions: nil ].
	item ifNil: [ ^ self ].
	children := childrenBlock value: item.
	children do: [ :each |
	    rootStringList append: (self assignId: each) printString.
	    rootItems add: each.
	    itemToParent at: each put: nil ]
    ]

    clear [
	<category: 'model'>

	| n |
	self clearMappings.
	n := GList modelGetNItems: rootStringList.
	n > 0 ifTrue: [ rootStringList splice: 0 nRemovals: n additions: nil ]
    ]

    clearMappings [
	<category: 'private'>

	nextId := 1.
	idToItem := Dictionary new.
	itemToId := IdentityDictionary new.
	itemToParent := IdentityDictionary new.
	rootItems := OrderedCollection new.
	childItems := IdentityDictionary new.
	childStringLists := IdentityDictionary new.
    ]

    append: anObject [
	<category: 'model'>

	self append: anObject parent: nil
    ]

    append: anObject parent: aParentObject [
	<category: 'model'>

	| id childList items |
	(itemToId includesKey: anObject) ifTrue: [ ^ self ].
	id := self assignId: anObject.
	aParentObject isNil
	    ifTrue: [
		rootStringList append: id printString.
		rootItems add: anObject.
		itemToParent at: anObject put: nil ]
	    ifFalse: [
		itemToParent at: anObject put: aParentObject.
		childList := childStringLists at: aParentObject ifAbsent: [ nil ].
		childList ifNotNil: [
		    childList append: id printString.
		    items := childItems at: aParentObject ifAbsentPut: [ OrderedCollection new ].
		    items add: anObject ] ]
    ]

    remove: anObject [
	<category: 'model'>

	self remove: anObject ifAbsent: [ self error: 'item not found' ]
    ]

    remove: anObject ifAbsent: aBlock [
	<category: 'model'>

	| parent childList items idx |
	(itemToId includesKey: anObject) ifFalse: [ ^ aBlock value ].
	parent := itemToParent at: anObject ifAbsent: [ nil ].
	parent isNil
	    ifTrue: [
		childList := rootStringList.
		items := rootItems ]
	    ifFalse: [
		childList := childStringLists at: parent ifAbsent: [ nil ].
		items := childItems at: parent ifAbsent: [ nil ] ].
	(items notNil and: [ childList notNil ]) ifTrue: [
	    idx := items indexOf: anObject ifAbsent: [ 0 ].
	    idx > 0 ifTrue: [
		items removeAtIndex: idx.
		childList remove: idx - 1 ] ].
	self cleanupItem: anObject
    ]

    cleanupItem: anObject [
	"Remove an item and all its descendants from the ID maps."
	<category: 'private'>

	| id children |
	id := itemToId at: anObject ifAbsent: [ nil ].
	id ifNotNil: [ idToItem removeKey: id ifAbsent: [ ] ].
	itemToId removeKey: anObject ifAbsent: [ ].
	itemToParent removeKey: anObject ifAbsent: [ ].
	children := childItems at: anObject ifAbsent: [ nil ].
	children ifNotNil: [
	    children do: [ :each | self cleanupItem: each ] ].
	childItems removeKey: anObject ifAbsent: [ ].
	childStringLists removeKey: anObject ifAbsent: [ ]
    ]

    "--- Query ---"

    hasItem: anObject [
	<category: 'item selection'>

	^ itemToId includesKey: anObject
    ]

    includes: anObject [
	<category: 'item selection'>

	^ itemToId includesKey: anObject
    ]

    findIndex: anObject [
	"Return the 0-based position of anObject in the flattened tree list model,
	 or -1 if not found."
	<category: 'item selection'>

	| n id idStr |
	(itemToId includesKey: anObject) ifFalse: [ ^ -1 ].
	id := itemToId at: anObject.
	idStr := id printString.
	n := GList modelGetNItems: treeListModel.
	0 to: n - 1 do: [ :i |
	    | row rowItem |
	    row := treeListModel getRow: i.
	    row ifNotNil: [
		rowItem := row getItem.
		rowItem ifNotNil: [
		    (GTK.Gtk stringObjectGetString: rowItem) = idStr
			ifTrue: [ ^ i ] ] ] ].
	^ -1
    ]

    findIndex: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	| idx |
	idx := self findIndex: anObject.
	idx < 0 ifTrue: [ ^ aBlock value ].
	^ idx
    ]

    "--- Signal forwarding ---"

    connectSignal: aString to: anObject selector: aSymbol [
	"Forward signal connections to the underlying tree list model.
	 Note: 'row-has-child-toggled' has no GTK4 equivalent (ignored)."
	<category: 'events'>

	aString = 'row-has-child-toggled' ifTrue: [ ^ nil ].
	^ treeListModel connectSignal: aString to: anObject selector: aSymbol
    ]
]
