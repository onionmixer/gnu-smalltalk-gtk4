Gtk class extend [

    gstGtkInit [
	"For backwards compatibility."
    ]

    gtkInitialized [
	<category: 'C call-outs'>
	<cCall: 'gtkInitialized' returning: #boolean args: #()>
    ]

]


"GtkAccelGroup removed in GTK4. Use GtkShortcutController instead."


"GtkObject signals replaced with GObject signal API."

GLib.GObject extend [
    signalEmitByName: signal args: argsArray [
	<category: 'C call-outs'>
	<cCall: 'g_signal_emit_by_name' returning: #void
	args: #(#self #string #variadic)>
    ]

    signalEmitStopByName: signal [
	"Stop the current emission of the named signal."
	<category: 'signals'>
	| signalId detail |
	signalId := GLib.GObject signalLookup: signal itype: (GLib.GType type: self class).
	signalId = 0 ifFalse: [
	    GLib.GObject signalStopEmission: self signalId: signalId detail: 0 ]
    ]
]

"GTK4: GdkWindow replaced by GdkSurface. gdk_cairo_create removed;
 use the cairo context provided by GtkDrawingArea draw function."


GtkWidget extend [

    getAllocation [
	<category: 'C call-outs'>
	<cCall: 'gstGtkWidgetGetAllocation' returning: #{GtkAllocation}
	args: #(#self )>

    ]

    getSurface [
	"GTK4: returns the GdkSurface for this widget's native ancestor."
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetSurface' returning: #cObject args: #(#self )>

    ]

    "Backwards compatibility alias."
    getWindow [
	<category: 'accessing'>
	^self getSurface
    ]

    getState [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetState' returning: #int args: #(#self )>

    ]

    getFlags [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetFlags' returning: #int args: #(#self )>

    ]

    setFlags: flags [
	<category: 'C call-outs'>
	<cCall: 'gstGtkSetFlags' returning: #void args: #(#self #int )>

    ]

    unsetFlags: flags [
	<category: 'C call-outs'>
	<cCall: 'gstGtkUnsetFlags' returning: #void args: #(#self #int )>

    ]

]


"GTK4: GtkContainer removed. Child management is widget-specific."



GtkTreeModel extend [

    getOop: iter column: aColumn [
	<category: 'C call-outs'>
	<cCall: 'gstGtkTreeModelGetOOP' returning: #smalltalk
	args: #(#self #cObject #int )>

    ]

]



GtkTreeStore extend [

    setOop: iter column: aColumn value: aValue [
	<category: 'C call-outs'>
	<cCall: 'gstGtkTreeStoreSetOOP' returning: #void
	args: #(#self #cObject #int #smalltalk )>

    ]

]



GtkListStore extend [

    setOop: iter column: aColumn value: aValue [
	<category: 'C call-outs'>
	<cCall: 'gstGtkListStoreSetOOP' returning: #void
	args: #(#self #cObject #int #smalltalk )>

    ]

]



GtkDialog extend [

    getVBox [
	<category: 'C call-outs'>
	<cCall: 'gstGtkDialogGetVBox' returning: #{GtkWidget} args: #(#self )>

    ]

    "GTK4: getActionArea removed."

]



GtkScrolledWindow extend [

    getHscrollbarVisible [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetHscrollbarVisible' returning: #boolean args: #(#self )>

    ]

    getVscrollbarVisible [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetVscrollbarVisible' returning: #boolean args: #(#self )>

    ]

]



GtkAdjustment extend [

    getLower [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAdjustmentGetLower' returning: #int args: #(#self )>

    ]

    getUpper [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAdjustmentGetUpper' returning: #int args: #(#self )>

    ]

    getPageSize [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAdjustmentGetPageSize' returning: #int args: #(#self )>

    ]

]



"FIXME: funcs.awk is broken for these."

GdkPixbufLoader extend [

    write: buf count: count error: error [

	<category: 'C call-outs'>
	<cCall: 'gdk_pixbuf_loader_write' returning: #boolean
	args: #(#self #byteArray #int #cObject )>

    ]

]


"GTK4: GtkFileChooserDialog deprecated. Use GtkFileDialog for new code."
GtkFileChooserDialog extend [
    getFile [
	"GTK4: returns a GFile for the selected file."
	<category: 'C call-outs'>
        <cCall: 'gtk_file_chooser_get_file' returning: #cObject args: #( #self )>
    ]

    getCurrentFolder [
	"GTK4: returns a GFile for the current folder."
	<category: 'C call-outs'>
        <cCall: 'gtk_file_chooser_get_current_folder' returning: #cObject args: #( #self )>
    ]
]


GTK.GtkNotebook extend [

    pageNum: aGtkWidget [
        <category: 'C call-outs'>
        <cCall: 'gtk_notebook_page_num' returning: #int args: #( #self #cObject )>
    ]
]


Eval [
    GtkTreeStore superclass: GtkTreeModel.
    GtkListStore superclass: GtkTreeModel.

    "Fix GTK4 list widget class hierarchy."
    GtkSignalListItemFactory superclass: GtkListItemFactory
]


"GTK4 list widget convenience wrappers.
 The auto-generated bindings put these as Gtk class methods;
 these wrappers provide proper instance/class method APIs."

GtkStringList class extend [

    new: anArrayOfStrings [
	"Create a new GtkStringList. Pass nil or a null-terminated array."
	<category: 'instance creation'>
	^ Gtk stringListNew: anArrayOfStrings
    ]

    new [
	"Create an empty GtkStringList."
	<category: 'instance creation'>
	^ Gtk stringListNew: nil
    ]

]

GtkStringList extend [

    append: aString [
	<category: 'accessing'>
	Gtk stringListAppend: self string: aString
    ]

    remove: aPosition [
	<category: 'accessing'>
	Gtk stringListRemove: self position: aPosition
    ]

    splice: position nRemovals: nRemovals additions: additions [
	<category: 'accessing'>
	Gtk stringListSplice: self position: position nRemovals: nRemovals additions: additions
    ]

    getNItems [
	<category: 'accessing'>
	^ GList modelGetNItems: self
    ]

    getItem: position [
	"Return the GtkStringObject at position."
	<category: 'accessing'>
	^ GList modelGetItem: self position: position
    ]

]

GtkStringObject class extend [

    new: aString [
	<category: 'instance creation'>
	^ Gtk stringObjectNew: aString
    ]

]

GtkStringObject extend [

    getString [
	<category: 'accessing'>
	<cCall: 'gtk_string_object_get_string' returning: #string
	args: #( #self )>
    ]

]

GtkSingleSelection class extend [

    new: aGListModel [
	<category: 'instance creation'>
	^ Gtk singleSelectionNew: aGListModel
    ]

]

GtkSingleSelection extend [

    getSelected [
	<category: 'accessing'>
	^ Gtk singleSelectionGetSelected: self
    ]

    setSelected: position [
	<category: 'accessing'>
	Gtk singleSelectionSetSelected: self position: position
    ]

    getSelectedItem [
	<category: 'accessing'>
	^ Gtk singleSelectionGetSelectedItem: self
    ]

    getModel [
	<category: 'accessing'>
	^ Gtk singleSelectionGetModel: self
    ]

    setModel: aGListModel [
	<category: 'accessing'>
	Gtk singleSelectionSetModel: self model: aGListModel
    ]

    getAutoselect [
	<category: 'accessing'>
	^ Gtk singleSelectionGetAutoselect: self
    ]

    setAutoselect: aBoolean [
	<category: 'accessing'>
	Gtk singleSelectionSetAutoselect: self autoselect: aBoolean
    ]

    getCanUnselect [
	<category: 'accessing'>
	^ Gtk singleSelectionGetCanUnselect: self
    ]

    setCanUnselect: aBoolean [
	<category: 'accessing'>
	Gtk singleSelectionSetCanUnselect: self canUnselect: aBoolean
    ]

]

"GtkDrawingArea draw function bridge for GTK4.
 GTK4 removed the 'draw' signal. Use connectDrawTo:selector: to
 install a draw function and connect to the custom 'gst-draw' signal."

"GTK4: GdkScreen and gdk_get_default_root_window() removed.
 Use GdkMonitor helpers for screen geometry."

Gtk class extend [

    screenGetGeometry [
	"Return a GdkRectangle with the primary monitor geometry."
	<category: 'C call-outs'>
	<cCall: 'gstGtkScreenGetGeometry' returning: #{GdkRectangle} args: #()>
    ]

    screenGetMonitorWidthMm [
	"Return the physical width of the primary monitor in mm."
	<category: 'C call-outs'>
	<cCall: 'gstGtkScreenGetMonitorWidthMm' returning: #int args: #()>
    ]

    screenGetMonitorHeightMm [
	"Return the physical height of the primary monitor in mm."
	<category: 'C call-outs'>
	<cCall: 'gstGtkScreenGetMonitorHeightMm' returning: #int args: #()>
    ]

]


"Missing from auto-generated Funcs.st."

PangoFontDescription extend [

    getFamily [
	<category: 'C call-outs'>
	<cCall: 'pango_font_description_get_family' returning: #string
	args: #( #self )>
    ]

]


GtkDrawingArea extend [

    connectDrawSignal [
	"Install the GTK4 draw function bridge. This registers a custom
	 'gst-draw' GObject signal and sets a C draw function that emits it.
	 Connect to 'gst-draw' using normal connectSignal:to:selector: after
	 calling this method."
	<category: 'drawing'>
	<cCall: 'gstGtkDrawingAreaConnectDraw' returning: #void args: #(#self)>
    ]

    connectDrawTo: anObject selector: aSelector [
	"Convenience method: install draw function bridge and connect
	 the 'gst-draw' signal in one step."
	<category: 'drawing'>

	self connectDrawSignal.
	self connectSignal: 'gst-draw' to: anObject selector: aSelector.
    ]

]

