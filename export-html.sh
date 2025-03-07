#!/bin/bash

echo "Input your itch.io username:"
read username

PICO8=/Applications/PICO-8.app/Contents/MacOS/pico8

mkdir slime_tactics
$PICO8 -export slime_tactics/slime_tactics.html ./gbjam.p8
mv slime_tactics/slime_tactics.html slime_tactics/index.html
zip -r slime_tactics.zip slime_tactics

butler push slime_tactics.zip $username/slime-tactics:html --if-changed

rm -r slime_tactics
rm slime_tactics.zip
