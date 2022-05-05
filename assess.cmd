## Window to output to
   var WINDOW Assess
## Clear the window before sending updated information: 1 for yes, 0 for no (Set to 0 if sending to append to Assess window) 
   var CLEAR 0
## Color of the non-link text and arrows
   var COLOR whitesmoke
## Show list of clickable links to face things flanking or behind you: 1 for yes, 0 for no
   var LINKS 1
## Doublespace the link list in mono font ("Facing"/"Behind" will not be links and will show as colored), or single space: 1 for yes, 0 for no
   var DOUBLESPACE 1
## See combat overhead view of enemies engaged to you: 1 for yes, 0 for no
   var OVERHEADVIEW 1
## In a group, this will add a link at the end to click so you can support the group leader. Or choose a person manually by starting the script with someone's name, even if this is 0.
   var ENABLESUPPORT 1
## Speed to update after the text "You assess your combat situation..." shows. Must be higher than 0. Too small and the variables cannot populate before text is printed to the window!
   var UPDATESPEED 0.1

#npcs
action var FACING ($2) $1 when ^An? (.*) \((\d+)\: .*\) is facing you
action if matchre ("%FLANK1","0") then var FLANK1 ($2) $1;if !matchre ("%FLANK1","0") then var FLANK2 ($2) $1 when ^An? (.*) \((\d+)\: (.*)\) is flanking you
action if matchre ("%BEHIND1","0") then var BEHIND1 ($2) $1;if !matchre ("%BEHIND1","0") then var BEHIND2 ($2) $1 when ^An? (.*) \((\d+)\: (.*)\) is behind you

#players
action var FACING $1 when ^(\w+) \(.*\) is facing you
action if matchre ("%FLANK1","0") then var FLANK1 $1;if !matchre ("%FLANK1","0") then var FLANK2 $1 when ^(\w+) \(.*\) is flanking you
action if matchre ("%BEHIND1","0") then var BEHIND1 $1;if !matchre ("%BEHIND1","0") then var BEHIND2 $1 when ^(\w+) \(.*\) is behind you

var NUMBERS zero|first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth|eleventh|twelfth|thirteenth|fourteenth|fifteenth|sixteenth|seventeenth|eighteenth|nineteenth|twentieth

var LEADER You
if %ENABLESUPPORT = 1 then
	{
	action (SUPPORTING) on
	action (SUPPORTING) var LEADER $1 when ^\s\s(\w+)\s\(Leader\)\:\s
	action goto SUPPORT when ^SUPPORT_(.*)
	}

action instant goto UPDATE when ^You assess your combat situation\.\.\.$
action var FACE $1;goto FACE when ^FACE_(.*)

if_1 then
	{
	action (SUPPORTING) off
	var ENABLESUPPORT 1
	var LEADER %1
	action goto SUPPORT when ^SUPPORT_(.*)
	}

START:
put #window show %WINDOW
if %CLEAR = 1 then put #clear %WINDOW
put #echo >%WINDOW %COLOR mono "   Script Loaded!"
if %OVERHEADVIEW = 1 then put #echo >%WINDOW %COLOR mono "         ^"
if %OVERHEADVIEW = 1 then put #echo >%WINDOW %COLOR mono "      < You >"
if %OVERHEADVIEW = 1 then put #echo >%WINDOW %COLOR mono "         v"
put #echo >%WINDOW %COLOR mono "Waiting for ASSESS..."
if %ENABLESUPPORT = 1 then put #echo >%WINDOW %COLOR mono "Support for Group Leader Enabled"

WAIT:
var FACING 0
var FLANK1 0
var FLANK2 0
var BEHIND1 0
var BEHIND2 0
pause 9999
goto WAIT

UPDATE:
delay %UPDATESPEED
if "%FLANK1" = "%FLANK2" then var FLANK2
if "%BEHIND1" = "%BEHIND2" then var BEHIND2
if "%BEHIND1" = "0" then var BEHIND1
if "%FLANK2" = "0" then var FLANK2
eval SPACETOP replacere ("%FLANK1","\(\d+\)\s","")
eval SPACETOP replacere ("%SPACETOP","."," ")
eval SPACESIDE replacere ("%FLANK1","."," ")
if "%FLANK1" = "0" then 
	{
	var FLANK1 0000
	eval SPACESIDE replacere ("%FLANK1","."," ")
	eval FLANK1 replacere ("%FLANK1","."," ")
	var SPACETOP
	}
if "%FACING" != "0" then
	{
	if !matchre ("%FACING","\(\d+\)") then
		{
		var SPACETOP 0000
		eval SPACETOP replacere ("%SPACETOP","."," ")
		}
	}	
if "%FACING" = "0" then var FACING

if %CLEAR = 1 then put #clear %WINDOW
if %OVERHEADVIEW = 0 then goto LINKS
if %CLEAR = 0 then put #echo >%WINDOW
if %BEHIND2 != 0 then goto UPDATE_TWOBEHIND
put #echo >%WINDOW %COLOR mono "%SPACETOP %FACING"
put #echo >%WINDOW %COLOR mono "%SPACESIDE   ^^^"
put #echo >%WINDOW %COLOR mono "%FLANK1 < You > %FLANK2"
put #echo >%WINDOW %COLOR mono "%SPACESIDE    v"
put #echo >%WINDOW %COLOR mono "%SPACETOP %BEHIND1"
goto LINKS

UPDATE_TWOBEHIND:
put #echo >%WINDOW %COLOR mono "%SPACETOP %FACING"
put #echo >%WINDOW %COLOR mono "%SPACESIDE   ^^^"
put #echo >%WINDOW %COLOR mono "%FLANK1 < You >"
put #echo >%WINDOW %COLOR mono "%SPACESIDE    v"
put #echo >%WINDOW %COLOR mono "%SPACETOP %BEHIND1"
put #echo >%WINDOW %COLOR mono "%SPACETOP %BEHIND2"

LINKS:
if %LINKS = 0 then goto WAIT
put #echo >%WINDOW
if %DOUBLESPACE = 0 then put #echo >%WINDOW
if "%FLANK1" = "    " then var FLANK1
if "%FLANK1" != "" then
	{
	eval FACEFLANK1 replacere("%FLANK1","\s","_")
	if %DOUBLESPACE = 1 then 
		{
		put #echo >%WINDOW %COLOR mono "Flanking: -"
		put #link >%WINDOW Face_%FACEFLANK1 #parse FACE_%FACEFLANK1
		}
	else put #link >%WINDOW Flanking:_Face_%FACEFLANK1 #parse FACE_%FACEFLANK1
	}
if "%FLANK2" != "" then
	{
	eval FACEFLANK2 replacere("%FLANK2","\s","_")
	if %DOUBLESPACE = 1 then 
		{
		put #echo >%WINDOW %COLOR mono "Flanking: -"
		put #link >%WINDOW Face_%FACEFLANK2 #parse FACE_%FACEFLANK2
		}
	else put #link >%WINDOW Flanking:_Face_%FACEFLANK2 #parse FACE_%FACEFLANK2
	}
if "%BEHIND1" != "" then
	{
	eval FACEBEHIND1 replacere("%BEHIND1","\s","_")
	if %DOUBLESPACE = 1 then 
		{
		put #echo >%WINDOW %COLOR mono "Behind: -"
		put #link >%WINDOW Face_%FACEBEHIND1 #parse FACE_%FACEBEHIND1
		}
	else put #link >%WINDOW Behind:_Face_%FACEBEHIND1 #parse FACE_%FACEBEHIND1
	}
if "%BEHIND2" != "" then
	{
	eval FACEBEHIND2 replacere("%BEHIND2","\s","_")
	if %DOUBLESPACE = 1 then 
		{
		put #echo >%WINDOW %COLOR mono "Behind: -"
		put #link >%WINDOW Face_%FACEBEHIND2 #parse FACE_%FACEBEHIND2
		}
	else put #link >%WINDOW Behind:_Face_%FACEBEHIND2 #parse FACE_%FACEBEHIND1
	}
if "%LEADER" != "You" then
	{
	if %DOUBLESPACE = 1 then
		{
		put #echo >%WINDOW %COLOR mono "Support: -"
		put #link >%WINDOW %LEADER #parse SUPPORT_%LEADER
		}
	else put #link >%WINDOW Support:_%LEADER #parse SUPPORT_%LEADER
	}
goto WAIT

FACE:
var NUMBER
if matchre ("%FACE","(\d+)") then 
	{
	var NUMBER $0
	eval NUMBER element("%NUMBERS","%NUMBER")
	eval FACE replacere ("%FACE","\(\d+\)_","")
	eval FACE replacere ("%FACE","_"," ")
	}

DO_FACE:
pause 0.1
put face %NUMBER %FACE
matchre DO_FACE ^\.\.\.wait|^You are still stunned|^Sorry\,|^You can't do that while entangled|^You don't seem to be able to move
matchre WAIT ^You turn to face|^You are already facing|^What\'s the point in facing a dead|^There is nothing else to face\!|^Face what?
matchre RETREAT_FACE ^You are too closely engaged and will have to retreat first\.$
matchwait 2
goto WAIT

RETREAT_FACE:
gosub RETREAT
goto DO_FACE

RETREAT_SUPPORT:
gosub RETREAT

SUPPORT:
pause 0.1
put support %LEADER
matchre SUPPORT \.\.\.wait|^You are still stunned|^Sorry\,|^You can't do that while entangled|^You don't seem to be able to move
matchre WAIT ^It appears they are facing you\.|^You turn to face|^You are already facing
matchre RETREAT_SUPPORT ^You are too closely engaged and will have to retreat first\.$
matchwait

RETREAT:
pause 0.1
put retreat
matchre RETREAT \.\.\.wait|^You are still stunned|^Sorry\,|^You can't do that while entangled|^You don't seem to be able to move|^You retreat back to pole range.|^You try to back away
matchre RETURN ^You retreat from combat\.|^You are already as far away as you can get\!
matchwait

RETURN:
return
