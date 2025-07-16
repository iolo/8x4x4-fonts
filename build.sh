#!/bin/bash

function exec_fontforge {
    fontforge $@
}

function exec_bitsnpicas {
    java -jar ./BitsNPicas.jar $@
}

function buildFont {
    rm "./fonts/$3*"
    python3 fnt2bdf.py "src/$1" "src/$2" "fonts/$3.bdf"
    exec_bitsnpicas convertbitmap -f ttf -o temp.ttf "fonts/$3.bdf"
    exec_fontforge --script generate_hangul_syllables.py "fonts/$3"
    if [ -x "./FontPatcher/font-patcher" ]; then
      exec_fontforge --lang=py --script ./FontPatcher/font-patcher --complete --out fonts "fonts/$3.ttf"
    fi
    rm temp.ttf
}

buildFont "eng.fnt" "dkby.fnt" "Dkby_8x4x4"
buildFont "eng_sans.fnt" "dkby.fnt" "Dkby_8x4x4_sans"
buildFont "eng.fnt" "hanme.fnt" "Hanme_8x4x4"
buildFont "eng_sans.fnt" "hanme.fnt" "Hanme_8x4x4_sans"
buildFont "eng.fnt" "iyagi.fnt" "Iyagi_8x4x4"
buildFont "eng_sans.fnt" "iyagi.fnt" "Iyagi_8x4x4_sans"
buildFont "eng.fnt" "serif.fnt" "Serif_8x4x4"
buildFont "eng_sans.fnt" "sans.fnt" "Sans_8x4x4"
