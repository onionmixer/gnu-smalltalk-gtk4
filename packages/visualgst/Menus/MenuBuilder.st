"======================================================================
|
| MenuBuilder class definition
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

Object subclass: MenuBuilder [

    | commands target |

    MenuBuilder class >> on: aGtkBrowser [
        <category: 'menu-building'>

        ^ self new 
	    target: aGtkBrowser; 
	    connect;
	    yourself
    ]

    MenuBuilder class >> browserBuildOn: aGtkBrowser [
        <category: 'menu-building'>

        ^ (self on: aGtkBrowser) asMenuItems
    ]

    MenuBuilder class >> buildToolbarOn: aGtkBrowser [
        <category: 'menu-building'>

        ^ (self on: aGtkBrowser) asToolItems
    ]

    asPopupMenu [
	"Build a GtkPopoverMenu for use as a context menu."

	| gmenu actionGroup popover |
	actionGroup := GTK.GSimpleActionGroup new.
	gmenu := GTK.GMenu new.
	self buildMenuOn: gmenu actionGroup: actionGroup prefix: 'popup'.
	popover := GTK.GtkPopoverMenu newFromModel: gmenu.
	popover insertActionGroup: 'popup' group: actionGroup.
	popover setHasArrow: false.
	^ popover
    ]

    asMenuItems [
	"Build GMenuItems for use in the menu bar. Target must be a GtkMainWindow."

	^ commands collect: [ :each |
	    each buildMenuItemOn: target actionGroup prefix: 'win' ]
    ]

    asToolItems [

        ^ commands collect: [ :each | self target appendToolItem: each buildToolItem ]
    ]

    buildMenuOn: aGMenu actionGroup: anActionGroup prefix: aPrefix [
	"Populate aGMenu with items from commands. Nil items become section breaks."

	| section |
	section := GTK.GMenu new.
	commands do: [ :each | | item |
	    item := each buildMenuItemOn: anActionGroup prefix: aPrefix.
	    item isNil
		ifTrue: [
		    aGMenu appendSection: nil section: section.
		    section := GTK.GMenu new ]
		ifFalse: [ section appendItem: item ] ].
	section getNItems > 0 ifTrue: [
	    aGMenu appendSection: nil section: section ]
    ]

    appendTo: aGMenu actionGroup: anActionGroup prefix: aPrefix [
	"Append menu items to an existing GMenu."

	self buildMenuOn: aGMenu actionGroup: anActionGroup prefix: aPrefix
    ]

    target [

        ^ target
    ]

    target: anObject [

        target := anObject.
    ]

    connect [

        commands := self class menus collect: [ :each | each on: self target ]
    ]
]

