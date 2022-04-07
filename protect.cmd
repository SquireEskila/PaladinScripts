action var protect $1 when ^You move into position to cover (\w+) from harm\.
action var protect $1 when ^You are already protecting (\w+)\!

if_1 then goto protect_setup
put #echo
put #echo yellow Protect who? .protect [name]!
put #echo
exit

protect_setup:
eval name tolower (%1)
eval capital replacere ("%name","(?!^[a-z]|^[A-Z])(.*)","")
eval name replacere ("%name","(^[a-z]|^[A-Z])","")
eval capital toupper (%capital)
var protect %capital%name

protect:
if $standing = 0 then gosub STAND
put protect %protect cover
matchre protect ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while
matchre lost ^Protect what\?
matchre wait ^You move into position to|^You are already protecting
matchre stand_protect ^You should stand up if you want to properly protect
matchwait

stand_protect:
gosub stand
goto protect

wait:
matchre stand_protect ^You should stand up if you want to properly protect 
matchre lost ^%protect is no longer around for you to protect
matchre logged ^You are no longer protecting
matchwait

logged:
put #echo
put #echo yellow %protect has logged out!
put #echo

lost:
waitforre ^Also here\:.*%protect|^.*(?!.*\")(%protect)
goto protect

stand:
pause 0.1
put stand
matchre stand ^\.\.\.wait|^Sorry\,|^You are still stunned|^You can't do that while|^You don't seem to be able to move|^The weight of|^You are overburdened
matchre return ^You stand|^You are already standing|^As you stand
matchwait 1
goto stand

return:
return