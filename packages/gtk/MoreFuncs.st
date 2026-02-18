Gtk class extend [

    gstGtkInit [
	"For backwards compatibility."
    ]

    gtkInitialized [
	<category: 'C call-outs'>
	<cCall: 'gtkInitialized' returning: #boolean args: #()>
    ]

]



GtkAccelGroup extend [
    connect: accelKey accelModes: accelMods accelFlags: accelFlags receiver: receiver selector: selector userData: userData [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAccelGroupConnect' returning: #void
	args: #( #selfSmalltalk #int #int #int #smalltalk #smalltalk #smalltalk)>
    ]

    connect: accelKey accelModes: accelMods accelFlags: accelFlags receiver: receiver selector: selector [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAccelGroupConnectNoUserData' returning: #void
	args: #( #selfSmalltalk #int #int #int #smalltalk #smalltalk )>
    ]
]


"GtkObject signals replaced with GObject signal API for GTK3."

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

GTK.GdkWindow extend [

    cairoCreate [
        <category: 'C call-outs'>
        <cCall: 'gdk_cairo_create' returning: #cObject args: #( #self )>
    ]
]


GtkWidget extend [

    getAllocation [
	<category: 'C call-outs'>
	<cCall: 'gstGtkWidgetGetAllocation' returning: #{GtkAllocation}
	args: #(#self )>
	
    ]

    getWindow [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetWindow' returning: #{GdkWindow} args: #(#self )>
	
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



GtkContainer extend [

    child: widget propertiesAt: name [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetChildProperty' returning: #smalltalk
	args: #(#self #cObject #string )>
	
    ]

    child: widget propertiesAt: name put: anObject [
	<category: 'C call-outs'>
	<cCall: 'gstGtkSetChildProperty' returning: #void
	args: #(#self #cObject #string #smalltalk )>
	
    ]

]



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

    getActionArea [
	<category: 'C call-outs'>
	<cCall: 'gstGtkDialogGetActionArea' returning: #{GtkWidget}
	args: #(#self )>
	
    ]

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


GtkFileChooserDialog extend [
    getFilename [
	<category: 'C call-outs'>
        <cCall: 'gtk_file_chooser_get_filename' returning: #string args: #( #self )>
    ]

    getCurrentFolder [
	<category: 'C call-outs'>
        <cCall: 'gtk_file_chooser_get_current_folder' returning: #string args: #( #self )>
    ]
]


GtkContainer extend [

    getFocusChild [
	<category: 'C call-outs'>
        <cCall: 'gtk_container_get_focus_child' returning: #{GtkWidget}
        args: #( #self )>
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

