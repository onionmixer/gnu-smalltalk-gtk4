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
    GtkListStore superclass: GtkTreeModel
]

