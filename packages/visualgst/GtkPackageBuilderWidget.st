"======================================================================
|
| GtkPackageBuilderWidget class definition
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

GtkConcreteWidget subclass: GtkPackageBuilderWidget [

    | classList ressourceList packName namespace provide provideList test classCategory prereq prereqList entries |

    initialize [
        <category: 'initialization'>

	entries := Dictionary new.
        self mainWidget: (GTK.GtkScrolledWindow withViewport: self buildMainWidget)
    ]

    buildMainWidget [
        <category: 'user interface'>

        ^ (GTK.GtkBox new: GTK.Gtk gtkOrientationVertical spacing: 3)
            append: self buildPackageNameEntry mainWidget;
	    append: self buildNamespaceEntry mainWidget;
            append: self buildPackageEntry mainWidget;
	    append: self buildPrereq;
	    append: self buildProvideEntry;
	    append: self buildTestsEntry mainWidget;
	    append: self buildClassCategoryEntry mainWidget;
	    append: self buildClassCategory;
	    append: self buildRessourcesEntry;
	    append: self buildButtons;
            yourself
    ]

    buildPackageNameEntry [
        <category: 'user interface'>

	^ packName := GtkEntryWidget labeled: 'Package name :'
    ]

    buildNamespaceEntry [
        <category: 'user interface'>

	^ namespace := GtkEntryWidget labeled: 'Namespace :'
    ]

    buildPackageEntry [
        <category: 'user interface'>

	^ prereq := GtkEntryWidget labeled: 'Package :'
    ]

    buildPrereqEntry [
        <category: 'user interface'>

	prereqList := GtkSimpleListWidget named: 'Packages prerequired :'.
	^ prereqList mainWidget
    ]

    buildPrereq [

        | hbox vbox add remove |
        hbox := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 0.

        hbox append: self buildPrereqEntry.
        add := GTK.GtkButton createButton: 'list-add-symbolic'.
        add
            setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #addPrereq.

        vbox := GTK.GtkBox new: GTK.Gtk gtkOrientationVertical spacing: 0.
        vbox append: add.

        remove := GTK.GtkButton createButton: 'list-remove-symbolic'.
        remove
            setTooltipText: 'Remove the selected file from the list'.
        vbox append: remove.
        hbox append: vbox.
        ^ hbox
    ]

    buildProvideEntry [
        <category: 'user interface'>

	provideList := GtkSimpleListWidget named: 'Provides :'.
	^ provideList mainWidget
    ]

    buildTestsEntry [
        <category: 'user interface'>

	^ test := GtkEntryWidget labeled: 'Tests :'
    ]

    buildClassCategoryEntry [
        <category: 'user interface'>

	^ classCategory := GtkEntryWidget labeled: 'Class category :'
    ]

    buildClassCategory [

	| hbox vbox add remove |
	hbox := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 0.

	hbox append: self buildFilesEntry.
        add := GTK.GtkButton createButton: 'list-add-symbolic'.
        add
	    setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #addCategory.

	vbox := GTK.GtkBox new: GTK.Gtk gtkOrientationVertical spacing: 0.
        vbox append: add.

        remove := GTK.GtkButton createButton: 'list-remove-symbolic'.
	remove
	    setTooltipText: 'Remove the selected file from the list'.
        vbox append: remove.
        hbox append: vbox.
	^ hbox
    ]

    buildFilesEntry [
        <category: 'user interface'>

        classList := GtkSimpleListWidget named: 'Class category :'.
        ^ classList mainWidget
    ]

    buildRessourcesEntry [
        <category: 'user interface'>

        ressourceList := GtkSimpleListWidget named: 'Ressources :'.
        ^ ressourceList mainWidget
    ]

    buildButtons [
        <category: 'user interface'>

        | hbox add cancel |
        hbox := GTK.GtkBox new: GTK.Gtk gtkOrientationHorizontal spacing: 0.

        add := GTK.GtkButton createButton: 'list-add-symbolic'.
        add
            setTooltipText: 'Save the package';
            connectSignal: 'clicked' to: self selector: #buildPackage.

        hbox append: add.

        cancel := GTK.GtkButton createButton: 'list-remove-symbolic'.
        cancel
            setTooltipText: 'Cancel'.
        hbox append: cancel.
        ^ hbox
    ]

    addPrereq [

	prereqList model append: prereq text
    ]

    addCategory [
    ]

    buildPackage [
    ]
]

