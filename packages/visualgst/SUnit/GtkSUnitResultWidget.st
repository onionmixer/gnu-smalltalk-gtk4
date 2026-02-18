"======================================================================
|
| GtkSUnitResult class definition
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

GtkConcreteWidget subclass: GtkSUnitResult [
    | model resultTree results |
    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    buildTreeView [
        <category: 'user interface'>

	| gesture |
        resultTree := GTK.GtkTreeView newWithTextColumn: self model title: 'Results'.
	gesture := GTK.GtkGestureClick new.
	gesture setButton: 3.
	gesture connectSignal: 'pressed' to: self selector: #'onPress:nPress:x:y:'.
	resultTree addController: gesture.
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    model [
        <category: 'model'>

        ^ model ifNil: [
            model := GTK.GtkTreeStore new: 2 varargs: {GTK.GValue gTypeString. GLib.GType oopType} ]
    ]

    clearModel [
	<category: 'model'>

	self model clear
    ]

    results: aSet [
	<category: 'accessing'>

	self clearModel.
	results := aSet.
	results do: [ :each |
	    self model appendItem: {each displayString. each} ]
    ]

    onPress: gesture nPress: nPress x: x y: y [
	<category: 'events'>

	| gmenu actionGroup popover action symbol |
	actionGroup := GTK.GSimpleActionGroup new.
	gmenu := GTK.GMenu new.
	action := GTK.GSimpleAction new: 'debug-test' parameterType: nil.
	action connectSignal: 'activate' to: self selector: #debugTest.
	actionGroup insert: action.
	gmenu append: 'Run test' detailedAction: 'popup.debug-test'.
	symbol := self selectedMethodSymbol.
	action := GTK.GSimpleAction new: 'browse-implementors' parameterType: nil.
	action connectSignal: 'activate' to: self selector: #browseImplementors.
	action setEnabled: symbol notNil.
	actionGroup insert: action.
	gmenu append: 'Browse implementors' detailedAction: 'popup.browse-implementors'.
	popover := GTK.GtkPopoverMenu newFromModel: gmenu.
	popover insertActionGroup: 'popup' group: actionGroup.
	popover setParent: resultTree.
	popover setHasArrow: false.
	popover popup.
	popover connectSignal: 'closed' to: popover selector: #'unparent'.
    ]

    debugTest [
	<category: 'event'>
	
        DebugTestCommand executeOn: self
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ resultTree hasSelectedItem
    ]

    state [
        <category: 'state'>
        resultTree hasSelectedItem ifTrue: [
            ^MethodState on: self selectedResult with: (self selectedResult class lookupSelector: self selectedResult selector) ].
        ^BrowserState new
    ]
	
    selectedMethodSymbol [
        <category: 'accessing'>

        ^ self selectedResult ifNotNil: [ :result | result selector ]
    ]

    selectedMethod [
        <category: 'accessing'>

        self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
        ^ self class compiledMethodAt: self selectedMethodSymbol
    ]

    selectedResult [
        <category: 'accessing'>

	| iter |
        (iter := resultTree selectedIter) ifNil: [ self error: 'Nothing is selected' ].
        ^ self model getOop: iter column: 1
    ]

    browseImplementors [
        OpenImplementorCommand executeOn: self
    ]
]

