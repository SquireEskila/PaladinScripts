## Group engagement script by <3 Eskila Ikamaye <3 !AND! <3 Korya <3 - Thank you for the multi-line action idea, the update variable to queue updates, capturing messaging, and other ideas i borrowed from you!!
## this is to help notify when people in your group are engaged and unable to follow!
## it uses automatic group list updates to display health and if they're stunned or prone! so these updates are less frequent

## issues:
## places that break groups... need a lot more testing around places like Kaerna barricade, faldesu river diving
## because of some messaging with the %movelist %directions options being weird when people arrive, going into a place like a house and having a group member show up after you, the script thinks they're leaving instead
## further moving after errors like these sorts itself out with the room check loop
## the group adding actions like this:
##     action (group) var name $1;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when X happens
## need to be reworked. Its not good to have an action do a goto because it could interrupt other things. But the brief moments where the (group) action classes are disabled will skip updating this info.
## but without the "goto wait" stopping the rest of the action from triggering, the %total will get thrown off and multiply group members
## the idea is that most of the time when someone leaves the group, they will come back or you will go find them, instead of removing them from the list it instead keeps last known information about them in the list
## like health, engagement status, position status... so adding them back has to work for finding lost members as well as adding entirely new ones
## 
## Aesry stairs show half the group climbing down or up, so the script thinks they're lost a lot, when they're not. depending where you are in the Also here: list, which half of the group is "lost" changes.
## Also got into an infinite loop doing the room check... not sure how
##
## many unfound bugs still to discover
## Its not done, but its time to get it out there to get people to test it and help with fixes so it can be amazing for everyone!

## user variables:

## autogroup 0 to turn this off. it will make you grab people that were left behind if you return to their room, or they're in the room and you look at the room
## such add checks are toggled by the [Area, Room Name] being parsed
var autogroup 1

## update speed is how many seconds the wait loop is. For faster window updating, 0.2 or 0.5 might work, but it could make Genie crash the script thinking its in an infinite loop
var update_speed 0.5

## room speed is how many seconds it takes to check the people left behind in the previous room
## going fast will restart this process every room you pass by
## if its too small then you could mistakenly mark members as "lost" because they don't load into the room before the check happens
var room_speed 0.5 

## window to update to, the script will make it show up automatically if it doesn't exist
var window grouplist

## set your window name and highlight colors here. Only *Melee*, *Pole*, *LOST* and [prone!], etc., are highlighted.
## however, empaths may want to highlight some of the health numbers like 49-40% and lower.
var positioncolor pink
var meleecolor red
var polecolor yellow
var lostcolor red

put #highlight {regex} {%lostcolor} {(\*LOST\*)}
put #highlight {regex} {%meleecolor} {(\*Melee\*)}
put #highlight {regex} {%polecolor} {(\*Pole\*)}
put #highlight {regex} {%positioncolor} {\s(\[(prone|sitting|kneeling|stunned|immobile|sleeping)\!\])$}

## end of user variables

put #window show %window

var lastroomid $roomid
var movelist canters|cartwheels|dances|drifts|ducks|glides|hobbles|hops|jogs|limps|lopes|lurches|lumbers|marches|meanders|moseys|pads|parades|patters|plods|prances|rambles|roves|runs|rushes|sashays|saunters|scampers|scrambles|shambles|shuffles|skips|slinks|slogs|slouches|sprints|staggers|stomps|stides|strolls|struts|stumbles|swaggers|traipses|tramps|treads|treks|troops|trots|trudges|walks|wanders|goes|climbs|swims|just went|went|wandered|moves|steps onto
var directions north|northeast|east|southeast|south|southwest|west|northwest|up|down|in|out|widdershins|clockwise|through|some stairs|(into (?!(position|a position)))|(over (?!to guard))

action var lastroomid $roomid;goto room_check when ^\[(?!.*\.).*\]$

restart:
action (start) on
action (start) var group $1|%group when ^\s\s(\w+).*\:
action (start) var leader $1 when ^\s\s(\w+)\s\(Leader\)\:\s
action (start) var members $1 when ^There are (.*) members in your group\.
action (start) var member $1;var %member_health 100+ when ^\s\s(\w+).*\: Invigorated
action (start) var member $1;var %member_health 100% when ^\s\s(\w+).*\: Healthy
action (start) var member $1;var %member_health 99-90% when ^\s\s(\w+).*\: Bruised
action (start) var member $1;var %member_health 89-80% when ^\s\s(\w+).*\: Hurt
action (start) var member $1;var %member_health 79-70% when ^\s\s(\w+).*\: Battered
action (start) var member $1;var %member_health 69-60% when ^\s\s(\w+).*\: Beat up
action (start) var member $1;var %member_health 59-50% when ^\s\s(\w+).*\: Very beat up
action (start) var member $1;var %member_health 49-40% when ^\s\s(\w+).*\: Badly hurt
action (start) var member $1;var %member_health 39-30% when ^\s\s(\w+).*\: Very badly hurt
action (start) var member $1;var %member_health 29-20% when ^\s\s(\w+).*\: Smashed up
action (start) var member $1;var %member_health 19-10% when ^\s\s(\w+).*\: Terribly wounded
action (start) var member $1;var %member_health 9-1% when ^\s\s(\w+).*\: Near death
action (start) var member $1;var %member_position when ^\s\s(\w+).*\: (Invigorated|Healthy|Bruised|Hurt|Battered|Beat up|Very beat up|Badly hurt|Very badly hurt|Smashed up|Terribly wounded|Near death)\.
action (start) var member $1;var %member_position [$2!] when ^\s\s(\w+).*\, (prone|sitting|kneeling|stunned|immobile|sleeping)\.
var group 0

gosub group_list

start:
pause 0.01
eval group replacere ("%group","\|0","")
eval total count("%group","|")
math total add 1
math total divide 2
var loop 0

start_loop:
eval member element ("%group","%loop")
eval group replacere ("%group","%member\|%member","%member")
var %member_engage Ready!
var %member_lost
math loop add 1
if %loop < %total then goto start_loop
pause 0.01

action (start) off
action (group) on
action (group_list) on
action (group_disband) on

# these will trigger on advancing/retreating
action var name $1;if matchre("%%name_engage","\*Pole\*|\?\?\?") then var %name_engage Ready!;if ("%%name_engage" = "*Melee*") then var %name_engage *Pole*;var update 1 when ^(%group) retreats? from combat\.$
action var name You;var %name_engage *Pole*;var update 1 when ^You retreat back to pole range\.
action var name $1;if ("%%name_engage" != "*Melee*") then var %name_engage *Pole*;var update 1 when ^(%group) closes? to pole weapon range
action var name $1;if ("%%name_engage" != "*Melee*") then var %name_engage *Pole*;var update 1 when pole weapon range on (%group)(\!|\.)$
action var name You;if ("%%name_engage" != "*Melee*") then var %name_engage *Pole*;var update 1 when pole weapon range on you\!$
action var name $1;if ("%%name_engage" != "*Melee*") then var update 1;if ("%%name_engage" != "*Melee*") then var var %name_engage *Melee* when ^(%group) closes? to melee range
action var name $2;if ("%%name_engage" != "*Melee*") then var var update 1;if ("%%name_engage" != "*Melee*") then var %name_engage *Melee* when (melee range on|to melee with) (%group)(\!|\.)$
action var name You;if ("%%name_engage" != "*Melee*") then var var update 1;if ("%%name_engage" != "*Melee*") then var %name_engage *Melee* when (melee range on|to melee with) you\!$

# these will trigger off assess
action var name assess_clear;var update 1 when ^You assess your combat situation\.\.\.
action var name $2;var %name_engage *Melee* when (facing|flanking|behind) (%group) at melee range\.
action var name You;var %name_engage *Melee* when (facing|flanking|behind) you at melee range\.
action var name $2;if ("%%name_engage" != "*Melee*") then var %name_engage *Pole* when (advancing on|facing|flanking|behind) (%group) at pole weapon range\.
action var name You;if ("%%name_engage" != "*Melee*") then var %name_engage *Pole* when (advancing on|facing|flanking|behind) you at pole weapon range\.

# disengage spell effects: innocence, intimidate, whole displacement, halo, 
action var name 1$;var %name_engage Ready!;var update 1 when disengages from (%group)\.$
action var name 1$;var %name_engage Ready!;var update 1 when ^The ring of light smashes into .* forcefully pushing it away from (%group)\.
action var name You;var %name_engage Ready!;var update 1 when ^The ring of light smashes into .* forcefully pushing it from melee to missile range, away from you\.

#action var name 1$;var %name_engage Ready!;var update 1 when ^(%group) is engulfed in a ripple of light and shadow, and vanishes, only to reappear some distance away\!
#action var name You;var %name_engage Ready!;var update 1 when ^A blinding flash of light engulfs you as a gut-wrenching sensation wracks your body, moving you further away\!
action var name 1$;var %name_engage Ready!;var %name_lost *LOST* Room [$roomid];var update 1 when ^(%group) is engulfed in a ripple of light and shadow, and vanishes, only to reappear some distance away\!
action var name You;var %name_engage Ready!;goto group_lost when ^A blinding flash of light engulfs you as a gut-wrenching sensation wracks your body, moving you further away\!

# engage spell effects: paeldryth's wrath
action var name You;if ("%%name_engage" != "*Melee*") then var update 1;var %name_engage *Melee* when ^The winds slam into .* until it is right in front of you\!
# third person messaging needed
# war stomp?
# crusader's challenge?

# group adding - auto updates group list
action (group) var name $2;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) holds? (\w+)\'s hand lightly\.
action (group) var name $3;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) (reach|reaches) over and holds? (\w+)\'s hand\.
action (group) var name $2;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) reaches over and holds hands with (\w+).
action (group) var name $2;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) holds? (\w+)\'s hand, giving
action (group) var name $2;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) clasps? (\w+)\'s hand tenderly\.
action (group) var name $2;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) roughly grabs? (\w+)\'s hand\.
action (group) var name $1;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(\w+) joins (your|%leader's) group\.
action (group) var name $2;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(%group) adds? (\w+) to (your|the) group\.
action (group) var name $1;var %name_engage ???;var %name_lost;if matchre ("%group","%name") then goto wait;math total add 1;var group %group|%name when ^(\w+) takes (his|her) rightful place beside (you|%leader)\.

# group subtracting
action (group_disband) var name $1;math total subtract 1;eval group replacere("%group","%name\||\|%name","");var update 1 when ^You disband (%group)\.
action var name $1;var %name_lost *LOST* Room [%lastroomid];var update 1 when ^(\w+) is engaged and unable to follow you\.
action var name $1;math total subtract 1;var %name_engage ???;eval group replacere("%group","%name\||\|%name","");var update 1 when ^(%group) left the group\.
action var name $1;math total subtract 1;eval group replacere("%group","%name\||\|%name","");var update 1 when ^%leader forces (\w+) out of (his|her) group\.
action goto group_lost when ^%leader leaves you behind|^%leader (%movelist) (%directions)|^Your group moves on without you
action goto group_wait when ^(\w+) stops you from following|^(\w+) forces you out of (his|her) group
action action (group_disband) off;goto list_group_lost when ^Defaulting to GROUP disband
action action (group_disband) off;goto end when ^You leave the group\.
action (group_disband) goto list_group_lost when ^There is 1 member

# this one is driving me crazy, why does it only work if the person is in the group when the script is started?
# also fires off if you go inside a house then then ^(%name) (walks) (in) the door
action var name $1;if ("%name" = "%leader") then goto group_lost;var place $3;math total subtract 1;var %name_engage ???;var %name_lost *LOST* (%place);var update 1 when ^(%group) (%movelist) (%directions)

# group other
action var leader You;var update 1 when ^(\w+) designates you as the new leader of the group\.
action var leader $1;var update 1 when ^You designate (\w+) as the new leader of the group\.
action var leader $2;var update 1 when ^(\w+) designates (?!you)(\w+) as the new leader of the group\.
action goto restart when ^You join (\w+)\'s group\.

# health subs, position, and further group checking
action var checklist $1|%checklist when ^\s\s(\w+).*\:
action var name $1;var %name_health 100+ when ^\s\s(\w+).*\: Invigorated
action var name $1;var %name_health 100% when ^\s\s(\w+).*\: Healthy
action var name $1;var %name_health 99-90% when ^\s\s(\w+).*\: Bruised
action var name $1;var %name_health 89-80% when ^\s\s(\w+).*\: Hurt
action var name $1;var %name_health 79-70% when ^\s\s(\w+).*\: Battered
action var name $1;var %name_health 69-60% when ^\s\s(\w+).*\: Beat up
action var name $1;var %name_health 59-50% when ^\s\s(\w+).*\: Very beat up
action var name $1;var %name_health 49-40% when ^\s\s(\w+).*\: Badly hurt
action var name $1;var %name_health 39-30% when ^\s\s(\w+).*\: Very badly hurt
action var name $1;var %name_health 29-20% when ^\s\s(\w+).*\: Smashed up
action var name $1;var %name_health 19-10% when ^\s\s(\w+).*\: Terribly wounded
action var name $1;var %name_health 9-1% when ^\s\s(\w+).*\: Near death
action var name $1;var %name_position when ^\s\s(\w+).*\: (Invigorated|Healthy|Bruised|Hurt|Battered|Beat up|Very beat up|Badly hurt|Very badly hurt|Smashed up|Terribly wounded|Near death)\.
action var name $1;var %name_position [$2!] when ^\s\s(\w+).*\, (prone|sitting|kneeling|stunned|immobile|sleeping)\.
action var update 1 when ^There are (.*) members in your group\.$

update:
var update 0
var loop 0
var lost 0
if ("%name" = "assess_clear") then goto ready_loop
var echo #echo >%window Group: Health - Engage [Status]
eval total count("%group","|")
var name You
if %name = %leader then var echo %echo;#echo >%window * %name (Lead): %%name_health - %%name_lost %%name_engage %%name_position
else var echo %echo;#echo >%window  * %name: %%name_health - %%name_lost %%name_engage %%name_position

update_loop:
eval name element ("%group","%loop")
if %name != You then
	{
	if matchre ("%name","%checklist") then var %name_lost
	if %name = %leader then var echo %echo;#echo >%window * %name (Lead): %%name_health - %%name_lost %%name_engage %%name_position
	else var echo %echo;#echo >%window * %name: %%name_health - %%name_lost %%name_engage %%name_position
	if matchre ("%%name_lost","\*LOST\*") then math lost add 1
	}
if %loop = %total then goto update_window
math loop add 1
goto update_loop

update_window:
put #clear %window
put %echo
evalmath members %total+1
evalmath members_ready %members-%lost
put #echo >%window Members: %members - Here: %members_ready - Lost: %lost
var checklist 0

# this is copied a lot so hopefully Genie doesnt get tricked into an infinite loop error
wait:
pause %update_speed
if %update = 1 then goto update
pause %update_speed
if %update = 1 then goto update
pause %update_speed
if %update = 1 then goto update
pause %update_speed
if %update = 1 then goto update
pause %update_speed
if %update = 1 then goto update
pause %update_speed
if %update = 1 then goto update
goto wait

ready_loop:
eval name element ("%group","%loop")
var %name_engage Ready!
if %loop = %total then goto update
math loop add 1
goto ready_loop

list_group_lost:
var loop 0
list_group_lost_loop:
eval name element ("%group","%loop")
if %name != You then var %name_lost *LOST* (Room %lastroomid?)
if %loop = %total then goto update
math loop add 1
goto list_group_lost_loop

room_check:
pause %room_speed
var loop 0
action (group) off
action (group_disband) off

room_check_loop:
eval checking element ("%group","%loop")
if %checking = You then goto room_check_resume
if !matchre ("$roomplayers","%checking") then
	{
	if !matchre ("%%checking_lost","\*LOST\*") then var %checking_lost *LOST* (Room %lastroomid?) -
	goto room_check_resume
	}
if %autogroup = 1 then 
	{
	if matchre ("%leader%%checking_lost", "You\*LOST\*") then 
		{
		gosub group_add
		var %checking_lost
		}
	}

room_check_resume:
if %loop = %total then goto room_check_done
math loop add 1
pause 0.001
goto room_check_loop

room_check_done:
action (group) on
action (group_list) on
action (group_disband) on
goto update

group_add:
pause 0.05
var %checking_engage ???
put group %checking
matchre group_add ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move
matchre return ^You add %checking to your group\.|^%checking is already in your group.|^I\'m sorry\, but who are you trying to add to your group\?
matchwait

group_list:
pause 0.05
put group list
matchre group_list ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move
matchre return ^Members of your group
matchwait

stand:
pause 0.05
put stand
matchre stand ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move|^The weight of|^You are overburdened
matchre return ^You stand|^You are already standing|^As you stand
matchwait

return:
return

group_lost:
var loop 0
var echo 0
if ("%leader" = "You") then goto list_group_lost
put #clear grouplist
put #echo >%window You lost the group.
else put #echo >%window Find %leader to join again!

join_leader:
if matchre ("$roomplayers","%leader") then goto do_join_leader
if $standing != 1 then gosub stand
pause 1
goto join_leader

do_join_leader:
pause 0.05
put join %leader
matchre do_join_leader ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move
matchre start ^You join (\w+)'s group|^You are already following
matchwait

group_wait:
#put #clear grouplist
put #echo
put #echo >%window You were disbanded from the group.
put #echo >%window Find %leader to join again when they're ready!
waitforre ^You join (\w+)'s group|^You are already following
goto restart

end:
put #clear grouplist
put #echo >%window You left the group on purpose.
put #echo >%window Find %leader to join again when you're ready!
waitforre ^You join (\w+)'s group|^You are already following
goto restart