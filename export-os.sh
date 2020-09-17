#!/bin/bash

echo "Input your itch.io username"
read username

PICO8=/Applications/PICO-8.app/Contents/MacOS/pico8

$PICO8 -export slime_tactics.bin ./gbjam.p8

butler push slime_tactics.bin/slime_tactics.app $username/slime-tactics:osx --if-changed
butler push slime_tactics.bin/windows $username/slime-tactics:windows --if-changed
butler push slime_tactics.bin/linux $username/slime-tactics:linux --if-changed
butler push slime_tactics.bin/raspi $username/slime-tactics:raspi --if-changed

rm -r slime_tactics.bin
