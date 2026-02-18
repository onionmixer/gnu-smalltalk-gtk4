"======================================================================
|
| GtkListModel4 class definition
|
| GTK4 list model wrapper using GtkStringList + parallel OrderedCollection.
| Provides the same API as GtkListModel but uses GTK4 GListModel internally.
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

Object subclass: GtkListModel4 [

    | contentsBlock item items stringList columnTypes |

    GtkListModel4 class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]

    GtkListModel4 class >> columns: anArray [
	<category: 'instance creation'>

	^ self new
	    columnTypes: anArray;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	items := OrderedCollection new.
	stringList := GTK.GtkStringList new.
	columnTypes := #().
    ]

    columnTypes: anArray [
	<category: 'accessing'>

	columnTypes := anArray
    ]

    columnTypes [
	<category: 'accessing'>

	^ columnTypes
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

    items [
	<category: 'accessing'>

	^ items
    ]

    stringList [
	"Return the underlying GtkStringList (implements GListModel)."
	<category: 'accessing'>

	^ stringList
    ]

    size [
	<category: 'accessing'>

	^ items size
    ]

    append: anItem [
	<category: 'model'>

	| contents |
	contents := contentsBlock value: anItem.
	items add: anItem.
	stringList append: contents first displayString.
    ]

    remove: anObject [
	<category: 'model'>

	| idx |
	idx := items indexOf: anObject ifAbsent: [ self error: 'item not found' ].
	items removeAtIndex: idx.
	stringList remove: idx - 1.
    ]

    clear [
	<category: 'model'>

	| n |
	n := items size.
	items := OrderedCollection new.
	n > 0 ifTrue: [ stringList splice: 0 nRemovals: n additions: nil ].
    ]

    refresh [
	<category: 'model'>

	self clear.
	self item ifNil: [ ^ self ].
	self item do: [ :each | self append: each ]
    ]

    hasItem: anObject [
	<category: 'item selection'>

	^ items includes: anObject
    ]

    includes: anObject [
	<category: 'item selection'>

	^ items includes: anObject
    ]

    itemAt: aZeroBasedIndex [
	"Return the original Smalltalk object at the given 0-based index."
	<category: 'item selection'>

	^ items at: aZeroBasedIndex + 1
    ]

    contentsAt: aZeroBasedIndex [
	"Return the full contents array for the item at the given 0-based index."
	<category: 'item selection'>

	^ contentsBlock value: (items at: aZeroBasedIndex + 1)
    ]

    findIndex: anObject [
	"Return the 0-based index of the object, or -1 if not found."
	<category: 'item selection'>

	| idx |
	idx := items indexOf: anObject ifAbsent: [ ^ -1 ].
	^ idx - 1
    ]

    findIndex: anObject ifAbsent: aBlock [
	"Return the 0-based index of the object, or evaluate aBlock."
	<category: 'item selection'>

	| idx |
	idx := items indexOf: anObject ifAbsent: [ ^ aBlock value ].
	^ idx - 1
    ]
]
