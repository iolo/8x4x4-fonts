#!/bin/bash

function exec_fontforge {
    fontforge $@
}

function exec_bitsnpicas {
    java -jar ./BitsNPicas.jar $@
}

function buildFont {
    rm "./fonts/$3*"
    node fnt2bdf.js "$1" "$2" "$3.bdf"
    exec_bitsnpicas convertbitmap -f ttf -o temp.ttf "$3.bdf"
    exec_fontforge --script generate_hangul_syllables.py "$3"
    if [ -x "./FontPatcher/font-patcher" ]; then
      exec_fontforge --lang=py --script ./FontPatcher/font-patcher --complete "$3.ttf"
    fi
    rm temp.ttf
}

buildFont "src/eng.fnt" "src/dkby.fnt" "Dkby_8x4x4"
buildFont "src/eng_sans.fnt" "src/dkby.fnt" "Dkby_8x4x4_sans"
buildFont "src/eng.fnt" "src/hanme.fnt" "Hanme_8x4x4"
buildFont "src/eng_sans.fnt" "src/hanme.fnt" "Hanme_8x4x4_sans"
buildFont "src/eng.fnt" "src/iyagi.fnt" "Iyagi_8x4x4"
buildFont "src/eng_sans.fnt" "src/iyagi.fnt" "Iyagi_8x4x4_sans"
buildFont "src/eng.fnt" "src/serif.fnt" "Serif_8x4x4"
buildFont "src/eng_sans.fnt" "src/sans.fnt" "Sans_8x4x4"
