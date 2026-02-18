"======================================================================
|
| MenuBuilderTest class definition
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

Command subclass: FakeCommandA [

    item [
	^ 'FakeA'
    ]
]

Command subclass: FakeCommandB [

    item [
        ^ 'FakeB'
    ]
]

MenuBuilder subclass: TestMenuBuilderA [

    TestMenuBuilderA class >> menus [

        ^ {FakeCommandA.
        MenuSeparator.
	FakeCommandB}
    ]

]

TestCase subclass: MenuBuilderTest [

    | accelGroup actionGroup |

    accelGroup [
        <category: 'accessing'>

        ^ accelGroup ifNil: [ accelGroup := GTK.GtkShortcutController new ]
    ]

    actionGroup [
        <category: 'accessing'>

        ^ actionGroup ifNil: [ actionGroup := GTK.GSimpleActionGroup new ]
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Assistant>'
    ]

    testMenuBuilder [
	<category: 'testing'>

	| menu |
	menu := TestMenuBuilderA browserBuildOn: self.
	self assert: menu size = 3.
	self assert: (menu at: 1) isNil not.
	self assert: (menu at: 2) isNil.
	self assert: (menu at: 3) isNil not
    ]
]
