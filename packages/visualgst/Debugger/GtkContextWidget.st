"======================================================================
|
| GtkContextWidget class definition
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

GtkConcreteWidget subclass: GtkContextWidget [
    | column contextTree model context contextList |

    GtkContextWidget class >> on: aContext [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    context: aContext;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    context: aContext [
	<category: 'accessing'>

	context := aContext.
	model
	    item: self buildListOfContexts;
	    refresh
    ]

    buildListOfContexts [
	<category: 'model'>

	| ctxt |
	contextList := OrderedCollection new.
        ctxt := context.
        [ ctxt isNil ] whileFalse: [
            contextList add: ctxt.
            ctxt := ctxt parentContext ].
	^ contextList
    ]

    buildTreeView [
        <category: 'user interface'>

        contextTree := GtkScrollListWidget4 createListWithModel: {{GtkColumnTextType title: 'Contexts'}}.
        contextTree connectToWhenPopupMenu: (ContextMenus on: self).
        (model := contextTree model)
                                        contentsBlock: [ :each | {each printString} ].
        ^ contextTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	contextTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    isLastContextSelected [
        <category: 'item selection'>

	^ self selectedContext == context
    ]

    selectLastContext [
        <category: 'item selection'>

	contextTree selectLastItem
    ]

    selectFirstContext [
        <category: 'item selection'>

	contextTree selectFirstItem
    ]

    hasSelectedContext [
	<category: 'testing'>

	^ contextTree hasSelectedItem
    ]

    selectedContext [
	<category: 'accessing'>

	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
        ^ contextTree selection
    ]

    state [
        <category: 'actions'>

        "TODO: add ContextState."
        contextTree hasSelectedItem ifTrue: [
            ^MethodState with: contextTree selection method method ].
        ^BrowserState new
    ]

    positionOfSelectedContext [
	<category: 'accessing'>

	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
	^ contextList findFirst: [ :each | each == self selectedContext ].
    ]
]

