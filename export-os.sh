#!/bin/bash

PICO8=/Applications/PICO-8.app/Contents/MacOS/pico8

$PICO8 -export slime_tactics.bin ./gbjam.p8

butler push slime_tactics.bin/slime_tactics_osx.zip civilianzero/slime-tactics:osx --if-changed
butler push slime_tactics.bin/slime_tactics_windows.zip civilianzero/slime-tactics:windows --if-changed
butler push slime_tactics.bin/slime_tactics_linux.zip civilianzero/slime-tactics:linux --if-changed

rm -r slime_tactics.bin
