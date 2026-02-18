"======================================================================
|
| GtkClock class definition
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

Smalltalk.Object subclass: GtkClock [
    | canvas hour minute process radius second window x y |

    GtkClock class >> open [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    show;
	    yourself
    ]

    GtkClock class >> openSized: aPoint [
	<category: 'user interface'>
	
	^ (self new)
	    initialize;
	    resize: aPoint;
	    show;
	    yourself
    ]

    quit [
	<category: 'events'>

	process terminate.
	window hide
    ]

    time [
	<category: 'time'>

	| now |
	now := DateTime now.
        hour := now hour.
        minute := now minute.
        second := now second.
    ]

    clearArea: aGtkAllocation [
	<category: 'drawing'>

	| res |
        res := aGtkAllocation castTo: (CIntType arrayType: 4).

        canvas saveWhile: [
            canvas
                rectangle: ((0@0) extent: ((res at: 2) @ (res at: 3)));
                operator: #clear;
                fill ]
    ]

    drawClockCircle: context [
	<category: 'drawing'>

        context
            lineWidth: 6;
            stroke: [ context arc: x@y radius: radius from: 0 to: Float pi * 2 ]
    ]

    drawHourMarker: context [
	<category: 'drawing'>

        1 to: 12 do: [ :i |
            context
                lineWidth: 4;
                stroke: [ | inset |
                    inset := 0.1 * radius.
                    context
                        moveTo: (x + ((radius - inset) * (i * Float pi / 6.0) cos)) @ (y + ((radius - inset) * (i * Float pi / 6.0) sin));
                        lineTo: (x + (radius * (i * Float pi / 6.0) cos)) @ (y + (radius * (i * Float pi / 6.0) sin)) ] ]
    ]

    drawClockLine: context angle: anAngFloat [
	<category: 'drawing'>

        context
            lineWidth: 4;
            paint: [
                context stroke: [
                    context
                        sourceRed: 1 green: 0.2 blue: 0.2 alpha: 1.0;
                        moveTo: x@y;
                        lineTo: (x + (radius * anAngFloat  cos)) @ (y + (radius * anAngFloat sin)) ] ]
            withAlpha: 0.64
    ]

    drawHourLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (hour \\ 12 * (Float pi / 6.0)) - (Float pi / 2.0).
    ]

    drawMinuteLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (minute * (Float pi / 30.0)) - (Float pi / 2.0)
    ]

    drawSecondLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (second * (Float pi / 30.0)) - (Float pi / 2.0)
    ]

    drawClock: context [
	<category: 'drawing'>

	self
            drawClockCircle: context;
            drawHourMarker: context;
            drawHourLine: context;
            drawMinuteLine: context;
            drawSecondLine: context
    ]

    draw: aGtkWidget context: aCairoContext [
	<category: 'drawing'>

	| cr |
	cr := Cairo.CairoContext context: aCairoContext.
	canvas := cr.

	x := 128.
	y := 128.

	self
	    clearArea: aGtkWidget getAllocation;
	    time;
	    drawClock: cr.

	^ true
    ]

    initialize [
	<category: 'intialization'>

	window := (GTK.GtkWindow new: GTK.Gtk gtkWindowToplevel).
	window
	    connectSignal: 'draw' to: self selector: #'draw:context:';
	    connectSignal: 'close-request' to: self selector: #'delete:';
	    setDecorated: false.
	radius := 100
    ]

    delete: aGtkWidget [
        <category: 'windows event'>

        self quit.
        ^ true
    ]

    resize: aPoint [
	<category: 'user interface'>

	window resize: aPoint x height: aPoint y
    ]

    show [
	| delay |

	delay := Delay forSeconds: 1.
	window show.
	process := [ [ true ] whileTrue: [ window queueDraw. delay wait ] ] fork
    ]
]
