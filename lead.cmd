action instant goto lead when ^You feel your leadership wane\.

lead:
pause 0.1
put lead
matchre lead ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while
matchre face ^A Paladin must not command from the rear echelons like a coward
matchre following ^How do you expect to lead when you're following|^Leading usually implies that someone is following you
matchre wait looks to you for guidance\.$
matchre stand_lead An inspiring leader would at least stand up
matchwait

stand_lead:
gosub stand
goto lead

short_wait:
pause 10
goto lead

room_wait:
matchre lead to (pole|melee).*on you\!$
matchre face ^\[.*\]$
matchwait

face:
pause 0.1
put face next 
matchre face ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while
matchre short_wait ^Face what?|^What\'s the point in facing a dead
matchre room_wait ^There is nothing else to face\!
matchre lead ^You turn to face a|^You are already facing|to (pole|melee).*on you\!$|^You will have to retreat from your current melee first
matchwait

following:
waitforre designates you as the new leader of the group\.$|joins your group\.$|takes (his|her) rightful place beside you\.$
goto lead

wait:
pause 601
goto lead

stand:
pause 0.1
put stand
matchre stand ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move|^The weight of|^You are overburdened
matchre return ^You stand|^You are already standing|^As you stand
matchwait 1
goto stand

return:
return




# extra stuff

#lead_wait:
## this is disabled for now but it gives you an idea of what it should do. 
# gosub marshal_order
## or you could do this:
# put #echo >Log pink *** Remember to cast Marshal Order! ***
## Paladin lead falls off after 10 minutes but the action at the top of the script should catch it
#pause 601
#goto lead

# marshal_order:
# if $SpellTimer.MarshalOrder.active = 0 then goto marshal_cast
# pause 0.2
# if $SpellTimer.MarshalOrder.duration <= 2 then goto marshal_cast
# return
#
# marshal_cast:
# put .cast marshal order  ## <-- Put your spell cast script here with whatever flags make it do Marshal Order
# waitforre ^SPELL CAST    ## <-- Your spell cast script should "put #parse SPELL CAST" when its successful
# return