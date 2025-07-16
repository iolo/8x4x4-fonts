Function fontforge {
    & "${env:ProgramFiles(x86)}\FontForgeBuilds\fontforge.bat" $args
}

Function bitsnpicas {
    & "${env:JAVA_HOME}\bin\java.exe" -jar "$HOME\apps\bitsnpicas\BitsNPicas.jar" $args
}

Function buildFont($eng, $kor, $out) {
    rm "./fonts/$3*"
    python3 fnt2bdf.py "src/$eng" "src/$kor" "fonts/$out.bdf"
    bitsnpicas convertbitmap -f ttf -o temp.ttf "fonts/$out.bdf"
    fontforge --lang=py --script generate_hangul_syllables.py "fonts/$out"
    if (Test-Path "./FontPatcher/font-patcher") {
      fontforge --lang=py --script ./FontPatcher/font-patcher --careful --complete --out fonts "fonts/$out.ttf"
    }
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
