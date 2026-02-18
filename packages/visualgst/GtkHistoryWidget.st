"======================================================================
|
| GtkHistoryWidget class definition
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

GtkConcreteWidget subclass: GtkHistoryWidget [
    | browser model widget |

    GtkHistoryWidget class >> new [
	<category: 'instance creation'>

	^ super new
		initialize;
		yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildListView
    ]

    browser: aBrowser [
	<category: 'accessing'>

	browser := aBrowser
    ]

    buildListView [
	<category: 'user interface'>

	| gesture |
        widget := GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'History'}}.
	gesture := GTK.GtkGestureClick new.
	gesture setButton: 3.
	gesture connectSignal: 'pressed' to: self selector: #'onPress:nPress:x:y:'.
	widget addController: gesture.
        widget getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        widget getSelection connectSignal: 'changed' to: self selector: #onSelectionChanged.
        (model := GtkListModel on: widget getModel)
                                        contentsBlock: [ :each | {each name displayString} ].
        ^ GTK.GtkScrolledWindow withChild: widget
    ]

    refresh: historyStack [
	<category: 'user interface'>

	model
	    item: historyStack;
	    refresh.

        widget selectNth: historyStack selectedIndex.
    ]

    onPress: gesture nPress: nPress x: x y: y [
        <category: 'button event'>

        | gmenu actionGroup popover action |
        actionGroup := GTK.GSimpleActionGroup new.
        gmenu := GTK.GMenu new.
        action := GTK.GSimpleAction new: 'inspect-class' parameterType: nil.
        action connectSignal: 'activate' to: self selector: #inspectClass.
        actionGroup insert: action.
        gmenu append: 'Inspect a class' detailedAction: 'popup.inspect-class'.
        action := GTK.GSimpleAction new: 'browse-tabbed-class' parameterType: nil.
        action connectSignal: 'activate' to: self selector: #browseTabbedClass.
        actionGroup insert: action.
        gmenu append: 'Open in new tab' detailedAction: 'popup.browse-tabbed-class'.
        popover := GTK.GtkPopoverMenu newFromModel: gmenu.
        popover insertActionGroup: 'popup' group: actionGroup.
        popover setParent: widget.
        popover setHasArrow: false.
        popover popup.
        popover connectSignal: 'closed' to: popover selector: #'unparent'.
    ]

    targetObject [
        <category: 'evaluation'>

        ^ widget selection
    ]

    updateBrowser: aBrowser [
	<category: 'event'>

        aBrowser 
	    selectANamespace: self targetObject environment;
	    selectAClass: self targetObject
    ]
    
    inspectIt: anObject [
        <category: 'smalltalk event'>

        GtkInspector openOn: anObject
    ]

    inspectClass [
	<category: 'event'>

	widget hasSelectedItem ifFalse: [ ^ self ].
	InspectItCommand executeOn: self
    ]

    onSelectionChanged [
	<category: 'event'>

	widget hasSelectedItem ifFalse: [ ^ self ].
        model item selectedIndex = widget selectedIndex ifTrue: [^self].
        model item selectItem: widget selectedIndex.
    ]

    browseTabbedClass [
	<category: 'event'>

        "TODO: should reuse OpenTabbedBrowserCommand by giving a state to
         GtkHistoryWidget."
	widget hasSelectedItem ifFalse: [ ^ self ].
        self updateBrowser: GtkLauncher uniqueInstance classBrowser
    ]

    state [
        <category: 'state'>

        ^model item current
    ]
]

