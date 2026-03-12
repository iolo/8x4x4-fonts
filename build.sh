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

#buildFont "asc_serif.fnt" "han_hanme.fnt" "Hanme_8x4x4"
#buildFont "asc_sans.fnt" "han_hanme.fnt" "Hanme_8x4x4_sans"
#buildFont "asc_serif.fnt" "han_dkby.fnt" "Dkby_8x4x4"
#buildFont "asc_sans.fnt" "han_dkby.fnt" "Dkby_8x4x4_sans"
#buildFont "asc_serif.fnt" "han_iyagi.fnt" "Iyagi_8x4x4"
#buildFont "asc_sans.fnt" "han_iyagi.fnt" "Iyagi_8x4x4_sans"
#buildFont "asc_sans.fnt" "han_sans.fnt" "Sans_8x4x4"
#buildFont "asc_serif.fnt" "han_serif.fnt" "Serif_8x4x4"
buildFont "asc_serif.fnt" "han_pilgi.fnt" "Pilgi_8x4x4"
#buildFont "asc_sans.fnt" "han_sam.fnt" "Sam_8x4x4"
#buildFont "asc_thin.fnt" "han_thin.fnt" "Thin_8x4x4"
