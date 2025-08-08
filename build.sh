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

#ENG_SERIF = "eng.fnt"
#ENG_SANS = "eng_sans.fnt"
ENG_SERIF="HMSTD1.ENG"
#ENG_SANS="HMDEF.ENG"
ENG_SANS="SEMIROM.ENG"

buildFont $ENG_SERIF "dkby.fnt" "Dkby_8x4x4"
buildFont $ENG_SANS "dkby.fnt" "Dkby_8x4x4_sans"
buildFont $ENG_SERIF "hanme.fnt" "Hanme_8x4x4"
buildFont $ENG_SANS "hanme.fnt" "Hanme_8x4x4_sans"
buildFont $ENG_SERIF "iyagi.fnt" "Iyagi_8x4x4"
buildFont $ENG_SANS "iyagi.fnt" "Iyagi_8x4x4_sans"
buildFont $ENG_SERIF "serif.fnt" "Serif_8x4x4"
buildFont $ENG_SANS "sans.fnt" "Sans_8x4x4"

buildFont $ENG_SERIF "HMSAM.KOR" "Saemmul_8x4x4"
buildFont $ENG_SANS "HMSAM.KOR" "Saemmul_8x4x4"

buildFont "HMMCR.ENG" "HMSYSTH.KOR" "HanmeThin_8x4x4"
