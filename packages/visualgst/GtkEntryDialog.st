"======================================================================
|
| GtkEntryDialog class definition
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

Object subclass: GtkEntryDialog [
    | window entryWidget okBlock |

    GtkEntryDialog class >> title: aTitle text: aDescription [
	<category: 'instance creation'>

	^ (self new)
	    title: aTitle text: aDescription;
	    yourself
    ]

    title: aTitle text: aDescription [
	<category: 'initialization'>

	window := GTK.GtkWindow new.
	window setTitle: aTitle.
	window setModal: true.
	window setDefaultSize: 400 height: -1.
	self buildCentralWidget: aDescription.
    ]

    hasPressedOk: aBlock [
	<category: 'testing'>

	okBlock := aBlock.
	window show
    ]

    result [
	<category: 'accessing'>

	^ entryWidget getText
    ]

    onOk [
	<category: 'callbacks'>

	okBlock ifNotNil: [ okBlock value ].
	window destroy
    ]

    onCancel [
	<category: 'callbacks'>

	window destroy
    ]

    buildCentralWidget: aString [
	<category: 'user interface'>

	| vbox hbox buttonBox okButton cancelButton |
	hbox := (GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 6)
		    setHomogeneous: true;
		    yourself.
	hbox
	    append: (GTK.GtkLabel new: aString);
	    append: (entryWidget := GTK.GtkEntry new).

	okButton := GTK.GtkButton newWithLabel: 'Ok'.
	okButton connectSignal: 'clicked' to: self selector: #onOk.
	cancelButton := GTK.GtkButton newWithLabel: 'Cancel'.
	cancelButton connectSignal: 'clicked' to: self selector: #onCancel.

	buttonBox := (GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 6)
			setHomogeneous: true;
			setHalign: GTK.Gtk gtkAlignEnd;
			yourself.
	buttonBox
	    append: cancelButton;
	    append: okButton.

	vbox := GTK.GtkBox new: GTK.Gtk gtkOrientationVertical spacing: 12.
	vbox setMarginTop: 12.
	vbox setMarginBottom: 12.
	vbox setMarginStart: 12.
	vbox setMarginEnd: 12.
	vbox
	    append: hbox;
	    append: buttonBox.
	window setChild: vbox
    ]
]

