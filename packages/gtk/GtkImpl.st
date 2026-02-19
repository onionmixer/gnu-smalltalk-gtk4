"GTK4: Many types became opaque (no public struct), causing the AWK
 code generator to default their parent class to CObject instead of
 GLib.GObject.  This means classes like GSimpleAction, GtkNotebook,
 GtkEventController, etc. lose access to GObject methods defined in
 GLib.st (connectSignal:, disconnectSignal:, etc.).

 We extend CObject here with the signal-connection methods so that
 ALL GTK classes can connect signals regardless of the broken class
 hierarchy in the auto-generated Structs.st.  The underlying C functions
 use the raw GObject pointer, so this is safe."

CObject extend [

    connectSignalAfter: name to: handler selector: sel userData: userData [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignalAfter' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk #smalltalk )>
    ]

    connectSignalAfter: name to: handler selector: sel [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignalAfterNoUserData' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk )>
    ]

    connectSignal: name to: handler selector: sel userData: userData [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignal' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk #smalltalk )>
    ]

    connectSignal: name to: handler selector: sel [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignalNoUserData' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk )>
    ]

    disconnectSignal: anInteger [
       <category: 'C call-outs'>
       <cCall: 'g_signal_handler_disconnect' returning: #void
       args: #(#self #int )>
    ]
]


GtkTextBuffer extend [

    insertAtEnd: aString [
        <category: 'accessing'>

        self insert: self getEndIter text: aString
    ]
]


"GTK4: GtkAlignment removed. Use widget margin/halign/valign properties."


"GTK4: GdkWindow removed, replaced by GdkSurface.
 gdk_cairo_create removed. Use GtkDrawingArea setDrawFunc: instead."


GtkWidget extend [

    getSizeRequest [
	"Answer the natural size the widget has requisitioned.
	 GTK4: gtk_widget_size_request removed.
	 Uses gtk_widget_get_preferred_size instead."

	<category: 'accessing'>
	| minimum natural |
	minimum := GTK.GtkRequisition new.
	natural := GTK.GtkRequisition new.
	self getPreferredSize: minimum naturalSize: natural.
	^natural width value @ natural height value
    ]

]



GtkMessageDialog class extend [

    new: parent flags: flags type: type buttons: buttons message: message [
	<category: 'instance creation'>
	^self
	    new: parent
	    flags: flags
	    type: type
	    buttons: buttons
	    messageFormat: '%s'
	    varargs: {message}
    ]

    new: parent flags: flags type: type buttons: buttons message: message tip: tip [
	<category: 'instance creation'>
	^self
	    newWithMarkup: parent
	    flags: flags
	    type: type
	    buttons: buttons
	    messageFormat: '<big><b>%s</b></big>

%s'
	    varargs: {message. tip}
    ]

    newWithMarkup: parent flags: flags type: type buttons: buttons message: message [
	<category: 'instance creation'>
	^self
	    newWithMarkup: parent
	    flags: flags
	    type: type
	    buttons: buttons
	    messageFormat: (message copyReplaceAll: '%' with: '%%')
	    varargs: #()
    ]
]



GtkRequisition class extend [

    fromPoint: point [
	<category: 'instance creation'>
	| ba |
	ba := (CShortType arrayType: 2) new.
	ba at: 0 put: point x.
	ba at: 1 put: point y.
	^(ba castTo: self type)
	    addToBeFinalized;
	    yourself
    ]

]



GtkRequisition extend [

    x [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 0
    ]

    y [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 1
    ]

    asPoint [
	<category: 'conversion'>
	^
	{self width value.
	self height value}
    ]

]



GdkRectangle class extend [

    fromRectangle: rect [
	<category: 'instance creation'>
	| ba |
	ba := (CShortType arrayType: 4) new.
	ba at: 0 put: rect left.
	ba at: 1 put: rect top.
	ba at: 2 put: rect width.
	ba at: 3 put: rect height.
	^(ba castTo: self type)
	    addToBeFinalized;
	    yourself
    ]

]



GdkRectangle extend [

    left [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 0
    ]

    top [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 1
    ]

    right [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 0) + (ba at: 2)
    ]

    bottom [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 1) + (ba at: 3)
    ]

    width [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 2
    ]

    height [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 3
    ]

    origin [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 0) @ (ba at: 1)
    ]

    extent [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 2) @ (ba at: 3)
    ]

    corner [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^((ba at: 0) + (ba at: 2)) @ ((ba at: 1) + (ba at: 3))
    ]

    asRectangle [
	<category: 'conversion'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 0) @ (ba at: 1) extent: (ba at: 2) @ (ba at: 3)
    ]

]



GtkTextIter class extend [

    Prototype := nil.

    gcNew [
	^self type gcNew
    ]

    new [
	<category: 'instance creation'>
        Prototype isNil ifTrue: [ Prototype := self type gcNew ].
	^Prototype copy
	    addToBeFinalized;
	    yourself
    ]

]



GtkTextBuffer extend [

    setText: aString [
	"Set my contents"

	<category: 'accessing'>
	self setText: aString len: aString size
    ]

    insertAtCursor: aString [
	"Insert aString at the curser."

	<category: 'accessing'>
	self insertAtCursor: aString len: aString size
    ]

    getBounds [
	"Answer my entire contents."

	<category: 'accessing'>
	| start end |
	start := GTK.GtkTextIter new.
	end := GTK.GtkTextIter new.
	self getBounds: start end: end.
	^
	{start.
	end}
    ]

    getIterAtMark: mark [
	"Answer an iterator for mark"

	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTextIter new.
	self getIterAtMark: iter mark: mark.
	^iter
    ]

    getSelectionBounds [
	"Answer my selection bounds"

	<category: 'accessing'>
	| start end |
	start := GTK.GtkTextIter new.
	end := GTK.GtkTextIter new.
	self getSelectionBounds: start end: end.
	^
	{start.
	end}
    ]

    getIterAtLine: line [
	"Answer an iterator at the beginning of line."

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self getIterAtLine: result lineNumber: line.
	^result
    ]

    getIterAtLineOffset: lineNumber charOffset: charOffset [
	"Answer an iterator at offset in me."

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self
	    getIterAtLineOffset: result
	    lineNumber: lineNumber
	    charOffset: charOffset.
	^result
    ]

    getStartIter [
	"Answer a start iterator."

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self getStartIter: result.
	^result
    ]

    getEndIter [
	"Answer an end iterator"

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self getEndIter: result.
	^result
    ]

    insert: iter text: aString [
	"Insert aString at the insertion point."

	<category: 'accessing'>
	self
	    insert: iter
	    text: aString
	    len: aString size
    ]

]



Gtk class extend [
    | loop application |

    application [
	"Return the GtkApplication singleton, lazily creating and registering it."
	<category: 'application'>
	application isNil ifTrue: [
	    application := GtkApplication
		new: 'org.gnu.smalltalk.visualgst'
		flags: GLib gApplicationFlagsNone.
	    application register: nil error: nil.
	    application hold ].
	^ application
    ]

    mainQuit [
	<category: 'event loop'>
	GLib.GMainLoop mainQuit
    ]

    main [
	"Main loop implementation.  Same as gtk_main, but it splits
         g_main_context_run in two threads so that Smalltalk processes
         run.  Like gtk_main, it is ended with Gtk>>#mainQuit."

	<category: 'event loop'>
	GLib.GMainLoop main
    ]

]


"GTK4: GtkAccelGroup removed. Use GtkShortcutController instead."


GtkButton class extend [

    label: aString onPressedSend: aSymbol to: anObject [
    <category: 'instance creation'>

    ^ (GTK.GtkButton newWithLabel: aString)
        connectSignal: 'clicked' to: anObject selector: aSymbol userData: nil;
        yourself
    ]
]


GTK.GtkDialog extend [
    run [
        <category: 'services'>

        | signals loop answer modal destroyed |
        modal := self getModal.
        self setModal: true.
        destroyed := false.
        signals := {
            self
                connectSignal: 'response'
                to: [ :dialog :integer | answer := integer. loop quit ]
                selector: #value:value:.

            self
                connectSignal: 'unmap'
                to: loop
                selector: #quit.

            self
                connectSignal: 'close-request'
                to: [ answer := Gtk gtkResponseDeleteEvent. loop quit. true ]
                selector: #value.

            self
                connectSignal: 'destroy'
                to: [ destroyed := true ]
                selector: #value }.

        loop := GLib.GMainLoop pushMainLoop.
        [self show. loop run] ensure: [loop pop].
        destroyed ifFalse: [
            self setModal: modal.
            signals do: [ :each | self disconnectSignal: each ] ].
        ^answer
    ]
]


"GTK4: GtkFileChooserDialog deprecated. Use GtkFileDialog for new code."
GTK.GtkFileChooserDialog class extend [

    for: aGtkFileChooserAction title: aString parent: aGtkWidget button: aButtonLabel  [
        <category: 'instance creation'>

        ^ self
            new: aString
            parent: aGtkWidget
            action: aGtkFileChooserAction
            varargs: {'_Cancel'.
                    GTK.Gtk gtkResponseCancel.
                    aButtonLabel.
                    GTK.Gtk gtkResponseAccept.
                    nil}
    ]

    save: aString parent: aGtkWidget [
        <category: 'instance creation'>

        ^ self
            for: GTK.Gtk gtkFileChooserActionSave
            title: aString
            parent: aGtkWidget
            button: '_Save'
    ]

    load: aString parent: aGtkWidget [
        <category: 'instance creation'>

        ^ self
            for: GTK.Gtk gtkFileChooserActionOpen
            title: aString
            parent: aGtkWidget
            button: '_Open'
    ]

    selectFolder: aString parent: aGtkWidget [
        <category: 'instance creation'>

        ^ self
            for: GTK.Gtk gtkFileChooserActionSelectFolder
            title: aString
            parent: aGtkWidget
            button: '_Open'
    ]
]


"GTK4: GtkMenuItem/GtkMenu removed. Use GMenu/GAction model-based menus."


GTK.GtkScrolledWindow class extend [

    withChild: aGtkWidget [
    <category: 'instance creation'>

    ^ GTK.GtkScrolledWindow new
        setChild: aGtkWidget;
        setPolicy: GTK.Gtk gtkPolicyAutomatic vscrollbarPolicy: GTK.Gtk gtkPolicyAutomatic;
        yourself
    ]
]


GTK.GtkTextBuffer extend [

    text [
    <category: 'accessing'>

    ^ self getText: self getStartIter end: self getEndIter includeHiddenChars: false
    ]

    applyTagByName: aSymbol startOffset: aStartInteger endOffset: anEndInteger [
    <category: 'accessing'>

    | end start |
    start := GTK.GtkTextIter new.
        end := GTK.GtkTextIter new.
        self getIterAtOffset: start charOffset: aStartInteger.
        self getIterAtOffset: end charOffset: anEndInteger.
        self applyTagByName: aSymbol start: start end: end
    ]

    getIterAtOffset: offset [
    <category: 'accessing'>

    | result |
    result := GTK.GtkTextIter new.
    self getIterAtOffset: result charOffset: offset.
    ^ result
    ]

    iterOfSelectedText [
        <category: 'text accessing'>

        | iter |
        self getHasSelection
                ifTrue: [ iter := self getSelectionBounds ifNil: [ ^ self ].
                        (iter at: 1) getOffset > ((iter at: 2) getOffset)
                            ifTrue: [ iter swap: 1 with: 2 ] ]
                ifFalse: [ iter := {self getStartIter. self getEndIter} ].
        ^ iter
    ]

    selectedText [
        <category: 'text accessing'>

        | iter |
        iter := self iterOfSelectedText.
        ^ self getText: (iter at: 1) end: (iter at: 2) includeHiddenChars: false
    ]
]


GTK.GtkTreeModel extend [

    at: aGtkTreeIter [
        <category: 'accessing'>

        | values |
        aGtkTreeIter ifNil: [ ^ nil ].
        values := OrderedCollection new.
        0 to: self getNColumns - 1 do: [ :column |
            values add: (self at: aGtkTreeIter column: column) ].
        ^ values
    ]

    at: aGtkTreeIter column: anInteger [
        <category: 'accessing'>

        ^ self getOop: aGtkTreeIter column: anInteger
    ]

    at: aGtkTreeIter column: anInteger put: anObject [
        <category: 'accessing'>

        self setOop: aGtkTreeIter column: anInteger value: anObject
    ]

    at: aGtkTreeIter put: anArray [
        <category: 'accessing'>

        1 to: anArray size do: [ :i |
            self at: aGtkTreeIter column: i - 1 put: (anArray at: i) ]
    ]

    at: aGtkTreeIter do: aBlock [
	<category: 'accessing'>

	(self at: aGtkTreeIter) do: aBlock
    ]

    itersDo: aBlock iter: aGtkTreeIter [
	<category: 'accessing'>

	| childIter |
	childIter := GTK.GtkTreeIter new.
	aBlock value: aGtkTreeIter.
	(self iterChildren: childIter parent: aGtkTreeIter) ifTrue: [ self itersDo: aBlock iter: childIter ].
	[ self iterNext: aGtkTreeIter ] whileTrue: [
	    aBlock value: aGtkTreeIter.
            (self iterChildren: childIter parent: aGtkTreeIter) ifTrue: [ self itersDo: aBlock iter: childIter ] ]
    ]

    itersDo: aBlock [
	<category: 'accessing'>

	| iter child |
	((iter := self getIterFirst) isNil or: [ (self iterIsValid: iter) not ] ) ifTrue: [ ^ nil ].
	self itersDo: aBlock iter: iter
    ]

    do: aBlock [
        <category: 'accessing'>

        self itersDo: [ :iter |
            aBlock value: (self at: iter) value: iter ]
    ]
]


