##
## Set your preferred window name and colors here! Use ASSESS to update the window!
##
var COLOR whitesmoke
var WINDOW Visual

action var FACING ($2) $1 when ^An? (.*) \((\d+)\: .*\) is facing you
action if matchre ("%FLANK1","0") then var FLANK1 ($2) $1;if !matchre ("%FLANK1","0") then var FLANK2 ($2) $1 when ^An? (.*) \((\d+)\: (.*)\) is flanking you
action if matchre ("%BEHIND1","0") then var BEHIND1 ($2) $1;if !matchre ("%BEHIND1","0") then var BEHIND2 ($2) $1 when ^An? (.*) \((\d+)\: (.*)\) is behind you
action goto UPDATE when ^You assess your combat situation\.\.\.

put #window show %WINDOW
put #clear %WINDOW
put #echo >%WINDOW %COLOR mono " "
put #echo >%WINDOW %COLOR mono "      ^"
put #echo >%WINDOW %COLOR mono " <-- You -->"
put #echo >%WINDOW %COLOR mono "      v"
put #echo >%WINDOW %COLOR mono " "

WAIT:
var FACING 0
var FLANK1 0
var FLANK2 0
var BEHIND1 0
var BEHIND2 0
pause 9999
goto WAIT

UPDATE:
pause 0.5
if "%FLANK1" = "%FLANK2" then var FLANK2
if "%BEHIND1" = "%BEHIND2" then var BEHIND2
if "%BEHIND1" = "0" then var BEHIND1
if "%FACING" = "0" then var FACING
if "%FLANK2" = "0" then var FLANK2
if "%FLANK1" = "0" then var FLANK1
eval SPACETOP replacere ("%FLANK1","\(\d+\)\s","")
eval SPACESIDE replacere ("%FLANK1","."," ")
eval SPACETOP replacere ("%SPACETOP","."," ")

put #clear %WINDOW
if %BEHIND2 != 0 then goto UPDATE_TWOBEHIND
put #echo >%WINDOW %COLOR mono "%SPACETOP %FACING"
put #echo >%WINDOW %COLOR mono "%SPACESIDE     ^^^"
put #echo >%WINDOW %COLOR mono "%FLANK1 <-- You --> %FLANK2"
put #echo >%WINDOW %COLOR mono "%SPACESIDE      v"
put #echo >%WINDOW %COLOR mono "%SPACETOP %BEHIND1"
goto WAIT

UPDATE_TWOBEHIND:
put #echo >%WINDOW %COLOR mono "%SPACETOP %FACING"
put #echo >%WINDOW %COLOR mono "%SPACESIDE     ^^^"
put #echo >%WINDOW %COLOR mono "%FLANK1 <-- You -->"
put #echo >%WINDOW %COLOR mono "%SPACESIDE      v"
put #echo >%WINDOW %COLOR mono "%SPACETOP %BEHIND1 %BEHIND2"
goto WAIT