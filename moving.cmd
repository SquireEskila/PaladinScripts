## Moving in X script by <3 Eskila Ikamaye <3
## a small, thin window with a larger font is good for this
## mine has enough room for 3 lines at 22 font size and is as wide as "GO" is

## begin retreating when the move is called. 0 or 1
	var auto_retreat 1
## only auto_retreat if combat state is known. 0 or 1
	var if_combat_only 0
## only auto_retreat if someone else is leader. 0 or 1
        var no_retreat_if_leader 0
## only trigger the countdown if the group leader says it
	var only_leader 1
## name of retreat script:
	var retreat_script .retreat.cmd
## scripts to paused. 0 if no script needs to be paused. add more if needed!
	var pause_script1 spear
	var pause_script2 0
	var pause_script3 0
	var pause_script4 0
	var pause_script5 0
## see if anything thrown is at your feet and pick it up. 0 or 1
	var check_feet 1

var window Move
var numbercolor whitesmoke
var gocolor lime

put #window show %window

# Examples of things that will work:
# Someone says, "Moving in 5!"
# Someone says, "Moving in five!"
# Someone says, "MOVING IN FIVE!!"
# reciting will not, don't recite in battle, it gets lost!

var caps ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE|TEN|ELEVEN|TWELVE|THIRTEEN|FOURTEEN|FIFTEEN|SIXTEEN|SEVENTEEN|EIGHTEEN|NINETEEN|TWENTY
var letters one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty
var numbers 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20

if %only_leader = 0 then action (start) var sayer $1;var countdown $3;goto timer_start when ^(\w+).*\,\s\".*\s?(in|IN|In|iN)\s?\b(%numbers|%letters|%caps)\b

action var leader $1 when ^\s\s(\w+)\s\(Leader\)\:\s
action var leader You when ^(\w+) designates you as the new leader of the group\.
action var leader $1 when ^You designate (\w+) as the new leader of the group\.
action var leader $2 when ^(\w+) designates (?!you)(\w+) as the new leader of the group\.

action var combat 1 when ^\[You\'re (.*) balanced (and|with)|range on you\!$|^You are engaged|melee with you\!$|you at (melee|pole) range\.$|is (facing|flanking|behind) you
action var combat 0 when ^(balance|balanced)\]$|^There is nothing else to face\!

if matchre ("%0","leader") then
	{
	eval leader replacere("%0","leader\s","")
	goto start
	}

if %only_leader = 0 then goto start

group_list:
pause 0.01
put group list
matchre group_list ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move
matchre start ^Members of your group
matchwait

start:
var combat 0
if %only_leader = 1 then action var sayer %leader;var countdown $2;goto timer_start when ^%leader.*\,\s\".*\s?(in|IN|In|iN)\s?\b(%numbers|%letters|%caps)\b
pause 1
pause 6000
goto start

timer_start:
action (start) off
if matchre ("%countdown","%numbers") then goto timer_ready
var loop 0
eval tolower %countdown

timer_loop:
eval word element("%letters","%loop")
if %countdown = %word then goto numberfy
math loop add 1
if %loop = 20 then goto start
goto timer_loop

numberfy:
eval countdown element ("%numbers","%loop")

timer_ready:
put #clear >%window
var clear 3
if ("%pause_script1" != "0")} then put #script pause %pause_script1
if ("%pause_script2" != "0")} then put #script pause %pause_script2
if ("%pause_script3" != "0")} then put #script pause %pause_script3
if ("%pause_script4" != "0")} then put #script pause %pause_script4
if ("%pause_script5" != "0")} then put #script pause %pause_script5
if %check_feet = 1 then gosub check_feet
if {("%no_retreat_if_leader" = "1") AND ("%sayer" = "You") then goto timer_start
else if %auto_retreat = 1 then
	{
	if %if_combat_only = 1 then
		{
		if %combat = 1 then put %retreat_script leader %leader
		}
	if %if_combat_only = 0 then put %retreat_script leader %leader
	}

timer:
if %countdown = 0 then put #echo >%window %gocolor GO
else put #echo >%window %numbercolor %countdown
pause
if %countdown = 0 then goto clear
math countdown subtract 1
goto timer

clear:
put #echo >%window
pause
math clear subtract 1
if %clear = 0 then goto start
goto clear

check_feet:
pause 0.01
put inv atfeet
matchre check_feet ^\.\.\.wait|^You are still stunned|^Sorry\,|^You can't do that while entangled|^You don't seem to be able to move
matchre stow_feet ^All of your items lying at your feet
matchre return ^You aren't wearing anything like that
matchwait

stow_feet:
pause 0.01
put stow feet
matchre stow_feet ^\.\.\.wait|^You are still stunned|^Sorry\,|^You can't do that while entangled|^You don't seem to be able to move
matchre return ^You pick up .* lying at your feet
matchwait

return:
return