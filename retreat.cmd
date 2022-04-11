## retreat attempts before telling people you need to be dragged
var help_limit 6
## health limit before telling people you're dying
var health_limit 35
## retreat attempts between telling people you're dying
var dying_limit 3

action var leader $1 when ^\s\s(\w+)\s\(Leader\)\:\s
action var status ready when ^You are already as far away as you can get\!|^You retreat from combat\.
action var status pole when ^You retreat back to pole range\.|closes to pole weapon range on you\!$|(advancing on|facing|flanking|behind) you at pole weapon range\.$
action var status melee when (melee range on|to melee with) you\!$|(facing|flanking|behind) you at melee range\.$|^\[You.*\.\]$
action var left 1;var direction $1 when %leader \w+ (\w+)\, leading (his|her) group\.$
action var left 1 when ^%leader leaves you behind|^Your group moves on without you
action var scarything $1;math help add 1 when ^You try to back away from (.*) but are unable to get away\!
action goto stow_feet when at your feet\, and do not wish to leave it behind\.
action goto move_success when ^You .*(north|east|south|west|up|down)\.$|^You follow %leader

# is this success? "^%leader\'s group climbed" as in "Salvitoriel's group climbed up a curving staircase.", but would that look the same if i was left behind?

var startroomid $roomid
var quick 0
var help 0
var left 0
var direction 0
var dying %dying_limit
if matchre ("%0","leader") then goto retreat
if_1 then var quick %0
if_1 then var direction %0

#need to do this to capture leader's name quickly, if leader is not set by starting the script with ".retreat leader [leader's name]"
group_list:
pause 0.01
put group list
matchre group_list ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move
matchre retreat ^Members of your group
matchwait

retreat:
if %help = %help_limit then gosub shout
if $health <= %health_limit then gosub shout_dying
if $standing = 0 then goto stand
pause 0.01
put retreat
matchre retreat ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move|^You retreat back to pole range|^You try to back away from .* but are unable to get away\!
matchre stand ^You must stand first
matchre retreat_wait ^You are already as far away as you can get\!|^You retreat from combat\.
matchwait 

retreat_wait:
if ("$roomid" != "%startroomid") then goto move_success
if %quick != 0 then goto move
if %left = 1 then goto move
pause 0.2
if %status = pole then goto retreat
if %status = melee then goto retreat
goto retreat_wait

move:
if %direction != 0 then goto do_move
put #echo >Log
put #echo >Log pink LEFT BEHIND! FIND [%leader]!
put #echo >Log

move_success:
put #parse YOU HAVE RETREATED!
exit

move_success_check:
if ("$roomid" != "%startroomid") then goto move_success

do_move:
if %status != ready then goto retreat
pause 0.01
put %direction
matchre do_move ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move
matchre move_success_check ^\[(?!.*\.).*\]$
matchwait

stand:
pause 0.01
put stand
matchre stand ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move|^The weight of|^You are overburdened
matchre retreat ^You stand|^You are already standing|^As you stand
matchwait 1
goto stand

shout:
if matchre ("$roomplayers","^Also here\:") then put "HELP! Can't retreat from %scarything!
else put yell belt "HELP! I'm $charactername! I can't retreat from %scarything!!
var help 0
return

shout_dying:
if %dying >= 3 then 
	{
	put yell belt "HELP! I'm $charactername! I can't retreat and I'm GONNA DIE!!
	var dying 0
	}
var help 0
math dying add 1
return

stow_feet:
pause 0.01
put stow feet
matchre stow_feet ^\.\.\.wait|^You are still stunned|^Sorry\,|^You can't do that while|^You don't seem to be able to move
matchre move ^You pick up .* lying at your feet
matchwait

