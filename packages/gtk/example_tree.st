"======================================================================
|
|   Smalltalk Gtk+ bindings examples — Tree view using GTK4 widgets
|
|   Uses GtkTreeListModel + GtkListView + GtkSignalListItemFactory
|   + GtkTreeExpander to display a class hierarchy tree.
|
 ======================================================================"


PackageLoader fileInPackage: 'GTK'.


Namespace current: GTK [

Object subclass: TreeExample [
    | window listView selectionModel treeListModel
      rootStringList entries nextId selection |

    <category: nil>
    <comment: nil>

    closeClicked: aSender [
	<category: 'event handling'>
	window destroy
    ]

    closeRequest [
	<category: 'event handling'>
	Gtk mainQuit.
	^ false
    ]

    selectionChangedCallback: aModel pos: aPos nItems: aNItems [
	<category: 'event handling'>
	| pos row stringObj idStr |
	pos := selectionModel getSelected.
	pos < 0 ifTrue: [ ^ self ].
	row := treeListModel getRow: pos.
	row ifNil: [ ^ self ].
	stringObj := Gtk treeListRowGetItem: row.
	stringObj ifNil: [ ^ self ].
	idStr := Gtk stringObjectGetString: stringObj.
	selection := entries at: idStr asInteger ifAbsent: [ nil ].
	('Selection: ' , selection printString) printNl
    ]

    assignId: anObject [
	<category: 'private'>
	| id |
	id := nextId.
	nextId := nextId + 1.
	entries at: id put: anObject.
	^ id
    ]

    onCreateChildren: aModel id: anId [
	"Called by the C bridge when a node is expanded.
	 Return a GtkStringList of child IDs, or nil for leaf nodes."
	<category: 'tree model'>
	| cls children sorted childList |
	cls := entries at: anId ifAbsent: [ ^ nil ].
	children := self getChildNodesFor: cls.
	(children isNil or: [ children isEmpty ]) ifTrue: [ ^ nil ].
	sorted := children asSortedCollection: [ :a :b |
	    (a name ifNil: [ '<unnamed>' ]) <= (b name ifNil: [ '<unnamed>' ]) ].
	childList := GtkStringList new.
	sorted do: [ :each |
	    childList append: (self assignId: each) printString ].
	^ childList
    ]

    onSetup: aFactory listItem: aListItem [
	"Create widget tree: GtkTreeExpander > GtkLabel.
	 Cast aListItem to GtkListItem (arrives as GtkWidget from GObject bridge).
	 Use GtkTreeExpander new for proper type dispatch."
	<category: 'factory callbacks'>
	| listItem expander label |
	listItem := GtkListItem address: aListItem address.
	expander := GtkTreeExpander new.
	label := GtkLabel new: ''.
	label setHalign: Gtk gtkAlignStart.
	expander setChild: label.
	listItem setChild: expander.
    ]

    onBind: aFactory listItem: aListItem [
	"Bind data to a tree row.
	 Cast returned widgets to their proper Smalltalk classes."
	<category: 'factory callbacks'>
	| listItem row stringObj idStr cls expander label |
	listItem := GtkListItem address: aListItem address.
	row := listItem getItem.
	row ifNil: [ ^ self ].
	stringObj := Gtk treeListRowGetItem: row.
	stringObj ifNil: [ ^ self ].
	idStr := Gtk stringObjectGetString: stringObj.
	cls := entries at: idStr asInteger ifAbsent: [ nil ].
	expander := GtkTreeExpander address: (listItem getChild) address.
	label := GtkLabel address: (expander getChild) address.
	cls isNil
	    ifTrue: [ label setLabel: '???' ]
	    ifFalse: [ label setLabel: (cls name ifNil: [ '<unnamed>' ]) ].
	expander setListRow: row.
    ]

    open [
	<category: 'window layout'>
	"Build the GTK4 tree view UI."

	| vbox frame scroll factory button |
	entries := Dictionary new.
	nextId := 1.

	window := GtkWindow new.
	window setTitle: 'Tree Example (GTK4)'.
	window connectSignal: 'close-request' to: self selector: #closeRequest.
	vbox := GtkBox new: Gtk gtkOrientationVertical spacing: 9.
	window setChild: vbox.
	frame := GtkFrame new: nil.
	vbox append: frame.
	scroll := GtkScrolledWindow new.
	frame setChild: scroll.
	scroll setPolicy: Gtk gtkPolicyAutomatic
	    vscrollbarPolicy: Gtk gtkPolicyAutomatic.

	"Build root model with top-level classes."
	rootStringList := GtkStringList new.
	treeListModel := GtkTreeListModel
	    newWithRoot: rootStringList passthrough: false autoexpand: false.
	treeListModel connectCreateChildren: self selector: #'onCreateChildren:id:'.

	"Factory for rendering tree rows."
	factory := GtkSignalListItemFactory new.
	factory connectSignal: 'setup' to: self selector: #'onSetup:listItem:'.
	factory connectSignal: 'bind' to: self selector: #'onBind:listItem:'.

	"Selection model."
	selectionModel := GtkSingleSelection new: treeListModel.
	selectionModel
	    connectSignal: 'selection-changed'
	    to: self
	    selector: #'selectionChangedCallback:pos:nItems:'
	    userData: nil.

	"List view."
	listView := GtkListView new: selectionModel factory: factory.
	scroll setChild: listView.

	"Close button."
	button := GtkButton newWithLabel: 'Close'.
	button
	    connectSignal: 'clicked'
	    to: self
	    selector: #closeClicked:
	    userData: nil.
	vbox append: button.

	"Display."
	window setDefaultSize: 300 height: 500.
	window show
    ]

    topLevelNodes [
	<category: 'tree data'>
	| cls |
	cls := Array
		    streamContents: [:stream | Smalltalk allClassesDo: [:each | stream nextPut: each]].
	^cls
	    select: [:each | each superclass isNil or: [each superclass environment ~= Smalltalk]]
    ]

    getChildNodesFor: aNode [
	<category: 'tree data'>
	aNode isNil ifTrue: [^self topLevelNodes].
	aNode isClass
	    ifTrue: [^aNode subclasses select: [:each | each environment = Smalltalk]].
	^nil
    ]

    buildTree [
	<category: 'tree data'>
	"Populate the root string list with top-level class IDs."
	| roots sorted |
	roots := self topLevelNodes.
	sorted := roots asSortedCollection: [ :a :b |
	    (a name ifNil: [ '<unnamed>' ]) <= (b name ifNil: [ '<unnamed>' ]) ].
	sorted do: [ :each |
	    rootStringList append: (self assignId: each) printString ]
    ]

    defaultExpand [
	<category: 'tree operations'>
	"Expand all root nodes."
	| n |
	n := GList modelGetNItems: treeListModel.
	0 to: n - 1 do: [ :i |
	    | row |
	    row := treeListModel getRow: i.
	    (row notNil and: [ row isExpandable ])
		ifTrue: [ row setExpanded: true ] ]
    ]
]

]



Namespace current: GTK [
    TreeExample new open buildTree defaultExpand.
    Gtk main
]

